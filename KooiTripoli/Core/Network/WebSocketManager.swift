import Foundation
import Combine

/// WebSocket manager for real-time updates (order tracking, group cart sync, etc.)
/// Mirrors the Kotlin `io.github.sac.Socket` + `AppService` implementation
/// Original app uses Socket.IO-like channels with events:
/// - MEMBER_EVENT (user-specific)
/// - SERVICE_REQUEST_STATUS (service requests)
/// - TRACKING_SERVICE (order/delivery tracking)
/// - CHAT_SERVICE (chat messages)
/// - VOIP_SERVICE (VOIP calls)
public final class WebSocketManager: ObservableObject {
    public static let shared = WebSocketManager()

    // MARK: - Configuration
    private let baseURL = "wss://www.kool.com.ly/websocket"
    private let reconnectInterval: TimeInterval = 40 // seconds (matches AppService.RECONNECTION_INTERVAL_SECONDS)
    private let pingInterval: TimeInterval = 10    // seconds (matches AppService.PING_INTERVAL_SECONDS)
    private let pingEventName = "PING_INTERVAL"     // matches AppService.PING_EVENT_NAME

    // MARK: - Internal State
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    private var reconnectTimer: Timer?
    private var pingTimer: Timer?
    private var currentMemberId: String?
    private var currentUserType: String = "Passenger"
    private var subscribedChannels: Set<String> = []
    private var isIntentionalDisconnect = false

    // MARK: - Published Connection State
    @Published public private(set) var connectionState: ConnectionState = .disconnected
    @Published public private(set) var lastError: Error?

    // MARK: - Event Publishers (matching original app's SocketEvents)
    public let memberEvents = PassthroughSubject<MemberEvent, Never>()
    public let serviceRequestUpdates = PassthroughSubject<ServiceRequestUpdate, Never>()
    public let trackingUpdates = PassthroughSubject<TrackingUpdate, Never>()
    public let chatMessages = PassthroughSubject<ChatMessage, Never>()
    public let voipEvents = PassthroughSubject<VoipEvent, Never>()

    // Generic message handler for other event types
    public let rawMessages = PassthroughSubject<WebSocketRawMessage, Never>()

    // Legacy publishers for backward compatibility
    public let orderUpdates = PassthroughSubject<OrderUpdate, Never>()
    public let groupCartUpdates = PassthroughSubject<GroupCartUpdate, Never>()
    public let deliveryTrackingUpdates = PassthroughSubject<DeliveryTrackingUpdate, Never>()
    public let notifications = PassthroughSubject<KooiNotification, Never>()

    private init() {}

    // MARK: - Public API

    /// Connects to the WebSocket server with authentication
    /// - Parameters:
    ///   - memberId: Current user's member ID (used to build channel names)
    ///   - userType: User type ("Passenger", "Driver", etc.) - defaults to "Passenger"
    ///   - authToken: Optional authentication token for the WebSocket handshake
    public func connect(memberId: String, userType: String = "Passenger", authToken: String? = nil) {
        // If already connected with same credentials, do nothing
        if case .connected = connectionState, self.currentMemberId == memberId, self.currentUserType == userType {
            return
        }

        disconnect(clean: false)
        isIntentionalDisconnect = false
        self.currentMemberId = memberId
        self.currentUserType = userType

        var urlString = baseURL
        if let token = authToken {
            urlString += "?token=\(token)"
        }
        urlString += "&memberId=\(memberId)&userType=\(userType)"

        guard let url = URL(string: urlString) else {
            lastError = URLError(.badURL)
            connectionState = .disconnected
            return
        }

        var request = URLRequest(url: url)
        request.setValue("KOOI-iOS/1.0.0", forHTTPHeaderField: "User-Agent")
        request.setValue("websocket", forHTTPHeaderField: "Upgrade")
        request.setValue("keep-alive, Upgrade", forHTTPHeaderField: "Connection")

        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()

        connectionState = .connecting
        receiveMessage()
    }

    /// Disconnects from the WebSocket server
    /// - Parameter clean: If true, won't attempt reconnection
    public func disconnect(clean: Bool = true) {
        isIntentionalDisconnect = clean
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        pingTimer?.invalidate()
        pingTimer = nil

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        subscribedChannels.removeAll()
        connectionState = .disconnected
    }

    /// Subscribe to a channel (matches AppService's subscribeToChannels)
    public func subscribe(to channels: [String]) {
        guard case .connected = connectionState else {
            // Queue for when connected
            subscribedChannels.formUnion(channels)
            return
        }

        let newChannels = channels.filter { !subscribedChannels.contains($0) }
        guard !newChannels.isEmpty else { return }

        subscribedChannels.formUnion(newChannels)

        let message = WebSocketMessage(
            type: "subscribe",
            data: ["channels": newChannels],
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        send(message)
    }

    /// Unsubscribe from channels
    public func unsubscribe(from channels: [String]) {
        let channelsToRemove = channels.filter { subscribedChannels.contains($0) }
        guard !channelsToRemove.isEmpty else { return }

        subscribedChannels.subtract(channelsToRemove)

        let message = WebSocketMessage(
            type: "unsubscribe",
            data: ["channels": channelsToRemove],
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        send(message)
    }

    /// Send a message on a specific channel (for chat, etc.)
    public func publish(to channel: String, event: String, data: [String: Any]) {
        let message = WebSocketMessage(
            type: "publish",
            data: [
                "channel": channel,
                "event": event,
                "data": data
            ],
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        send(message)
    }

    /// Emit a direct event (for service requests, etc.)
    public func emit(event: String, data: [String: Any]) {
        let message = WebSocketMessage(
            type: "emit",
            data: [
                "event": event,
                "data": data
            ],
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        send(message)
    }

    // MARK: - Default Channel Builders (matching SocketEvents.buildEvents)

    /// Build the standard channel names for a member
    public func buildDefaultChannels(memberId: String, userType: String) -> [String] {
        let prefix = userType.uppercased()
        return [
            "\(prefix)_\(memberId)",                    // MEMBER_EVENT
            "SERVICE_REQUEST_STATUS_\(memberId)",       // SERVICE_REQUEST_STATUS
            "TRACKING_SERVICE_DATA_\(memberId)",        // TRACKING_SERVICE
            "CHAT_SERVICE_\(memberId)",                 // CHAT_SERVICE
            "VOIP_SERVICE_\(memberId)"                  // VOIP_SERVICE
        ]
    }

    /// Subscribe to all default channels for the current member
    public func subscribeToDefaultChannels() {
        guard let memberId = currentMemberId else { return }
        let channels = buildDefaultChannels(memberId: memberId, userType: currentUserType)
        subscribe(to: channels)
    }

    // MARK: - Private Methods

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.handleError(error)
            case .success(let message):
                self.handleMessage(message)
                self.receiveMessage() // Continue listening
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            parseMessage(text)
        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                parseMessage(text)
            }
        @unknown default:
            break
        }
    }

    private func parseMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

        // Handle different message formats from the server
        if let type = json["type"] as? String {
            switch type {
            case "connected":
                handleConnected(json)
            case "subscribed":
                // Subscription confirmed
                break
            case "unsubscribed":
                // Unsubscription confirmed
                break
            case "event":
                // Channel event received
                if let channel = json["channel"] as? String,
                   let event = json["event"] as? String,
                   let eventData = json["data"] as? [String: Any] {
                    routeEvent(channel: channel, event: event, data: eventData)
                }
            case "broadcast":
                // Direct broadcast event
                if let event = json["event"] as? String,
                   let eventData = json["data"] as? [String: Any] {
                    routeEvent(channel: "", event: event, data: eventData)
                }
            case "pong":
                // Heartbeat response
                break
            case "error":
                if let errorMsg = json["message"] as? String {
                    lastError = NSError(domain: "WebSocket", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])
                }
            default:
                // Unknown type, forward as raw
                rawMessages.send(WebSocketRawMessage(type: type, payload: json))
            }
        } else if let channel = json["channel"] as? String,
                  let event = json["event"] as? String,
                  let eventData = json["data"] as? [String: Any] {
            // Alternative format: direct channel/event/data
            routeEvent(channel: channel, event: event, data: eventData)
        }
    }

    private func routeEvent(channel: String, event: String, data: [String: Any]) {
        // Route based on channel name (matching original AppService logic)
        if channel.hasSuffix("_\(currentMemberId ?? "")") || channel.contains("MEMBER") {
            if let memberEvent = MemberEvent.from(channel: channel, event: event, data: data) {
                memberEvents.send(memberEvent)
            }
        } else if channel.hasPrefix("SERVICE_REQUEST_STATUS_") || event.contains("SERVICE_REQUEST") {
            if let update = ServiceRequestUpdate.from(channel: channel, event: event, data: data) {
                serviceRequestUpdates.send(update)
            }
        } else if channel.hasPrefix("TRACKING_SERVICE_DATA_") || event.contains("TRACKING") || event.contains("ORDER") {
            if let update = TrackingUpdate.from(channel: channel, event: event, data: data) {
                trackingUpdates.send(update)
            }
        } else if channel.hasPrefix("CHAT_SERVICE_") || event.contains("CHAT") || event.contains("MESSAGE") {
            if let message = ChatMessage.from(channel: channel, event: event, data: data) {
                chatMessages.send(message)
            }
        } else if channel.hasPrefix("VOIP_SERVICE_") || event.contains("VOIP") || event.contains("CALL") {
            if let voipEvent = VoipEvent.from(channel: channel, event: event, data: data) {
                voipEvents.send(voipEvent)
            }
        } else {
            // Forward unhandled events as raw
            rawMessages.send(WebSocketRawMessage(type: event, payload: ["channel": channel, "data": data]))
        }

        // Also route to legacy publishers for backward compatibility
        routeLegacyEvent(channel: channel, event: event, data: data)
    }

    private func routeLegacyEvent(channel: String, event: String, data: [String: Any]) {
        // Legacy event routing for backward compatibility with existing views
        if event == "order_update" || event.contains("ORDER") {
            if let update = OrderUpdate.from(json: data) {
                orderUpdates.send(update)
            }
        } else if event == "group_cart_update" || event.contains("GROUP_CART") {
            if let update = GroupCartUpdate.from(json: data) {
                groupCartUpdates.send(update)
            }
        } else if event == "delivery_tracking" || event.contains("DELIVERY") || event.contains("TRACKING") {
            if let update = DeliveryTrackingUpdate.from(json: data) {
                deliveryTrackingUpdates.send(update)
            }
        } else if event == "notification" {
            if let notification = KooiNotification.from(json: data) {
                notifications.send(notification)
            }
        }
    }

    private func handleConnected(_ json: [String: Any]) {
        connectionState = .connected
        lastError = nil

        // Start ping timer
        startPingTimer()

        // Subscribe to default channels
        subscribeToDefaultChannels()

        // Re-subscribe to any previously subscribed channels
        if !subscribedChannels.isEmpty {
            subscribe(to: Array(subscribedChannels))
        }
    }

    private func handleError(_ error: Error) {
        lastError = error
        connectionState = .disconnected
        webSocketTask = nil
        pingTimer?.invalidate()
        pingTimer = nil

        // Attempt reconnection if not intentional
        if !isIntentionalDisconnect {
            scheduleReconnect()
        }
    }

    private func scheduleReconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectInterval, repeats: false) { [weak self] _ in
            guard let self = self, !self.isIntentionalDisconnect else { return }
            if let memberId = self.currentMemberId {
                self.connect(memberId: memberId, userType: self.currentUserType)
            }
        }
    }

    private func startPingTimer() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }

    private func sendPing() {
        let ping = WebSocketMessage(
            type: "ping",
            data: ["event": pingEventName],
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        send(ping)
    }

    private func send(_ message: WebSocketMessage) {
        guard let webSocketTask = webSocketTask else { return }

        do {
            let data = try JSONEncoder().encode(message)
            let string = String(data: data, encoding: .utf8) ?? ""
            webSocketTask.send(.string(string)) { [weak self] error in
                if let error = error {
                    self?.handleError(error)
                }
            }
        } catch {
            print("WebSocket encode error: \(error)")
        }
    }
}

// MARK: - Connection State

public enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed(Error)

    public static func == (lhs: ConnectionState, rhs: ConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected),
             (.connecting, .connecting),
             (.connected, .connected),
             (.reconnecting, .reconnecting):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// MARK: - Message Structures

public struct WebSocketMessage: Codable {
    public let type: String
    public let data: [String: AnyCodable]
    public let timestamp: Int64

    public init(type: String, data: [String: Any], timestamp: Int64) {
        self.type = type
        self.data = data.mapValues { AnyCodable($0) }
        self.timestamp = timestamp
    }
}

public struct AnyCodable: Codable {
    public let value: Any

    public init(_ value: Any) { self.value = value }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) { value = intVal }
        else if let doubleVal = try? container.decode(Double.self) { value = doubleVal }
        else if let stringVal = try? container.decode(String.self) { value = stringVal }
        else if let boolVal = try? container.decode(Bool.self) { value = boolVal }
        else if let arrayVal = try? container.decode([AnyCodable].self) { value = arrayVal.map { $0.value } }
        else if let dictVal = try? container.decode([String: AnyCodable].self) { value = dictVal.mapValues { $0.value } }
        else { value = NSNull() }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intVal as Int: try container.encode(intVal)
        case let doubleVal as Double: try container.encode(doubleVal)
        case let stringVal as String: try container.encode(stringVal)
        case let boolVal as Bool: try container.encode(boolVal)
        case let arrayVal as [Any]: try container.encode(arrayVal.map { AnyCodable($0) })
        case let dictVal as [String: Any]: try container.encode(dictVal.mapValues { AnyCodable($0) })
        default: try container.encodeNil()
        }
    }
}

public struct WebSocketRawMessage {
    public let type: String
    public let payload: [String: Any]
}

// MARK: - Event Models (matching original app's event types)

/// Member-specific events (MEMBER_EVENT channel)
public struct MemberEvent {
    public let event: String
    public let data: [String: Any]
    public let channel: String

    public static func from(channel: String, event: String, data: [String: Any]) -> MemberEvent? {
        return MemberEvent(event: event, data: data, channel: channel)
    }
}

/// Service request status updates (SERVICE_REQUEST_STATUS channel)
public struct ServiceRequestUpdate {
    public let requestId: String
    public let status: String
    public let event: String
    public let data: [String: Any]
    public let channel: String

    public static func from(channel: String, event: String, data: [String: Any]) -> ServiceRequestUpdate? {
        guard let requestId = data["requestId"] as? String ?? data["iRefRequestId"] as? String else { return nil }
        return ServiceRequestUpdate(
            requestId: requestId,
            status: data["status"] as? String ?? data["vStatus"] as? String ?? "",
            event: event,
            data: data,
            channel: channel
        )
    }
}

/// Order/delivery tracking updates (TRACKING_SERVICE channel)
public struct TrackingUpdate {
    public let orderId: String
    public let stage: TrackingStage
    public let event: String
    public let courierId: String?
    public let courierNameAr: String?
    public let courierNameEn: String?
    public let courierPhone: String?
    public let latitude: Double?
    public let longitude: Double?
    public let estimatedArrivalMinutes: Int?
    public let data: [String: Any]
    public let channel: String

    public static func from(channel: String, event: String, data: [String: Any]) -> TrackingUpdate? {
        guard let orderId = data["orderId"] as? String ?? data["iRefOrderId"] as? String,
              let stageRaw = data["stage"] as? String ?? data["vStage"] as? String,
              let stage = TrackingStage(rawValue: stageRaw) else { return nil }

        return TrackingUpdate(
            orderId: orderId,
            stage: stage,
            event: event,
            courierId: data["courierId"] as? String,
            courierNameAr: data["courierNameAr"] as? String,
            courierNameEn: data["courierNameEn"] as? String,
            courierPhone: data["courierPhone"] as? String,
            latitude: data["latitude"] as? Double ?? data["vLatitude"] as? Double,
            longitude: data["longitude"] as? Double ?? data["vLongitude"] as? Double,
            estimatedArrivalMinutes: data["estimatedArrivalMinutes"] as? Int ?? data["iEtaMinutes"] as? Int,
            data: data,
            channel: channel
        )
    }
}

/// Chat messages (CHAT_SERVICE channel)
public struct ChatMessage {
    public let messageId: String
    public let senderId: String
    public let senderName: String
    public let text: String
    public let timestamp: Int64
    public let event: String
    public let data: [String: Any]
    public let channel: String

    public static func from(channel: String, event: String, data: [String: Any]) -> ChatMessage? {
        guard let messageId = data["messageId"] as? String ?? data["id"] as? String,
              let senderId = data["senderId"] as? String,
              let text = data["text"] as? String ?? data["message"] as? String else { return nil }

        return ChatMessage(
            messageId: messageId,
            senderId: senderId,
            senderName: data["senderName"] as? String ?? "",
            text: text,
            timestamp: data["timestamp"] as? Int64 ?? Int64(Date().timeIntervalSince1970 * 1000),
            event: event,
            data: data,
            channel: channel
        )
    }
}

/// VOIP events (VOIP_SERVICE channel)
public struct VoipEvent {
    public let callId: String
    public let callerId: String
    public let event: String // "incoming", "accepted", "rejected", "ended"
    public let data: [String: Any]
    public let channel: String

    public static func from(channel: String, event: String, data: [String: Any]) -> VoipEvent? {
        guard let callId = data["callId"] as? String ?? data["iRefCallId"] as? String else { return nil }
        return VoipEvent(
            callId: callId,
            callerId: data["callerId"] as? String ?? "",
            event: event,
            data: data,
            channel: channel
        )
    }
}

// MARK: - Legacy Event Models (for backward compatibility)

/// Order update from WebSocket
public struct OrderUpdate: Codable {
    public let orderId: String
    public let orderNumber: String
    public let status: OrderStatus
    public let stage: TrackingStage
    public let etaMinutes: Int
    public let messageAr: String?
    public let messageEn: String?

    public static func from(json: [String: Any]) -> OrderUpdate? {
        guard let orderId = json["orderId"] as? String,
              let orderNumber = json["orderNumber"] as? String,
              let statusRaw = json["status"] as? String,
              let status = OrderStatus(rawValue: statusRaw),
              let stageRaw = json["stage"] as? String,
              let stage = TrackingStage(rawValue: stageRaw),
              let etaMinutes = json["etaMinutes"] as? Int else { return nil }

        return OrderUpdate(
            orderId: orderId,
            orderNumber: orderNumber,
            status: status,
            stage: stage,
            etaMinutes: etaMinutes,
            messageAr: json["messageAr"] as? String,
            messageEn: json["messageEn"] as? String
        )
    }
}

/// Group cart update from WebSocket
public struct GroupCartUpdate: Codable {
    public let groupId: String
    public let participantId: String
    public let action: GroupCartAction
    public let item: GroupCartItem?
    public let messageAr: String?
    public let messageEn: String?

    public enum GroupCartAction: String, Codable {
        case added = "ADDED"
        case updated = "UPDATED"
        case removed = "REMOVED"
        case submitted = "SUBMITTED"
        case paid = "PAID"
    }

    public static func from(json: [String: Any]) -> GroupCartUpdate? {
        guard let groupId = json["groupId"] as? String,
              let participantId = json["participantId"] as? String,
              let actionRaw = json["action"] as? String,
              let action = GroupCartAction(rawValue: actionRaw) else { return nil }

        var item: GroupCartItem?
        if let itemData = json["item"] as? [String: Any] {
            item = GroupCartItem.from(json: itemData)
        }

        return GroupCartUpdate(
            groupId: groupId,
            participantId: participantId,
            action: action,
            item: item,
            messageAr: json["messageAr"] as? String,
            messageEn: json["messageEn"] as? String
        )
    }
}

/// Delivery tracking update from WebSocket
public struct DeliveryTrackingUpdate: Codable {
    public let orderId: String
    public let courierId: String?
    public let courierNameAr: String?
    public let courierNameEn: String?
    public let courierPhone: String?
    public let latitude: Double?
    public let longitude: Double?
    public let estimatedArrivalMinutes: Int?
    public let status: TrackingStage

    public static func from(json: [String: Any]) -> DeliveryTrackingUpdate? {
        guard let orderId = json["orderId"] as? String,
              let statusRaw = json["status"] as? String,
              let status = TrackingStage(rawValue: statusRaw) else { return nil }

        return DeliveryTrackingUpdate(
            orderId: orderId,
            courierId: json["courierId"] as? String,
            courierNameAr: json["courierNameAr"] as? String,
            courierNameEn: json["courierNameEn"] as? String,
            courierPhone: json["courierPhone"] as? String,
            latitude: json["latitude"] as? Double,
            longitude: json["longitude"] as? Double,
            estimatedArrivalMinutes: json["estimatedArrivalMinutes"] as? Int,
            status: status
        )
    }
}
