import Foundation
import SwiftData

// MARK: - Group Order Models

/// Group status matching the Kotlin `GroupStatus`
public enum GroupStatus: String, CaseIterable, Identifiable, Codable {
    case draft = "DRAFT"
    case open = "OPEN"
    case locked = "LOCKED"
    case awaitingPayment = "AWAITING_PAYMENT"
    case readyToPlace = "READY_TO_PLACE"
    case placed = "PLACED"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
    case expired = "EXPIRED"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .draft: return "مسودة إعداد"
        case .open: return "مفتوحة للإضافة"
        case .locked: return "مقفلة للمراجعة"
        case .awaitingPayment: return "بانتظار سداد الحصص"
        case .readyToPlace: return "جاهزة للإرسال"
        case .placed: return "تم إرسال الطلب"
        case .completed: return "مكتملة"
        case .cancelled: return "ملغاة"
        case .expired: return "منتهية الصلاحية"
        }
    }

    public var labelEn: String {
        switch self {
        case .draft: return "Draft"
        case .open: return "Open for Items"
        case .locked: return "Locked"
        case .awaitingPayment: return "Awaiting Split Payments"
        case .readyToPlace: return "Ready to Place"
        case .placed: return "Order Placed"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .expired: return "Expired"
        }
    }
}

/// Group payment mode matching the Kotlin `GroupPaymentMode`
public enum GroupPaymentMode: String, CaseIterable, Identifiable, Codable {
    case organizerPays = "ORGANIZER_PAYS"
    case everyonePaysOwnShare = "EVERYONE_PAYS_OWN_SHARE"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .organizerPays: return "سأدفع عن الجميع"
        case .everyonePaysOwnShare: return "كل شخص يدفع حصته"
        }
    }

    public var labelEn: String {
        switch self {
        case .organizerPays: return "I'll pay for everyone"
        case .everyonePaysOwnShare: return "Everyone pays their own share"
        }
    }

    public var explanationAr: String {
        switch self {
        case .organizerPays: return "يختار كل مشارك وجبته في سلته الخاصة، ويدفع منظم المجموعة الفاتورة الموحدة."
        case .everyonePaysOwnShare: return "يدفع كل مشارك قيمة أطباقه وحصته من الرسوم إلكترونياً قبل إرسال الطلب الموحد."
        }
    }

    public var explanationEn: String {
        switch self {
        case .organizerPays: return "Everyone adds their own dishes; you pay one combined bill at checkout."
        case .everyonePaysOwnShare: return "Each participant pays their own allocated share electronically before placement."
        }
    }
}

/// Shared fee allocation mode matching the Kotlin `SharedFeeAllocationMode`
public enum SharedFeeAllocationMode: String, CaseIterable, Identifiable, Codable {
    case proportionalBySubtotal = "PROPORTIONAL_BY_SUBTOTAL"
    case organizerPaysFees = "ORGANIZER_PAYS_FEES"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .proportionalBySubtotal: return "توزيع نسبي حسب قيمة الطلب"
        case .organizerPaysFees: return "المنظم يتحمل رسوم التوصيل والتنسيق"
        }
    }

    public var labelEn: String {
        switch self {
        case .proportionalBySubtotal: return "Proportional to Item Subtotal"
        case .organizerPaysFees: return "Organizer Covers Shared Fees"
        }
    }
}

/// Group fee allocation mode matching the Kotlin `GroupFeeAllocationMode`
public enum GroupFeeAllocationMode: String, CaseIterable, Identifiable, Codable {
    case equalSplit = "EQUAL_SPLIT"
    case proportionalBySubtotal = "PROPORTIONAL_BY_SUBTOTAL"
    case organizerPaysFees = "ORGANIZER_PAYS_FEES"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .equalSplit: return "تقسيم متساوٍ"
        case .proportionalBySubtotal: return "نسبة حسب قيمة الطلب"
        case .organizerPaysFees: return "المنظم يتحمل الرسوم"
        }
    }

    public var labelEn: String {
        switch self {
        case .equalSplit: return "Equal Split"
        case .proportionalBySubtotal: return "Proportional by Subtotal"
        case .organizerPaysFees: return "Organizer Pays Fees"
        }
    }
}

/// Participant status matching the Kotlin `ParticipantStatus`
public enum ParticipantStatus: String, CaseIterable, Identifiable, Codable {
    case invited = "INVITED"
    case joined = "JOINED"
    case browsing = "BROWSING"
    case editing = "EDITING"
    case submitted = "SUBMITTED"
    case paymentPending = "PAYMENT_PENDING"
    case paid = "PAID"
    case left = "LEFT"
    case removed = "REMOVED"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .invited: return "مدعو"
        case .joined: return "انضم"
        case .browsing: return "يتصفح القائمة"
        case .editing: return "يعدّل سلته"
        case .submitted: return "اعتمد اختياراته"
        case .paymentPending: return "بانتظار الدفع"
        case .paid: return "تم الدفع"
        case .left: return "غادر المجموعة"
        case .removed: return "مستبعد"
        }
    }

    public var labelEn: String {
        switch self {
        case .invited: return "Invited"
        case .joined: return "Joined"
        case .browsing: return "Browsing"
        case .editing: return "Editing Basket"
        case .submitted: return "Submitted"
        case .paymentPending: return "Payment Pending"
        case .paid: return "Paid"
        case .left: return "Left"
        case .removed: return "Removed"
        }
    }
}

/// Group invitation matching the Kotlin `GroupInvitation`
@Model
public final class GroupInvitation: Codable, Identifiable {
    @Attribute(.unique) public var id: String = UUID().uuidString
    public var groupId: String
    public var token: String
    public var deepLink: String
    public var qrPayload: String
    public var expiresAtEpochMs: Int64
    public var isRevoked: Bool

    public init(
        groupId: String,
        token: String,
        deepLink: String,
        qrPayload: String,
        expiresAtEpochMs: Int64,
        isRevoked: Bool = false
    ) {
        self.groupId = groupId
        self.token = token
        self.deepLink = deepLink
        self.qrPayload = qrPayload
        self.expiresAtEpochMs = expiresAtEpochMs
        self.isRevoked = isRevoked
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, groupId, token, deepLink, qrPayload, expiresAtEpochMs, isRevoked
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        groupId = try container.decode(String.self, forKey: .groupId)
        token = try container.decode(String.self, forKey: .token)
        deepLink = try container.decode(String.self, forKey: .deepLink)
        qrPayload = try container.decode(String.self, forKey: .qrPayload)
        expiresAtEpochMs = try container.decode(Int64.self, forKey: .expiresAtEpochMs)
        isRevoked = try container.decode(Bool.self, forKey: .isRevoked)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(groupId, forKey: .groupId)
        try container.encode(token, forKey: .token)
        try container.encode(deepLink, forKey: .deepLink)
        try container.encode(qrPayload, forKey: .qrPayload)
        try container.encode(expiresAtEpochMs, forKey: .expiresAtEpochMs)
        try container.encode(isRevoked, forKey: .isRevoked)
    }
}

/// Group cart item matching the Kotlin `GroupCartItem`
@Model
public final class GroupCartItem: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var participantId: String
    public var restaurantId: String
    @Relationship public var menuItem: MenuItem
    public var quantity: Int
    public var customizationNote: String
    public var modifierExtraLyd: Int
    public var quotedUnitPriceLyd: Int
    public var quoteVersion: Int

    public init(
        id: String = UUID().uuidString,
        participantId: String,
        restaurantId: String,
        menuItem: MenuItem,
        quantity: Int,
        customizationNote: String = "",
        modifierExtraLyd: Int = 0,
        quotedUnitPriceLyd: Int? = nil,
        quoteVersion: Int = 1
    ) {
        self.id = id
        self.participantId = participantId
        self.restaurantId = restaurantId
        self.menuItem = menuItem
        self.quantity = quantity
        self.customizationNote = customizationNote
        self.modifierExtraLyd = modifierExtraLyd
        self.quotedUnitPriceLyd = quotedUnitPriceLyd ?? menuItem.priceLyd
        self.quoteVersion = quoteVersion
    }

    public var lineTotalLyd: Int {
        (quotedUnitPriceLyd + modifierExtraLyd) * quantity
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, participantId, restaurantId, menuItem, quantity,
             customizationNote, modifierExtraLyd, quotedUnitPriceLyd, quoteVersion
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        participantId = try container.decode(String.self, forKey: .participantId)
        restaurantId = try container.decode(String.self, forKey: .restaurantId)
        menuItem = try container.decode(MenuItem.self, forKey: .menuItem)
        quantity = try container.decode(Int.self, forKey: .quantity)
        customizationNote = try container.decode(String.self, forKey: .customizationNote)
        modifierExtraLyd = try container.decode(Int.self, forKey: .modifierExtraLyd)
        quotedUnitPriceLyd = try container.decode(Int.self, forKey: .quotedUnitPriceLyd)
        quoteVersion = try container.decode(Int.self, forKey: .quoteVersion)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(participantId, forKey: .participantId)
        try container.encode(restaurantId, forKey: .restaurantId)
        try container.encode(menuItem, forKey: .menuItem)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(customizationNote, forKey: .customizationNote)
        try container.encode(modifierExtraLyd, forKey: .modifierExtraLyd)
        try container.encode(quotedUnitPriceLyd, forKey: .quotedUnitPriceLyd)
        try container.encode(quoteVersion, forKey: .quoteVersion)
    }
}

/// Group participant matching the Kotlin `GroupParticipant`
@Model
public final class GroupParticipant: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var nameAr: String
    public var nameEn: String
    public var isOrganizer: Bool
    public var status: ParticipantStatus
    @Relationship(deleteRule: .cascade) public var items: [GroupCartItem]
    public var selectedPaymentMethod: PaymentMethod?
    public var paidAmountLyd: Int
    public var lastPaymentErrorAr: String?
    public var lastPaymentErrorEn: String?
    public var consentedToScheduledOfferId: String?

    public init(
        id: String = UUID().uuidString,
        nameAr: String,
        nameEn: String,
        isOrganizer: Bool = false,
        status: ParticipantStatus = .joined,
        items: [GroupCartItem] = [],
        selectedPaymentMethod: PaymentMethod? = nil,
        paidAmountLyd: Int = 0,
        lastPaymentErrorAr: String? = nil,
        lastPaymentErrorEn: String? = nil,
        consentedToScheduledOfferId: String? = nil
    ) {
        self.id = id
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.isOrganizer = isOrganizer
        self.status = status
        self.items = items
        self.selectedPaymentMethod = selectedPaymentMethod
        self.paidAmountLyd = paidAmountLyd
        self.lastPaymentErrorAr = lastPaymentErrorAr
        self.lastPaymentErrorEn = lastPaymentErrorEn
        self.consentedToScheduledOfferId = consentedToScheduledOfferId
    }

    public var itemsSubtotalLyd: Int {
        items.reduce(0) { $0 + $1.lineTotalLyd }
    }

    public var isActiveInOrder: Bool {
        status != .left && status != .removed
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, nameAr, nameEn, isOrganizer, status, items,
             selectedPaymentMethod, paidAmountLyd, lastPaymentErrorAr,
             lastPaymentErrorEn, consentedToScheduledOfferId
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        nameAr = try container.decode(String.self, forKey: .nameAr)
        nameEn = try container.decode(String.self, forKey: .nameEn)
        isOrganizer = try container.decode(Bool.self, forKey: .isOrganizer)
        status = try container.decode(ParticipantStatus.self, forKey: .status)
        items = try container.decode([GroupCartItem].self, forKey: .items)
        selectedPaymentMethod = try container.decodeIfPresent(PaymentMethod.self, forKey: .selectedPaymentMethod)
        paidAmountLyd = try container.decode(Int.self, forKey: .paidAmountLyd)
        lastPaymentErrorAr = try container.decodeIfPresent(String.self, forKey: .lastPaymentErrorAr)
        lastPaymentErrorEn = try container.decodeIfPresent(String.self, forKey: .lastPaymentErrorEn)
        consentedToScheduledOfferId = try container.decodeIfPresent(String.self, forKey: .consentedToScheduledOfferId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nameAr, forKey: .nameAr)
        try container.encode(nameEn, forKey: .nameEn)
        try container.encode(isOrganizer, forKey: .isOrganizer)
        try container.encode(status, forKey: .status)
        try container.encode(items, forKey: .items)
        try container.encodeIfPresent(selectedPaymentMethod, forKey: .selectedPaymentMethod)
        try container.encode(paidAmountLyd, forKey: .paidAmountLyd)
        try container.encodeIfPresent(lastPaymentErrorAr, forKey: .lastPaymentErrorAr)
        try container.encodeIfPresent(lastPaymentErrorEn, forKey: .lastPaymentErrorEn)
        try container.encodeIfPresent(consentedToScheduledOfferId, forKey: .consentedToScheduledOfferId)
    }
}

/// Group payment allocation matching the Kotlin `GroupPaymentAllocation`
@Model
public final class GroupPaymentAllocation: Codable, Identifiable {
    @Attribute(.unique) public var id: String = UUID().uuidString
    public var participantId: String
    public var participantNameAr: String
    public var participantNameEn: String
    public var itemsSubtotalLyd: Int
    public var allocatedSharedFeesLyd: Int
    public var allocatedDiscountLyd: Int
    public var totalDueLyd: Int
    public var isPaid: Bool

    public init(
        participantId: String,
        participantNameAr: String,
        participantNameEn: String,
        itemsSubtotalLyd: Int,
        allocatedSharedFeesLyd: Int,
        allocatedDiscountLyd: Int,
        totalDueLyd: Int,
        isPaid: Bool
    ) {
        self.participantId = participantId
        self.participantNameAr = participantNameAr
        self.participantNameEn = participantNameEn
        self.itemsSubtotalLyd = itemsSubtotalLyd
        self.allocatedSharedFeesLyd = allocatedSharedFeesLyd
        self.allocatedDiscountLyd = allocatedDiscountLyd
        self.totalDueLyd = totalDueLyd
        self.isPaid = isPaid
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, participantId, participantNameAr, participantNameEn,
             itemsSubtotalLyd, allocatedSharedFeesLyd, allocatedDiscountLyd,
             totalDueLyd, isPaid
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        participantId = try container.decode(String.self, forKey: .participantId)
        participantNameAr = try container.decode(String.self, forKey: .participantNameAr)
        participantNameEn = try container.decode(String.self, forKey: .participantNameEn)
        itemsSubtotalLyd = try container.decode(Int.self, forKey: .itemsSubtotalLyd)
        allocatedSharedFeesLyd = try container.decode(Int.self, forKey: .allocatedSharedFeesLyd)
        allocatedDiscountLyd = try container.decode(Int.self, forKey: .allocatedDiscountLyd)
        totalDueLyd = try container.decode(Int.self, forKey: .totalDueLyd)
        isPaid = try container.decode(Bool.self, forKey: .isPaid)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(participantId, forKey: .participantId)
        try container.encode(participantNameAr, forKey: .participantNameAr)
        try container.encode(participantNameEn, forKey: .participantNameEn)
        try container.encode(itemsSubtotalLyd, forKey: .itemsSubtotalLyd)
        try container.encode(allocatedSharedFeesLyd, forKey: .allocatedSharedFeesLyd)
        try container.encode(allocatedDiscountLyd, forKey: .allocatedDiscountLyd)
        try container.encode(totalDueLyd, forKey: .totalDueLyd)
        try container.encode(isPaid, forKey: .isPaid)
    }
}

/// Friend payment request matching the Kotlin `FriendPaymentRequest`
@Model
public final class FriendPaymentRequest: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var fromParticipantId: String
    public var fromParticipantNameAr: String
    public var fromParticipantNameEn: String
    public var toParticipantId: String
    public var toParticipantNameAr: String
    public var toParticipantNameEn: String
    public var amountLyd: Int
    public var status: FriendPaymentRequestStatus
    public var createdAtEpochMs: Int64

    public init(
        id: String = UUID().uuidString,
        fromParticipantId: String,
        fromParticipantNameAr: String,
        fromParticipantNameEn: String,
        toParticipantId: String,
        toParticipantNameAr: String,
        toParticipantNameEn: String,
        amountLyd: Int,
        status: FriendPaymentRequestStatus = .pending,
        createdAtEpochMs: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    ) {
        self.id = id
        self.fromParticipantId = fromParticipantId
        self.fromParticipantNameAr = fromParticipantNameAr
        self.fromParticipantNameEn = fromParticipantNameEn
        self.toParticipantId = toParticipantId
        self.toParticipantNameAr = toParticipantNameAr
        self.toParticipantNameEn = toParticipantNameEn
        self.amountLyd = amountLyd
        self.status = status
        self.createdAtEpochMs = createdAtEpochMs
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, fromParticipantId, fromParticipantNameAr, fromParticipantNameEn,
             toParticipantId, toParticipantNameAr, toParticipantNameEn,
             amountLyd, status, createdAtEpochMs
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fromParticipantId = try container.decode(String.self, forKey: .fromParticipantId)
        fromParticipantNameAr = try container.decode(String.self, forKey: .fromParticipantNameAr)
        fromParticipantNameEn = try container.decode(String.self, forKey: .fromParticipantNameEn)
        toParticipantId = try container.decode(String.self, forKey: .toParticipantId)
        toParticipantNameAr = try container.decode(String.self, forKey: .toParticipantNameAr)
        toParticipantNameEn = try container.decode(String.self, forKey: .toParticipantNameEn)
        amountLyd = try container.decode(Int.self, forKey: .amountLyd)
        status = try container.decode(FriendPaymentRequestStatus.self, forKey: .status)
        createdAtEpochMs = try container.decode(Int64.self, forKey: .createdAtEpochMs)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fromParticipantId, forKey: .fromParticipantId)
        try container.encode(fromParticipantNameAr, forKey: .fromParticipantNameAr)
        try container.encode(fromParticipantNameEn, forKey: .fromParticipantNameEn)
        try container.encode(toParticipantId, forKey: .toParticipantId)
        try container.encode(toParticipantNameAr, forKey: .toParticipantNameAr)
        try container.encode(toParticipantNameEn, forKey: .toParticipantNameEn)
        try container.encode(amountLyd, forKey: .amountLyd)
        try container.encode(status, forKey: .status)
        try container.encode(createdAtEpochMs, forKey: .createdAtEpochMs)
    }
}

/// Friend payment request status matching the Kotlin `FriendPaymentRequestStatus`
public enum FriendPaymentRequestStatus: String, CaseIterable, Codable {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case declined = "DECLINED"
    case expired = "EXPIRED"
}

/// Group activity matching the Kotlin `GroupActivity`
@Model
public final class GroupActivity: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var timestampLabelAr: String
    public var timestampLabelEn: String
    public var messageAr: String
    public var messageEn: String

    public init(
        id: String = UUID().uuidString,
        timestampLabelAr: String,
        timestampLabelEn: String,
        messageAr: String,
        messageEn: String
    ) {
        self.id = id
        self.timestampLabelAr = timestampLabelAr
        self.timestampLabelEn = timestampLabelEn
        self.messageAr = messageAr
        self.messageEn = messageEn
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, timestampLabelAr, timestampLabelEn, messageAr, messageEn
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        timestampLabelAr = try container.decode(String.self, forKey: .timestampLabelAr)
        timestampLabelEn = try container.decode(String.self, forKey: .timestampLabelEn)
        messageAr = try container.decode(String.self, forKey: .messageAr)
        messageEn = try container.decode(String.self, forKey: .messageEn)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestampLabelAr, forKey: .timestampLabelAr)
        try container.encode(timestampLabelEn, forKey: .timestampLabelEn)
        try container.encode(messageAr, forKey: .messageAr)
        try container.encode(messageEn, forKey: .messageEn)
    }
}

/// Group creation draft matching the Kotlin `GroupCreationDraft`
@Model
public final class GroupCreationDraft: Codable {
    public var stepIndex: Int
    public var paymentMode: GroupPaymentMode
    public var feeAllocationMode: SharedFeeAllocationMode
    public var orderingScope: OrderingScope
    public var singleRestaurantId: String?
    public var mrStreetId: String
    public var mrRestaurantIds: [String]
    public var fulfillmentMode: FulfillmentMode
    public var groupName: String
    public var participantLimit: Int?
    public var deadlineMinutes: Int
    public var welcomeMessage: String
    public var deliveryInstructions: String

    public init(
        stepIndex: Int = 0,
        paymentMode: GroupPaymentMode = .organizerPays,
        feeAllocationMode: SharedFeeAllocationMode = .proportionalBySubtotal,
        orderingScope: OrderingScope = .singleRestaurant,
        singleRestaurantId: String? = nil,
        mrStreetId: String = "st_gargaresh",
        mrRestaurantIds: [String] = [],
        fulfillmentMode: FulfillmentMode = .delivery,
        groupName: String = "",
        participantLimit: Int? = 6,
        deadlineMinutes: Int = 25,
        welcomeMessage: String = "",
        deliveryInstructions: String = ""
    ) {
        self.stepIndex = stepIndex
        self.paymentMode = paymentMode
        self.feeAllocationMode = feeAllocationMode
        self.orderingScope = orderingScope
        self.singleRestaurantId = singleRestaurantId
        self.mrStreetId = mrStreetId
        self.mrRestaurantIds = mrRestaurantIds
        self.fulfillmentMode = fulfillmentMode
        self.groupName = groupName
        self.participantLimit = participantLimit
        self.deadlineMinutes = deadlineMinutes
        self.welcomeMessage = welcomeMessage
        self.deliveryInstructions = deliveryInstructions
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case stepIndex, paymentMode, feeAllocationMode, orderingScope,
             singleRestaurantId, mrStreetId, mrRestaurantIds, fulfillmentMode,
             groupName, participantLimit, deadlineMinutes, welcomeMessage, deliveryInstructions
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stepIndex = try container.decode(Int.self, forKey: .stepIndex)
        paymentMode = try container.decode(GroupPaymentMode.self, forKey: .paymentMode)
        feeAllocationMode = try container.decode(SharedFeeAllocationMode.self, forKey: .feeAllocationMode)
        orderingScope = try container.decode(OrderingScope.self, forKey: .orderingScope)
        singleRestaurantId = try container.decodeIfPresent(String.self, forKey: .singleRestaurantId)
        mrStreetId = try container.decode(String.self, forKey: .mrStreetId)
        mrRestaurantIds = try container.decode([String].self, forKey: .mrRestaurantIds)
        fulfillmentMode = try container.decode(FulfillmentMode.self, forKey: .fulfillmentMode)
        groupName = try container.decode(String.self, forKey: .groupName)
        participantLimit = try container.decodeIfPresent(Int.self, forKey: .participantLimit)
        deadlineMinutes = try container.decode(Int.self, forKey: .deadlineMinutes)
        welcomeMessage = try container.decode(String.self, forKey: .welcomeMessage)
        deliveryInstructions = try container.decode(String.self, forKey: .deliveryInstructions)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stepIndex, forKey: .stepIndex)
        try container.encode(paymentMode, forKey: .paymentMode)
        try container.encode(feeAllocationMode, forKey: .feeAllocationMode)
        try container.encode(orderingScope, forKey: .orderingScope)
        try container.encodeIfPresent(singleRestaurantId, forKey: .singleRestaurantId)
        try container.encode(mrStreetId, forKey: .mrStreetId)
        try container.encode(mrRestaurantIds, forKey: .mrRestaurantIds)
        try container.encode(fulfillmentMode, forKey: .fulfillmentMode)
        try container.encode(groupName, forKey: .groupName)
        try container.encodeIfPresent(participantLimit, forKey: .participantLimit)
        try container.encode(deadlineMinutes, forKey: .deadlineMinutes)
        try container.encode(welcomeMessage, forKey: .welcomeMessage)
        try container.encode(deliveryInstructions, forKey: .deliveryInstructions)
    }
}

/// Group order matching the Kotlin `GroupOrder`
@Model
public final class GroupOrder: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var name: String
    public var organizerId: String
    public var status: GroupStatus
    public var paymentMode: GroupPaymentMode
    public var feeAllocationMode: SharedFeeAllocationMode
    public var orderingScope: OrderingScope
    public var restaurantIds: [String]
    public var mrStreetId: String?
    public var fulfillmentMode: FulfillmentMode
    public var deliveryAddress: DeliveryAddress?
    public var participantLimit: Int?
    public var deadlineMinutesRemaining: Int
    public var welcomeMessage: String
    public var deliveryInstructions: String
    public var invitation: GroupInvitation
    @Relationship(deleteRule: .cascade) public var participants: [GroupParticipant]
    public var activeViewingParticipantId: String
    public var appliedScheduledOffer: ScheduledOffer?
    public var pendingConsentOffer: ScheduledOffer?
    public var placedOrderNumber: String?
    @Relationship(deleteRule: .cascade) public var activities: [GroupActivity]

    public init(
        id: String = UUID().uuidString,
        name: String,
        organizerId: String,
        status: GroupStatus,
        paymentMode: GroupPaymentMode,
        feeAllocationMode: SharedFeeAllocationMode,
        orderingScope: OrderingScope,
        restaurantIds: [String],
        mrStreetId: String? = nil,
        fulfillmentMode: FulfillmentMode,
        deliveryAddress: DeliveryAddress? = nil,
        participantLimit: Int? = nil,
        deadlineMinutesRemaining: Int,
        welcomeMessage: String = "",
        deliveryInstructions: String = "",
        invitation: GroupInvitation,
        participants: [GroupParticipant] = [],
        activeViewingParticipantId: String,
        appliedScheduledOffer: ScheduledOffer? = nil,
        pendingConsentOffer: ScheduledOffer? = nil,
        placedOrderNumber: String? = nil,
        activities: [GroupActivity] = []
    ) {
        self.id = id
        self.name = name
        self.organizerId = organizerId
        self.status = status
        self.paymentMode = paymentMode
        self.feeAllocationMode = feeAllocationMode
        self.orderingScope = orderingScope
        self.restaurantIds = restaurantIds
        self.mrStreetId = mrStreetId
        self.fulfillmentMode = fulfillmentMode
        self.deliveryAddress = deliveryAddress
        self.participantLimit = participantLimit
        self.deadlineMinutesRemaining = deadlineMinutesRemaining
        self.welcomeMessage = welcomeMessage
        self.deliveryInstructions = deliveryInstructions
        self.invitation = invitation
        self.participants = participants
        self.activeViewingParticipantId = activeViewingParticipantId
        self.appliedScheduledOffer = appliedScheduledOffer
        self.pendingConsentOffer = pendingConsentOffer
        self.placedOrderNumber = placedOrderNumber
        self.activities = activities
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, organizerId, status, paymentMode, feeAllocationMode,
             orderingScope, restaurantIds, mrStreetId, fulfillmentMode,
             deliveryAddress, participantLimit, deadlineMinutesRemaining,
             welcomeMessage, deliveryInstructions, invitation, participants,
             activeViewingParticipantId, appliedScheduledOffer, pendingConsentOffer,
             placedOrderNumber, activities
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        organizerId = try container.decode(String.self, forKey: .organizerId)
        status = try container.decode(GroupStatus.self, forKey: .status)
        paymentMode = try container.decode(GroupPaymentMode.self, forKey: .paymentMode)
        feeAllocationMode = try container.decode(SharedFeeAllocationMode.self, forKey: .feeAllocationMode)
        orderingScope = try container.decode(OrderingScope.self, forKey: .orderingScope)
        restaurantIds = try container.decode([String].self, forKey: .restaurantIds)
        mrStreetId = try container.decodeIfPresent(String.self, forKey: .mrStreetId)
        fulfillmentMode = try container.decode(FulfillmentMode.self, forKey: .fulfillmentMode)
        deliveryAddress = try container.decodeIfPresent(DeliveryAddress.self, forKey: .deliveryAddress)
        participantLimit = try container.decodeIfPresent(Int.self, forKey: .participantLimit)
        deadlineMinutesRemaining = try container.decode(Int.self, forKey: .deadlineMinutesRemaining)
        welcomeMessage = try container.decode(String.self, forKey: .welcomeMessage)
        deliveryInstructions = try container.decode(String.self, forKey: .deliveryInstructions)
        invitation = try container.decode(GroupInvitation.self, forKey: .invitation)
        participants = try container.decode([GroupParticipant].self, forKey: .participants)
        activeViewingParticipantId = try container.decode(String.self, forKey: .activeViewingParticipantId)
        appliedScheduledOffer = try container.decodeIfPresent(ScheduledOffer.self, forKey: .appliedScheduledOffer)
        pendingConsentOffer = try container.decodeIfPresent(ScheduledOffer.self, forKey: .pendingConsentOffer)
        placedOrderNumber = try container.decodeIfPresent(String.self, forKey: .placedOrderNumber)
        activities = try container.decode([GroupActivity].self, forKey: .activities)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(organizerId, forKey: .organizerId)
        try container.encode(status, forKey: .status)
        try container.encode(paymentMode, forKey: .paymentMode)
        try container.encode(feeAllocationMode, forKey: .feeAllocationMode)
        try container.encode(orderingScope, forKey: .orderingScope)
        try container.encode(restaurantIds, forKey: .restaurantIds)
        try container.encodeIfPresent(mrStreetId, forKey: .mrStreetId)
        try container.encode(fulfillmentMode, forKey: .fulfillmentMode)
        try container.encodeIfPresent(deliveryAddress, forKey: .deliveryAddress)
        try container.encodeIfPresent(participantLimit, forKey: .participantLimit)
        try container.encode(deadlineMinutesRemaining, forKey: .deadlineMinutesRemaining)
        try container.encode(welcomeMessage, forKey: .welcomeMessage)
        try container.encode(deliveryInstructions, forKey: .deliveryInstructions)
        try container.encode(invitation, forKey: .invitation)
        try container.encode(participants, forKey: .participants)
        try container.encode(activeViewingParticipantId, forKey: .activeViewingParticipantId)
        try container.encodeIfPresent(appliedScheduledOffer, forKey: .appliedScheduledOffer)
        try container.encodeIfPresent(pendingConsentOffer, forKey: .pendingConsentOffer)
        try container.encodeIfPresent(placedOrderNumber, forKey: .placedOrderNumber)
        try container.encode(activities, forKey: .activities)
    }
}

// MARK: - Scheduled Offer Models

/// Scheduled fulfillment slot matching the Kotlin `ScheduledFulfillmentSlot`
@Model
public final class ScheduledFulfillmentSlot: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var windowLabelAr: String
    public var windowLabelEn: String
    public var availableCapacity: Int
    public var delayMinutesFromNow: Int

    public init(
        id: String = UUID().uuidString,
        windowLabelAr: String,
        windowLabelEn: String,
        availableCapacity: Int,
        delayMinutesFromNow: Int
    ) {
        self.id = id
        self.windowLabelAr = windowLabelAr
        self.windowLabelEn = windowLabelEn
        self.availableCapacity = availableCapacity
        self.delayMinutesFromNow = delayMinutesFromNow
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, windowLabelAr, windowLabelEn, availableCapacity, delayMinutesFromNow
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        windowLabelAr = try container.decode(String.self, forKey: .windowLabelAr)
        windowLabelEn = try container.decode(String.self, forKey: .windowLabelEn)
        availableCapacity = try container.decode(Int.self, forKey: .availableCapacity)
        delayMinutesFromNow = try container.decode(Int.self, forKey: .delayMinutesFromNow)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(windowLabelAr, forKey: .windowLabelAr)
        try container.encode(windowLabelEn, forKey: .windowLabelEn)
        try container.encode(availableCapacity, forKey: .availableCapacity)
        try container.encode(delayMinutesFromNow, forKey: .delayMinutesFromNow)
    }
}

/// Offer eligibility matching the Kotlin `OfferEligibility`
public struct OfferEligibility: Codable {
    public var isEligible: Bool
    public var ineligibilityReasonAr: String?
    public var ineligibilityReasonEn: String?
    public var isDemoRuleEvaluation: Bool

    public init(
        isEligible: Bool,
        ineligibilityReasonAr: String? = nil,
        ineligibilityReasonEn: String? = nil,
        isDemoRuleEvaluation: Bool = true
    ) {
        self.isEligible = isEligible
        self.ineligibilityReasonAr = ineligibilityReasonAr
        self.ineligibilityReasonEn = ineligibilityReasonEn
        self.isDemoRuleEvaluation = isDemoRuleEvaluation
    }
}

/// Scheduled offer matching the Kotlin `ScheduledOffer`
@Model
public final class ScheduledOffer: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var discountPercent: Int
    public var maxDiscountCapLyd: Int
    public var calculatedSavingsLyd: Int
    public var originalEstimateAr: String
    public var originalEstimateEn: String
    public var slot: ScheduledFulfillmentSlot
    public var applicableToLabelAr: String
    public var applicableToLabelEn: String
    public var expiresAtEpochMs: Int64
    public var expectedFinalPriceLyd: Int
    public var isDemoPeakRule: Bool

    public init(
        id: String = UUID().uuidString,
        discountPercent: Int,
        maxDiscountCapLyd: Int,
        calculatedSavingsLyd: Int,
        originalEstimateAr: String,
        originalEstimateEn: String,
        slot: ScheduledFulfillmentSlot,
        applicableToLabelAr: String,
        applicableToLabelEn: String,
        expiresAtEpochMs: Int64,
        expectedFinalPriceLyd: Int,
        isDemoPeakRule: Bool = true
    ) {
        self.id = id
        self.discountPercent = discountPercent
        self.maxDiscountCapLyd = maxDiscountCapLyd
        self.calculatedSavingsLyd = calculatedSavingsLyd
        self.originalEstimateAr = originalEstimateAr
        self.originalEstimateEn = originalEstimateEn
        self.slot = slot
        self.applicableToLabelAr = applicableToLabelAr
        self.applicableToLabelEn = applicableToLabelEn
        self.expiresAtEpochMs = expiresAtEpochMs
        self.expectedFinalPriceLyd = expectedFinalPriceLyd
        self.isDemoPeakRule = isDemoPeakRule
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, discountPercent, maxDiscountCapLyd, calculatedSavingsLyd,
             originalEstimateAr, originalEstimateEn, slot, applicableToLabelAr,
             applicableToLabelEn, expiresAtEpochMs, expectedFinalPriceLyd, isDemoPeakRule
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        discountPercent = try container.decode(Int.self, forKey: .discountPercent)
        maxDiscountCapLyd = try container.decode(Int.self, forKey: .maxDiscountCapLyd)
        calculatedSavingsLyd = try container.decode(Int.self, forKey: .calculatedSavingsLyd)
        originalEstimateAr = try container.decode(String.self, forKey: .originalEstimateAr)
        originalEstimateEn = try container.decode(String.self, forKey: .originalEstimateEn)
        slot = try container.decode(ScheduledFulfillmentSlot.self, forKey: .slot)
        applicableToLabelAr = try container.decode(String.self, forKey: .applicableToLabelAr)
        applicableToLabelEn = try container.decode(String.self, forKey: .applicableToLabelEn)
        expiresAtEpochMs = try container.decode(Int64.self, forKey: .expiresAtEpochMs)
        expectedFinalPriceLyd = try container.decode(Int.self, forKey: .expectedFinalPriceLyd)
        isDemoPeakRule = try container.decode(Bool.self, forKey: .isDemoPeakRule)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(discountPercent, forKey: .discountPercent)
        try container.encode(maxDiscountCapLyd, forKey: .maxDiscountCapLyd)
        try container.encode(calculatedSavingsLyd, forKey: .calculatedSavingsLyd)
        try container.encode(originalEstimateAr, forKey: .originalEstimateAr)
        try container.encode(originalEstimateEn, forKey: .originalEstimateEn)
        try container.encode(slot, forKey: .slot)
        try container.encode(applicableToLabelAr, forKey: .applicableToLabelAr)
        try container.encode(applicableToLabelEn, forKey: .applicableToLabelEn)
        try container.encode(expiresAtEpochMs, forKey: .expiresAtEpochMs)
        try container.encode(expectedFinalPriceLyd, forKey: .expectedFinalPriceLyd)
        try container.encode(isDemoPeakRule, forKey: .isDemoPeakRule)
    }
}

/// Offer acceptance state matching the Kotlin `OfferAcceptanceState`
public enum OfferAcceptanceState: String, CaseIterable, Codable {
    case notShown = "NOT_SHOWN"
    case presented = "PRESENTED"
    case accepted = "ACCEPTED"
    case declined = "DECLINED"
    case expired = "EXPIRED"
}

/// Scheduled offer config matching the Kotlin `ScheduledOfferConfig`
public struct ScheduledOfferConfig: Codable {
    public var enabled: Bool
    public var minOrderLyd: Int
    public var maxDiscountLyd: Int
    public var discountPercent: Int
    public var offPeakWindows: [OffPeakWindow]
    public var excludedRestaurantIds: [String]

    public init(
        enabled: Bool = true,
        minOrderLyd: Int = 30,
        maxDiscountLyd: Int = 15,
        discountPercent: Int = 20,
        offPeakWindows: [OffPeakWindow] = [],
        excludedRestaurantIds: [String] = []
    ) {
        self.enabled = enabled
        self.minOrderLyd = minOrderLyd
        self.maxDiscountLyd = maxDiscountLyd
        self.discountPercent = discountPercent
        self.offPeakWindows = offPeakWindows
        self.excludedRestaurantIds = excludedRestaurantIds
    }
}

/// Off-peak window matching the Kotlin `ApiOffPeakWindow`
@Model
public final class OffPeakWindow: Codable, Identifiable {
    @Attribute(.unique) public var id: String = UUID().uuidString
    public var startHour: Int
    public var endHour: Int
    public var daysOfWeek: [Int]

    public init(
        startHour: Int,
        endHour: Int,
        daysOfWeek: [Int]
    ) {
        self.startHour = startHour
        self.endHour = endHour
        self.daysOfWeek = daysOfWeek
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, startHour, endHour, daysOfWeek
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        startHour = try container.decode(Int.self, forKey: .startHour)
        endHour = try container.decode(Int.self, forKey: .endHour)
        daysOfWeek = try container.decode([Int].self, forKey: .daysOfWeek)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startHour, forKey: .startHour)
        try container.encode(endHour, forKey: .endHour)
        try container.encode(daysOfWeek, forKey: .daysOfWeek)
    }
}