import Foundation
import Combine

/// API Client for the KOOI Customer App
/// Mirrors the Kotlin `KooiApiClient` with async/await support
@MainActor
public final class APIClient: ObservableObject {
    public static let shared = APIClient()

    private let session: URLSession
    private let baseURL: String
    private var sessionToken: String = ""
    private var userId: String = ""
    private var userType: String = "Passenger"

    // Published state for reactivity
    @Published public var isLoading: Bool = false
    @Published public var lastError: KooiAPIError?

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        self.baseURL = KooiEndpoints.baseURL
    }

    /// Sets the authentication session
    public func setSession(token: String, userId: String, userType: String = "Passenger") {
        self.sessionToken = token
        self.userId = userId
        self.userType = userType
    }

    /// Clears the authentication session
    public func clearSession() {
        self.sessionToken = ""
        self.userId = ""
        self.userType = "Passenger"
    }

    /// Generic request method
    private func request<T: Codable>(
        type: KooiEndpoints.APITypes,
        fields: [String: String] = [:],
        responseType: T.Type
    ) async throws -> T {
        isLoading = true
        defer { isLoading = false }

        var formFields = fields
        formFields[KooiEndpoints.Fields.type.rawValue] = type.rawValue

        // Add auth fields if we have a session
        if !sessionToken.isEmpty && !userId.isEmpty {
            formFields[KooiEndpoints.Fields.tSessionId.rawValue] = sessionToken
            formFields[KooiEndpoints.Fields.GeneralMemberId.rawValue] = userId
            formFields[KooiEndpoints.Fields.GeneralUserType.rawValue] = userType
        }

        let formBody = formFields.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        let bodyData = formBody.data(using: .utf8)!

        var request = URLRequest(url: URL(string: baseURL + KooiEndpoints.webserviceShark)!)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: KooiEndpoints.Headers.accept.rawValue)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: KooiEndpoints.Headers.contentType.rawValue)
        request.setValue("KOOI-iOS/1.0.0 (iOS)", forHTTPHeaderField: KooiEndpoints.Headers.userAgent.rawValue)

        if !sessionToken.isEmpty {
            request.setValue(sessionToken, forHTTPHeaderField: KooiEndpoints.Headers.xSessionToken.rawValue)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw KooiAPIError(code: "INVALID_RESPONSE", messageAr: "استجابة غير صالحة من الخادم", messageEn: "Invalid server response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw KooiAPIError(code: "HTTP_\(httpResponse.statusCode)", messageAr: "خطأ في الخادم: \(httpResponse.statusCode)", messageEn: "Server error: \(httpResponse.statusCode)")
        }

        // Parse the response
        do {
            let decoder = JSONDecoder()
            // The API wraps responses in a specific format
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            let action = json["Action"] as? String ?? "0"

            if action == "1" {
                // Success - data is in 'message' field
                let message = json["message"] as? String ?? "{}"
                let messageData = message.data(using: .utf8) ?? Data()
                let result = try decoder.decode(T.self, from: messageData)
                return result
            } else {
                // Error
                let message = json["message"] as? String ?? "Unknown error"
                let error = KooiAPIError(code: "API_ERROR", messageAr: message, messageEn: message)
                self.lastError = error
                throw error
            }
        } catch let decodingError as DecodingError {
            let error = KooiAPIError(code: "PARSE_ERROR", messageAr: "فشل تحليل الاستجابة", messageEn: "Failed to parse response: \(decodingError)")
            self.lastError = error
            throw error
        } catch let apiError as KooiAPIError {
            throw apiError
        } catch {
            let error = KooiAPIError(code: "UNKNOWN_ERROR", messageAr: "حدث خطأ غير متوقع", messageEn: error.localizedDescription)
            self.lastError = error
            throw error
        }
    }

    /// Generic request returning raw data for custom parsing
    private func requestRaw(
        type: KooiEndpoints.APITypes,
        fields: [String: String] = [:]
    ) async throws -> [String: Any] {
        isLoading = true
        defer { isLoading = false }

        var formFields = fields
        formFields[KooiEndpoints.Fields.type.rawValue] = type.rawValue

        if !sessionToken.isEmpty && !userId.isEmpty {
            formFields[KooiEndpoints.Fields.tSessionId.rawValue] = sessionToken
            formFields[KooiEndpoints.Fields.GeneralMemberId.rawValue] = userId
            formFields[KooiEndpoints.Fields.GeneralUserType.rawValue] = userType
        }

        let formBody = formFields.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        let bodyData = formBody.data(using: .utf8)!

        var request = URLRequest(url: URL(string: baseURL + KooiEndpoints.webserviceShark)!)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: KooiEndpoints.Headers.accept.rawValue)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: KooiEndpoints.Headers.contentType.rawValue)
        request.setValue("KOOI-iOS/1.0.0 (iOS)", forHTTPHeaderField: KooiEndpoints.Headers.userAgent.rawValue)

        if !sessionToken.isEmpty {
            request.setValue(sessionToken, forHTTPHeaderField: KooiEndpoints.Headers.xSessionToken.rawValue)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw KooiAPIError(code: "INVALID_RESPONSE", messageAr: "استجابة غير صالحة من الخادم", messageEn: "Invalid server response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw KooiAPIError(code: "HTTP_\(httpResponse.statusCode)", messageAr: "خطأ في الخادم: \(httpResponse.statusCode)", messageEn: "Server error: \(httpResponse.statusCode)")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        return json
    }

    // MARK: - Authentication

    public func checkMemberAccount(phone: String, code: String) async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.vPhone.rawValue: phone,
            KooiEndpoints.Fields.vCode.rawValue: code
        ]
        return try await requestRaw(type: .checkMemberAccount, fields: fields)
    }

    public func authenticateMember(phone: String, code: String, password: String) async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.vPhone.rawValue: phone,
            KooiEndpoints.Fields.vCode.rawValue: code,
            KooiEndpoints.Fields.vPassword.rawValue: password
        ]
        return try await requestRaw(type: .authenticateMember, fields: fields)
    }

    public func sendAuthOtp(phone: String, code: String, userType: String = "Passenger") async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.vPhone.rawValue: phone,
            KooiEndpoints.Fields.vCode.rawValue: code,
            KooiEndpoints.Fields.vUserType.rawValue: userType
        ]
        return try await requestRaw(type: .sendAuthOtp, fields: fields)
    }

    public func signIn(phone: String, code: String, password: String, deviceToken: String = "", deviceType: String = "iOS", appVersion: String = "1.0.0") async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.vPhone.rawValue: phone,
            KooiEndpoints.Fields.vCode.rawValue: code,
            KooiEndpoints.Fields.vPassword.rawValue: password,
            KooiEndpoints.Fields.vUserType.rawValue: "Passenger",
            KooiEndpoints.Fields.vDeviceToken.rawValue: deviceToken,
            KooiEndpoints.Fields.vDeviceType.rawValue: deviceType,
            KooiEndpoints.Fields.vAppVersion.rawValue: appVersion
        ]
        return try await requestRaw(type: .signIn, fields: fields)
    }

    public func signUp(phone: String, code: String, password: String, name: String, email: String, deviceToken: String = "", deviceType: String = "iOS", appVersion: String = "1.0.0") async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.vPhone.rawValue: phone,
            KooiEndpoints.Fields.vCode.rawValue: code,
            KooiEndpoints.Fields.vPassword.rawValue: password,
            KooiEndpoints.Fields.vName.rawValue: name,
            KooiEndpoints.Fields.vEmail.rawValue: email,
            KooiEndpoints.Fields.vUserType.rawValue: "Passenger",
            KooiEndpoints.Fields.vDeviceToken.rawValue: deviceToken,
            KooiEndpoints.Fields.vDeviceType.rawValue: deviceType,
            KooiEndpoints.Fields.vAppVersion.rawValue: appVersion
        ]
        return try await requestRaw(type: .signUp, fields: fields)
    }

    public func forgotPassword(phone: String, code: String) async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.vPhone.rawValue: phone,
            KooiEndpoints.Fields.vCode.rawValue: code
        ]
        return try await requestRaw(type: .forgotPassword, fields: fields)
    }

    public func resetPassword(phone: String, code: String, otp: String, password: String) async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.vPhone.rawValue: phone,
            KooiEndpoints.Fields.vCode.rawValue: code,
            KooiEndpoints.Fields.vOtp.rawValue: otp,
            KooiEndpoints.Fields.vPassword.rawValue: password
        ]
        return try await requestRaw(type: .resetPassword, fields: fields)
    }

    public func verifyOtp(phone: String, code: String, otp: String) async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.vPhone.rawValue: phone,
            KooiEndpoints.Fields.vCode.rawValue: code,
            KooiEndpoints.Fields.vOtp.rawValue: otp
        ]
        return try await requestRaw(type: .verifyOtp, fields: fields)
    }

    // MARK: - Profile

    public func loadProfile(userId: String, sessionToken: String) async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.iRefUserId.rawValue: userId,
            KooiEndpoints.Fields.vSessionToken.rawValue: sessionToken
        ]
        return try await requestRaw(type: .loadProfile, fields: fields)
    }

    public func updateProfile(userId: String, sessionToken: String, nameAr: String?, nameEn: String?, email: String?, lang: String?) async throws -> [String: Any] {
        var fields: [String: String] = [
            KooiEndpoints.Fields.iRefUserId.rawValue: userId,
            KooiEndpoints.Fields.vSessionToken.rawValue: sessionToken
        ]
        if let nameAr { fields[KooiEndpoints.Fields.vNameAr.rawValue] = nameAr }
        if let nameEn { fields[KooiEndpoints.Fields.vNameEn.rawValue] = nameEn }
        if let email { fields[KooiEndpoints.Fields.vEmail.rawValue] = email }
        if let lang { fields[KooiEndpoints.Fields.vLang.rawValue] = lang }
        return try await requestRaw(type: .updateProfile, fields: fields)
    }

    // MARK: - Static Config

    public func countryList() async throws -> [String: Any] {
        return try await requestRaw(type: .countryList, fields: [:])
    }

    public func loadStaticInfo(userType: String = "Passenger", appVersion: String = "1.0.0") async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.vUserType.rawValue: userType,
            KooiEndpoints.Fields.vAppVersion.rawValue: appVersion
        ]
        return try await requestRaw(type: .loadStaticInfo, fields: fields)
    }

    // MARK: - Restaurants & Menu

    public func loadAvailableRestaurants(
        latitude: String? = nil,
        longitude: String? = nil,
        userId: String? = nil,
        cuisineId: String? = nil,
        categoryId: String? = nil,
        address: String? = nil,
        lang: String? = nil,
        userType: String? = nil,
        page: Int = 0
    ) async throws -> [String: Any] {
        var fields: [String: String] = [:]
        if let latitude { fields[KooiEndpoints.Fields.PassengerLat.rawValue] = latitude }
        if let longitude { fields[KooiEndpoints.Fields.PassengerLon.rawValue] = longitude }
        if let userId { fields[KooiEndpoints.Fields.iUserId.rawValue] = userId }
        if let cuisineId { fields[KooiEndpoints.Fields.cuisineId.rawValue] = cuisineId }
        if let categoryId { fields[KooiEndpoints.Fields.iCategoryId.rawValue] = categoryId }
        if let address { fields[KooiEndpoints.Fields.vAddress.rawValue] = address }
        if let lang { fields[KooiEndpoints.Fields.vLang.rawValue] = lang }
        if let userType { fields[KooiEndpoints.Fields.UserType.rawValue] = userType }
        fields[KooiEndpoints.Fields.page.rawValue] = String(page)
        return try await requestRaw(type: .loadAvailableRestaurants, fields: fields)
    }

    public func getRestaurantDetails(restaurantId: String, sessionToken: String? = nil) async throws -> [String: Any] {
        var fields = [
            KooiEndpoints.Fields.iRefRestaurantId.rawValue: restaurantId
        ]
        if let sessionToken {
            fields[KooiEndpoints.Fields.vSessionToken.rawValue] = sessionToken
        }
        return try await requestRaw(type: .getRestaurantDetails, fields: fields)
    }

    public func getStoreDetails(storeId: String, userId: String? = nil, lang: String? = nil, system: String = "DeliverAll", checkNonVeg: String = "") async throws -> [String: Any] {
        var fields = [
            KooiEndpoints.Fields.iCompanyId.rawValue: storeId,
            KooiEndpoints.Fields.eSystem.rawValue: system,
            KooiEndpoints.Fields.CheckNonVegFoodType.rawValue: checkNonVeg
        ]
        if let userId { fields[KooiEndpoints.Fields.iUserId.rawValue] = userId }
        if let lang { fields[KooiEndpoints.Fields.vLang.rawValue] = lang }
        return try await requestRaw(type: .getStoreDetails, fields: fields)
    }

    public func getItemOptionAddonDetails(storeId: String, userId: String? = nil, system: String = "DeliverAll", menuItemId: String) async throws -> [String: Any] {
        var fields = [
            KooiEndpoints.Fields.iCompanyId.rawValue: storeId,
            KooiEndpoints.Fields.eSystem.rawValue: system,
            KooiEndpoints.Fields.iMenuItemId.rawValue: menuItemId
        ]
        if let userId { fields[KooiEndpoints.Fields.iUserId.rawValue] = userId }
        return try await requestRaw(type: .getItemOptionAddonDetails, fields: fields)
    }

    public func getMenuItems(restaurantId: String, category: String? = nil, sessionToken: String? = nil) async throws -> [String: Any] {
        var fields = [
            KooiEndpoints.Fields.iRefRestaurantId.rawValue: restaurantId
        ]
        if let category { fields[KooiEndpoints.Fields.vCategory.rawValue] = category }
        if let sessionToken { fields[KooiEndpoints.Fields.vSessionToken.rawValue] = sessionToken }
        return try await requestRaw(type: .getMenuItems, fields: fields)
    }

    // MARK: - Food Streets

    public func getFoodStreets(microZoneId: String? = nil, sessionToken: String? = nil) async throws -> [String: Any] {
        var fields: [String: String] = [:]
        if let microZoneId { fields[KooiEndpoints.Fields.vMicroZoneId.rawValue] = microZoneId }
        if let sessionToken { fields[KooiEndpoints.Fields.vSessionToken.rawValue] = sessionToken }
        return try await requestRaw(type: .getFoodStreets, fields: fields)
    }

    public func getFoodStreetDetails(streetId: String, sessionToken: String? = nil) async throws -> [String: Any] {
        var fields = [
            KooiEndpoints.Fields.iRefFoodStreetId.rawValue: streetId
        ]
        if let sessionToken { fields[KooiEndpoints.Fields.vSessionToken.rawValue] = sessionToken }
        return try await requestRaw(type: .getFoodStreetDetails, fields: fields)
    }

    // MARK: - Wallet

    public func getWalletBalance(userId: String, sessionToken: String) async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.iRefUserId.rawValue: userId,
            KooiEndpoints.Fields.vSessionToken.rawValue: sessionToken
        ]
        return try await requestRaw(type: .getWalletBalance, fields: fields)
    }

    public func getTransactionHistory(userId: String, sessionToken: String, page: Int = 1, limit: Int = 50) async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.iRefUserId.rawValue: userId,
            KooiEndpoints.Fields.vSessionToken.rawValue: sessionToken,
            KooiEndpoints.Fields.iPage.rawValue: String(page),
            KooiEndpoints.Fields.iLimit.rawValue: String(limit)
        ]
        return try await requestRaw(type: .getTransactionHistory, fields: fields)
    }

    // MARK: - Orders

    public func placeOrder(
        userId: String,
        sessionToken: String,
        cartData: String,
        fulfillmentMode: String,
        paymentMethod: String,
        addressId: String? = nil,
        scheduledSlot: String? = nil,
        appliedLoyaltyRewardId: String? = nil,
        orderingScope: String,
        participationMode: String,
        groupId: String? = nil
    ) async throws -> [String: Any] {
        var fields = [
            KooiEndpoints.Fields.iRefUserId.rawValue: userId,
            KooiEndpoints.Fields.vSessionToken.rawValue: sessionToken,
            KooiEndpoints.Fields.vCartData.rawValue: cartData,
            KooiEndpoints.Fields.vFulfillmentMode.rawValue: fulfillmentMode,
            KooiEndpoints.Fields.vPaymentMethod.rawValue: paymentMethod,
            KooiEndpoints.Fields.vOrderingScope.rawValue: orderingScope,
            KooiEndpoints.Fields.vParticipationMode.rawValue: participationMode
        ]
        if let addressId { fields[KooiEndpoints.Fields.iRefAddressId.rawValue] = addressId }
        if let scheduledSlot { fields[KooiEndpoints.Fields.vScheduledSlot.rawValue] = scheduledSlot }
        if let appliedLoyaltyRewardId { fields[KooiEndpoints.Fields.vAppliedLoyaltyRewardId.rawValue] = appliedLoyaltyRewardId }
        if let groupId { fields[KooiEndpoints.Fields.iRefGroupId.rawValue] = groupId }
        return try await requestRaw(type: .placeOrder, fields: fields)
    }

    // MARK: - Group Orders

    public func createGroupOrder(userId: String, sessionToken: String, groupData: String) async throws -> [String: Any] {
        let fields = [
            KooiEndpoints.Fields.iRefUserId.rawValue: userId,
            KooiEndpoints.Fields.vSessionToken.rawValue: sessionToken,
            KooiEndpoints.Fields.vGroupData.rawValue: groupData
        ]
        return try await requestRaw(type: .createGroupOrder, fields: fields)
    }

    // MARK: - Scheduled Offers

    public func getScheduledOfferConfig(sessionToken: String? = nil) async throws -> [String: Any] {
        var fields: [String: String] = [:]
        if let sessionToken { fields[KooiEndpoints.Fields.vSessionToken.rawValue] = sessionToken }
        return try await requestRaw(type: .getScheduledOfferConfig, fields: fields)
    }

    // MARK: - Helper for parsing restaurant feed

    public func parseRestaurantFeed(from json: [String: Any]) -> (restaurants: [[String: Any]], cuisines: [[String: Any]], totalStores: Int, nextPage: Int?) {
        let message = json["message"] as? [String: Any] ?? [:]

        // Parse restaurants
        let companyDetails = message["CompanyDetails"] as? [String: Any] ?? [:]
        let companyFoodData = companyDetails["CompanyFoodData"] as? [[String: Any]] ?? []
        let restaurants = companyFoodData

        // Parse cuisines
        let getCuisineList = message["getCuisineList"] as? [[String: Any]] ?? []
        let cuisines = getCuisineList

        // Total stores
        let totalStores = message["totalStore"] as? Int ?? json["totalStore"] as? Int ?? restaurants.count

        // Next page - check if there are more pages
        let currentPage = json["page"] as? Int ?? 0
        let nextPage = restaurants.count > 0 ? currentPage + 1 : nil

        return (restaurants, cuisines, totalStores, nextPage)
    }
}