import Foundation
import SwiftData

// MARK: - Loyalty Models

/// Loyalty filter matching the Kotlin `LoyaltyFilter`
public enum LoyaltyFilter: String, CaseIterable, Identifiable, Codable {
    case all = "ALL"
    case active = "ACTIVE"
    case almostComplete = "ALMOST_COMPLETE"
    case readyToRedeem = "READY_TO_REDEEM"
    case expiringSoon = "EXPIRING_SOON"
    case redeemed = "REDEEMED"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .all: return "الكل"
        case .active: return "نشطة"
        case .almostComplete: return "قاربت الاكتمال"
        case .readyToRedeem: return "جاهزة للاستبدال"
        case .expiringSoon: return "تنتهي قريباً"
        case .redeemed: return "تم استبدالها"
        }
    }

    public var labelEn: String {
        switch self {
        case .all: return "All"
        case .active: return "Active"
        case .almostComplete: return "Almost Complete"
        case .readyToRedeem: return "Ready to Redeem"
        case .expiringSoon: return "Expiring Soon"
        case .redeemed: return "Redeemed"
        }
    }
}

/// Loyalty category matching the Kotlin `LoyaltyCategory`
@Model
public final class LoyaltyCategory: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var labelAr: String
    public var labelEn: String
    public var assetKey: String
    public var placeholderArt: DishArtType

    public init(
        id: String,
        labelAr: String,
        labelEn: String,
        assetKey: String,
        placeholderArt: DishArtType
    ) {
        self.id = id
        self.labelAr = labelAr
        self.labelEn = labelEn
        self.assetKey = assetKey
        self.placeholderArt = placeholderArt
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, labelAr, labelEn, assetKey, placeholderArt
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        labelAr = try container.decode(String.self, forKey: .labelAr)
        labelEn = try container.decode(String.self, forKey: .labelEn)
        assetKey = try container.decode(String.self, forKey: .assetKey)
        placeholderArt = try container.decode(DishArtType.self, forKey: .placeholderArt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(labelAr, forKey: .labelAr)
        try container.encode(labelEn, forKey: .labelEn)
        try container.encode(assetKey, forKey: .assetKey)
        try container.encode(placeholderArt, forKey: .placeholderArt)
    }
}

/// Loyalty rule type matching the Kotlin `LoyaltyRuleType`
public enum LoyaltyRuleType: String, CaseIterable, Codable {
    case stampsPerOrder = "STAMPS_PER_ORDER"
    case pointsPerSpend = "POINTS_PER_SPEND"
}

/// Loyalty program matching the Kotlin `LoyaltyProgram`
@Model
public final class LoyaltyProgram: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var isKooiWideMembership: Bool
    public var restaurantId: String?
    public var titleAr: String
    public var titleEn: String
    public var category: LoyaltyCategory?
    public var categoryId: String
    public var ruleType: LoyaltyRuleType
    public var targetUnits: Int
    public var minQualifyingOrderLyd: Int
    public var pointsPerLyd: Int
    public var rewardTitleAr: String
    public var rewardTitleEn: String
    public var rewardValueLyd: Int
    public var expiryDaysRemaining: Int?

    public init(
        id: String,
        isKooiWideMembership: Bool,
        restaurantId: String?,
        titleAr: String,
        titleEn: String,
        category: LoyaltyCategory? = nil,
        categoryId: String,
        ruleType: LoyaltyRuleType,
        targetUnits: Int,
        minQualifyingOrderLyd: Int,
        pointsPerLyd: Int = 1,
        rewardTitleAr: String,
        rewardTitleEn: String,
        rewardValueLyd: Int,
        expiryDaysRemaining: Int? = nil
    ) {
        self.id = id
        self.isKooiWideMembership = isKooiWideMembership
        self.restaurantId = restaurantId
        self.titleAr = titleAr
        self.titleEn = titleEn
        self.category = category
        self.categoryId = categoryId
        self.ruleType = ruleType
        self.targetUnits = targetUnits
        self.minQualifyingOrderLyd = minQualifyingOrderLyd
        self.pointsPerLyd = pointsPerLyd
        self.rewardTitleAr = rewardTitleAr
        self.rewardTitleEn = rewardTitleEn
        self.rewardValueLyd = rewardValueLyd
        self.expiryDaysRemaining = expiryDaysRemaining
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, isKooiWideMembership, restaurantId, titleAr, titleEn,
             category, categoryId, ruleType, targetUnits, minQualifyingOrderLyd,
             pointsPerLyd, rewardTitleAr, rewardTitleEn, rewardValueLyd, expiryDaysRemaining
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        isKooiWideMembership = try container.decode(Bool.self, forKey: .isKooiWideMembership)
        restaurantId = try container.decodeIfPresent(String.self, forKey: .restaurantId)
        titleAr = try container.decode(String.self, forKey: .titleAr)
        titleEn = try container.decode(String.self, forKey: .titleEn)
        category = try container.decodeIfPresent(LoyaltyCategory.self, forKey: .category)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        ruleType = try container.decode(LoyaltyRuleType.self, forKey: .ruleType)
        targetUnits = try container.decode(Int.self, forKey: .targetUnits)
        minQualifyingOrderLyd = try container.decode(Int.self, forKey: .minQualifyingOrderLyd)
        pointsPerLyd = try container.decode(Int.self, forKey: .pointsPerLyd)
        rewardTitleAr = try container.decode(String.self, forKey: .rewardTitleAr)
        rewardTitleEn = try container.decode(String.self, forKey: .rewardTitleEn)
        rewardValueLyd = try container.decode(Int.self, forKey: .rewardValueLyd)
        expiryDaysRemaining = try container.decodeIfPresent(Int.self, forKey: .expiryDaysRemaining)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isKooiWideMembership, forKey: .isKooiWideMembership)
        try container.encodeIfPresent(restaurantId, forKey: .restaurantId)
        try container.encode(titleAr, forKey: .titleAr)
        try container.encode(titleEn, forKey: .titleEn)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(ruleType, forKey: .ruleType)
        try container.encode(targetUnits, forKey: .targetUnits)
        try container.encode(minQualifyingOrderLyd, forKey: .minQualifyingOrderLyd)
        try container.encode(pointsPerLyd, forKey: .pointsPerLyd)
        try container.encode(rewardTitleAr, forKey: .rewardTitleAr)
        try container.encode(rewardTitleEn, forKey: .rewardTitleEn)
        try container.encode(rewardValueLyd, forKey: .rewardValueLyd)
        try container.encodeIfPresent(expiryDaysRemaining, forKey: .expiryDaysRemaining)
    }
}

/// Loyalty card matching the Kotlin `LoyaltyCard`
@Model
public final class LoyaltyCard: Codable, Identifiable {
    @Attribute(.unique) public var id: String = UUID().uuidString
    @Relationship public var program: LoyaltyProgram
    public var currentUnits: Int
    public var redeemedCount: Int
    public var availableRewardsCount: Int
    public var creditedOrderIds: Set<String>

    public init(
        program: LoyaltyProgram,
        currentUnits: Int,
        redeemedCount: Int = 0,
        availableRewardsCount: Int = 0,
        creditedOrderIds: Set<String> = []
    ) {
        self.program = program
        self.currentUnits = currentUnits
        self.redeemedCount = redeemedCount
        self.availableRewardsCount = availableRewardsCount
        self.creditedOrderIds = creditedOrderIds
    }

    public var remainingUnits: Int {
        max(program.targetUnits - currentUnits, 0)
    }

    public var isReadyToRedeem: Bool {
        availableRewardsCount > 0 || currentUnits >= program.targetUnits
    }

    public var isAlmostComplete: Bool {
        !isReadyToRedeem && currentUnits > 0 && remainingUnits <= 1
    }

    public var isExpiringSoon: Bool {
        guard let expiry = program.expiryDaysRemaining, expiry <= 5 else { return false }
        return currentUnits > 0 || isReadyToRedeem
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, program, currentUnits, redeemedCount, availableRewardsCount, creditedOrderIds
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        program = try container.decode(LoyaltyProgram.self, forKey: .program)
        currentUnits = try container.decode(Int.self, forKey: .currentUnits)
        redeemedCount = try container.decode(Int.self, forKey: .redeemedCount)
        availableRewardsCount = try container.decode(Int.self, forKey: .availableRewardsCount)
        creditedOrderIds = try container.decode(Set<String>.self, forKey: .creditedOrderIds)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(program, forKey: .program)
        try container.encode(currentUnits, forKey: .currentUnits)
        try container.encode(redeemedCount, forKey: .redeemedCount)
        try container.encode(availableRewardsCount, forKey: .availableRewardsCount)
        try container.encode(creditedOrderIds, forKey: .creditedOrderIds)
    }
}

/// Loyalty reward matching the Kotlin `LoyaltyReward`
@Model
public final class LoyaltyReward: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var programId: String
    public var restaurantId: String?
    public var titleAr: String
    public var titleEn: String
    public var discountValueLyd: Int
    public var isRedeemed: Bool

    public init(
        id: String = UUID().uuidString,
        programId: String,
        restaurantId: String?,
        titleAr: String,
        titleEn: String,
        discountValueLyd: Int,
        isRedeemed: Bool = false
    ) {
        self.id = id
        self.programId = programId
        self.restaurantId = restaurantId
        self.titleAr = titleAr
        self.titleEn = titleEn
        self.discountValueLyd = discountValueLyd
        self.isRedeemed = isRedeemed
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, programId, restaurantId, titleAr, titleEn, discountValueLyd, isRedeemed
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        programId = try container.decode(String.self, forKey: .programId)
        restaurantId = try container.decodeIfPresent(String.self, forKey: .restaurantId)
        titleAr = try container.decode(String.self, forKey: .titleAr)
        titleEn = try container.decode(String.self, forKey: .titleEn)
        discountValueLyd = try container.decode(Int.self, forKey: .discountValueLyd)
        isRedeemed = try container.decode(Bool.self, forKey: .isRedeemed)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(programId, forKey: .programId)
        try container.encodeIfPresent(restaurantId, forKey: .restaurantId)
        try container.encode(titleAr, forKey: .titleAr)
        try container.encode(titleEn, forKey: .titleEn)
        try container.encode(discountValueLyd, forKey: .discountValueLyd)
        try container.encode(isRedeemed, forKey: .isRedeemed)
    }
}

/// Loyalty transaction matching the Kotlin `LoyaltyTransaction`
@Model
public final class LoyaltyTransaction: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var programId: String
    public var orderNumber: String?
    public var titleAr: String
    public var titleEn: String
    public var deltaDescriptionAr: String
    public var deltaDescriptionEn: String
    public var timestampLabelAr: String
    public var timestampLabelEn: String
    public var isReversal: Bool

    public init(
        id: String = UUID().uuidString,
        programId: String,
        orderNumber: String? = nil,
        titleAr: String,
        titleEn: String,
        deltaDescriptionAr: String,
        deltaDescriptionEn: String,
        timestampLabelAr: String,
        timestampLabelEn: String,
        isReversal: Bool = false
    ) {
        self.id = id
        self.programId = programId
        self.orderNumber = orderNumber
        self.titleAr = titleAr
        self.titleEn = titleEn
        self.deltaDescriptionAr = deltaDescriptionAr
        self.deltaDescriptionEn = deltaDescriptionEn
        self.timestampLabelAr = timestampLabelAr
        self.timestampLabelEn = timestampLabelEn
        self.isReversal = isReversal
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, programId, orderNumber, titleAr, titleEn,
             deltaDescriptionAr, deltaDescriptionEn,
             timestampLabelAr, timestampLabelEn, isReversal
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        programId = try container.decode(String.self, forKey: .programId)
        orderNumber = try container.decodeIfPresent(String.self, forKey: .orderNumber)
        titleAr = try container.decode(String.self, forKey: .titleAr)
        titleEn = try container.decode(String.self, forKey: .titleEn)
        deltaDescriptionAr = try container.decode(String.self, forKey: .deltaDescriptionAr)
        deltaDescriptionEn = try container.decode(String.self, forKey: .deltaDescriptionEn)
        timestampLabelAr = try container.decode(String.self, forKey: .timestampLabelAr)
        timestampLabelEn = try container.decode(String.self, forKey: .timestampLabelEn)
        isReversal = try container.decode(Bool.self, forKey: .isReversal)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(programId, forKey: .programId)
        try container.encodeIfPresent(orderNumber, forKey: .orderNumber)
        try container.encode(titleAr, forKey: .titleAr)
        try container.encode(titleEn, forKey: .titleEn)
        try container.encode(deltaDescriptionAr, forKey: .deltaDescriptionAr)
        try container.encode(deltaDescriptionEn, forKey: .deltaDescriptionEn)
        try container.encode(timestampLabelAr, forKey: .timestampLabelAr)
        try container.encode(timestampLabelEn, forKey: .timestampLabelEn)
        try container.encode(isReversal, forKey: .isReversal)
    }
}

/// Redemption matching the Kotlin `Redemption`
@Model
public final class Redemption: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var programId: String
    public var rewardTitleAr: String
    public var rewardTitleEn: String
    public var valueLyd: Int
    public var redeemedAtLabelAr: String
    public var redeemedAtLabelEn: String

    public init(
        id: String = UUID().uuidString,
        programId: String,
        rewardTitleAr: String,
        rewardTitleEn: String,
        valueLyd: Int,
        redeemedAtLabelAr: String,
        redeemedAtLabelEn: String
    ) {
        self.id = id
        self.programId = programId
        self.rewardTitleAr = rewardTitleAr
        self.rewardTitleEn = rewardTitleEn
        self.valueLyd = valueLyd
        self.redeemedAtLabelAr = redeemedAtLabelAr
        self.redeemedAtLabelEn = redeemedAtLabelEn
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, programId, rewardTitleAr, rewardTitleEn, valueLyd, redeemedAtLabelAr, redeemedAtLabelEn
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        programId = try container.decode(String.self, forKey: .programId)
        rewardTitleAr = try container.decode(String.self, forKey: .rewardTitleAr)
        rewardTitleEn = try container.decode(String.self, forKey: .rewardTitleEn)
        valueLyd = try container.decode(Int.self, forKey: .valueLyd)
        redeemedAtLabelAr = try container.decode(String.self, forKey: .redeemedAtLabelAr)
        redeemedAtLabelEn = try container.decode(String.self, forKey: .redeemedAtLabelEn)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(programId, forKey: .programId)
        try container.encode(rewardTitleAr, forKey: .rewardTitleAr)
        try container.encode(rewardTitleEn, forKey: .rewardTitleEn)
        try container.encode(valueLyd, forKey: .valueLyd)
        try container.encode(redeemedAtLabelAr, forKey: .redeemedAtLabelAr)
        try container.encode(redeemedAtLabelEn, forKey: .redeemedAtLabelEn)
    }
}

// MARK: - Wallet Models

/// Transfer status matching the Kotlin `TransferStatus`
public enum TransferStatus: String, CaseIterable, Codable {
    case completed = "COMPLETED"
    case failed = "FAILED"

    public var labelAr: String {
        switch self {
        case .completed: return "مكتملة (محاكاة)"
        case .failed: return "فشلت"
        }
    }

    public var labelEn: String {
        switch self {
        case .completed: return "Completed (Simulated)"
        case .failed: return "Failed"
        }
    }
}

/// Money request status matching the Kotlin `MoneyRequestStatus`
public enum MoneyRequestStatus: String, CaseIterable, Codable {
    case pending = "PENDING"
    case paid = "PAID"
    case declined = "DECLINED"
    case cancelled = "CANCELLED"
    case expired = "EXPIRED"

    public var labelAr: String {
        switch self {
        case .pending: return "قيد الانتظار"
        case .paid: return "تم السداد"
        case .declined: return "مرفوض"
        case .cancelled: return "ملغي"
        case .expired: return "منتهي الصلاحية"
        }
    }

    public var labelEn: String {
        switch self {
        case .pending: return "Pending"
        case .paid: return "Paid"
        case .declined: return "Declined"
        case .cancelled: return "Cancelled"
        case .expired: return "Expired"
        }
    }
}

/// Wallet contact matching the Kotlin `WalletContact`
@Model
public final class WalletContact: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var nameAr: String
    public var nameEn: String
    public var handle: String
    public var avatarInitials: String
    public var balanceLyd: Int
    public var publicReceiveToken: String

    public init(
        id: String = UUID().uuidString,
        nameAr: String,
        nameEn: String,
        handle: String,
        avatarInitials: String,
        balanceLyd: Int = 90,
        publicReceiveToken: String
    ) {
        self.id = id
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.handle = handle
        self.avatarInitials = avatarInitials
        self.balanceLyd = balanceLyd
        self.publicReceiveToken = publicReceiveToken
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, nameAr, nameEn, handle, avatarInitials, balanceLyd, publicReceiveToken
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        nameAr = try container.decode(String.self, forKey: .nameAr)
        nameEn = try container.decode(String.self, forKey: .nameEn)
        handle = try container.decode(String.self, forKey: .handle)
        avatarInitials = try container.decode(String.self, forKey: .avatarInitials)
        balanceLyd = try container.decode(Int.self, forKey: .balanceLyd)
        publicReceiveToken = try container.decode(String.self, forKey: .publicReceiveToken)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nameAr, forKey: .nameAr)
        try container.encode(nameEn, forKey: .nameEn)
        try container.encode(handle, forKey: .handle)
        try container.encode(avatarInitials, forKey: .avatarInitials)
        try container.encode(balanceLyd, forKey: .balanceLyd)
        try container.encode(publicReceiveToken, forKey: .publicReceiveToken)
    }
}

/// Payment request token matching the Kotlin `PaymentRequestToken`
@Model
public final class PaymentRequestToken: Codable, Identifiable {
    @Attribute(.unique) public var id: String = UUID().uuidString
    public var token: String
    public var requestId: String
    public var shareableLink: String
    public var qrPayload: String
    public var expiresAtEpochMs: Int64
    public var isRevoked: Bool

    public init(
        token: String,
        requestId: String,
        shareableLink: String,
        qrPayload: String,
        expiresAtEpochMs: Int64,
        isRevoked: Bool = false
    ) {
        self.token = token
        self.requestId = requestId
        self.shareableLink = shareableLink
        self.qrPayload = qrPayload
        self.expiresAtEpochMs = expiresAtEpochMs
        self.isRevoked = isRevoked
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, token, requestId, shareableLink, qrPayload, expiresAtEpochMs, isRevoked
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        token = try container.decode(String.self, forKey: .token)
        requestId = try container.decode(String.self, forKey: .requestId)
        shareableLink = try container.decode(String.self, forKey: .shareableLink)
        qrPayload = try container.decode(String.self, forKey: .qrPayload)
        expiresAtEpochMs = try container.decode(Int64.self, forKey: .expiresAtEpochMs)
        isRevoked = try container.decode(Bool.self, forKey: .isRevoked)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(token, forKey: .token)
        try container.encode(requestId, forKey: .requestId)
        try container.encode(shareableLink, forKey: .shareableLink)
        try container.encode(qrPayload, forKey: .qrPayload)
        try container.encode(expiresAtEpochMs, forKey: .expiresAtEpochMs)
        try container.encode(isRevoked, forKey: .isRevoked)
    }
}

/// Wallet transaction matching the Kotlin `WalletTransaction`
@Model
public final class WalletTransaction: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var referenceCode: String
    public var titleAr: String
    public var titleEn: String
    public var timeAr: String
    public var timeEn: String
    public var amountLyd: Int
    public var isCredit: Bool
    public var status: TransferStatus
    public var isSimulatedDemo: Bool

    public init(
        id: String = UUID().uuidString,
        referenceCode: String,
        titleAr: String,
        titleEn: String,
        timeAr: String,
        timeEn: String,
        amountLyd: Int,
        isCredit: Bool,
        status: TransferStatus = .completed,
        isSimulatedDemo: Bool = true
    ) {
        self.id = id
        self.referenceCode = referenceCode
        self.titleAr = titleAr
        self.titleEn = titleEn
        self.timeAr = timeAr
        self.timeEn = timeEn
        self.amountLyd = amountLyd
        self.isCredit = isCredit
        self.status = status
        self.isSimulatedDemo = isSimulatedDemo
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, referenceCode, titleAr, titleEn, timeAr, timeEn, amountLyd, isCredit, status, isSimulatedDemo
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        referenceCode = try container.decode(String.self, forKey: .referenceCode)
        titleAr = try container.decode(String.self, forKey: .titleAr)
        titleEn = try container.decode(String.self, forKey: .titleEn)
        timeAr = try container.decode(String.self, forKey: .timeAr)
        timeEn = try container.decode(String.self, forKey: .timeEn)
        amountLyd = try container.decode(Int.self, forKey: .amountLyd)
        isCredit = try container.decode(Bool.self, forKey: .isCredit)
        status = try container.decode(TransferStatus.self, forKey: .status)
        isSimulatedDemo = try container.decode(Bool.self, forKey: .isSimulatedDemo)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(referenceCode, forKey: .referenceCode)
        try container.encode(titleAr, forKey: .titleAr)
        try container.encode(titleEn, forKey: .titleEn)
        try container.encode(timeAr, forKey: .timeAr)
        try container.encode(timeEn, forKey: .timeEn)
        try container.encode(amountLyd, forKey: .amountLyd)
        try container.encode(isCredit, forKey: .isCredit)
        try container.encode(status, forKey: .status)
        try container.encode(isSimulatedDemo, forKey: .isSimulatedDemo)
    }
}

/// Money transfer matching the Kotlin `MoneyTransfer`
@Model
public final class MoneyTransfer: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var referenceCode: String
    public var idempotencyKey: String
    public var senderId: String
    public var recipientId: String
    public var recipientNameAr: String
    public var recipientNameEn: String
    public var amountLyd: Int
    public var note: String
    public var status: TransferStatus
    public var createdAtLabelAr: String
    public var createdAtLabelEn: String
    public var isSimulated: Bool

    public init(
        id: String = UUID().uuidString,
        referenceCode: String,
        idempotencyKey: String,
        senderId: String,
        recipientId: String,
        recipientNameAr: String,
        recipientNameEn: String,
        amountLyd: Int,
        note: String,
        status: TransferStatus,
        createdAtLabelAr: String,
        createdAtLabelEn: String,
        isSimulated: Bool = true
    ) {
        self.id = id
        self.referenceCode = referenceCode
        self.idempotencyKey = idempotencyKey
        self.senderId = senderId
        self.recipientId = recipientId
        self.recipientNameAr = recipientNameAr
        self.recipientNameEn = recipientNameEn
        self.amountLyd = amountLyd
        self.note = note
        self.status = status
        self.createdAtLabelAr = createdAtLabelAr
        self.createdAtLabelEn = createdAtLabelEn
        self.isSimulated = isSimulated
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, referenceCode, idempotencyKey, senderId, recipientId,
             recipientNameAr, recipientNameEn, amountLyd, note, status,
             createdAtLabelAr, createdAtLabelEn, isSimulated
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        referenceCode = try container.decode(String.self, forKey: .referenceCode)
        idempotencyKey = try container.decode(String.self, forKey: .idempotencyKey)
        senderId = try container.decode(String.self, forKey: .senderId)
        recipientId = try container.decode(String.self, forKey: .recipientId)
        recipientNameAr = try container.decode(String.self, forKey: .recipientNameAr)
        recipientNameEn = try container.decode(String.self, forKey: .recipientNameEn)
        amountLyd = try container.decode(Int.self, forKey: .amountLyd)
        note = try container.decode(String.self, forKey: .note)
        status = try container.decode(TransferStatus.self, forKey: .status)
        createdAtLabelAr = try container.decode(String.self, forKey: .createdAtLabelAr)
        createdAtLabelEn = try container.decode(String.self, forKey: .createdAtLabelEn)
        isSimulated = try container.decode(Bool.self, forKey: .isSimulated)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(referenceCode, forKey: .referenceCode)
        try container.encode(idempotencyKey, forKey: .idempotencyKey)
        try container.encode(senderId, forKey: .senderId)
        try container.encode(recipientId, forKey: .recipientId)
        try container.encode(recipientNameAr, forKey: .recipientNameAr)
        try container.encode(recipientNameEn, forKey: .recipientNameEn)
        try container.encode(amountLyd, forKey: .amountLyd)
        try container.encode(note, forKey: .note)
        try container.encode(status, forKey: .status)
        try container.encode(createdAtLabelAr, forKey: .createdAtLabelAr)
        try container.encode(createdAtLabelEn, forKey: .createdAtLabelEn)
        try container.encode(isSimulated, forKey: .isSimulated)
    }
}

/// Money request matching the Kotlin `MoneyRequest`
@Model
public final class MoneyRequest: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var referenceCode: String
    public var requesterId: String
    public var requesterNameAr: String
    public var requesterNameEn: String
    public var payerContactId: String?
    public var payerNameAr: String?
    public var payerNameEn: String?
    public var amountLyd: Int
    public var note: String
    public var status: MoneyRequestStatus
    public var tokenInfo: PaymentRequestToken?
    public var createdAtLabelAr: String
    public var createdAtLabelEn: String
    public var isIncomingToCurrentUser: Bool

    public init(
        id: String = UUID().uuidString,
        referenceCode: String,
        requesterId: String,
        requesterNameAr: String,
        requesterNameEn: String,
        payerContactId: String? = nil,
        payerNameAr: String? = nil,
        payerNameEn: String? = nil,
        amountLyd: Int,
        note: String,
        status: MoneyRequestStatus,
        tokenInfo: PaymentRequestToken? = nil,
        createdAtLabelAr: String,
        createdAtLabelEn: String,
        isIncomingToCurrentUser: Bool = false
    ) {
        self.id = id
        self.referenceCode = referenceCode
        self.requesterId = requesterId
        self.requesterNameAr = requesterNameAr
        self.requesterNameEn = requesterNameEn
        self.payerContactId = payerContactId
        self.payerNameAr = payerNameAr
        self.payerNameEn = payerNameEn
        self.amountLyd = amountLyd
        self.note = note
        self.status = status
        self.tokenInfo = tokenInfo
        self.createdAtLabelAr = createdAtLabelAr
        self.createdAtLabelEn = createdAtLabelEn
        self.isIncomingToCurrentUser = isIncomingToCurrentUser
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, referenceCode, requesterId, requesterNameAr, requesterNameEn,
             payerContactId, payerNameAr, payerNameEn, amountLyd, note, status,
             tokenInfo, createdAtLabelAr, createdAtLabelEn, isIncomingToCurrentUser
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        referenceCode = try container.decode(String.self, forKey: .referenceCode)
        requesterId = try container.decode(String.self, forKey: .requesterId)
        requesterNameAr = try container.decode(String.self, forKey: .requesterNameAr)
        requesterNameEn = try container.decode(String.self, forKey: .requesterNameEn)
        payerContactId = try container.decodeIfPresent(String.self, forKey: .payerContactId)
        payerNameAr = try container.decodeIfPresent(String.self, forKey: .payerNameAr)
        payerNameEn = try container.decodeIfPresent(String.self, forKey: .payerNameEn)
        amountLyd = try container.decode(Int.self, forKey: .amountLyd)
        note = try container.decode(String.self, forKey: .note)
        status = try container.decode(MoneyRequestStatus.self, forKey: .status)
        tokenInfo = try container.decodeIfPresent(PaymentRequestToken.self, forKey: .tokenInfo)
        createdAtLabelAr = try container.decode(String.self, forKey: .createdAtLabelAr)
        createdAtLabelEn = try container.decode(String.self, forKey: .createdAtLabelEn)
        isIncomingToCurrentUser = try container.decode(Bool.self, forKey: .isIncomingToCurrentUser)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(referenceCode, forKey: .referenceCode)
        try container.encode(requesterId, forKey: .requesterId)
        try container.encode(requesterNameAr, forKey: .requesterNameAr)
        try container.encode(requesterNameEn, forKey: .requesterNameEn)
        try container.encodeIfPresent(payerContactId, forKey: .payerContactId)
        try container.encodeIfPresent(payerNameAr, forKey: .payerNameAr)
        try container.encodeIfPresent(payerNameEn, forKey: .payerNameEn)
        try container.encode(amountLyd, forKey: .amountLyd)
        try container.encode(note, forKey: .note)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(tokenInfo, forKey: .tokenInfo)
        try container.encode(createdAtLabelAr, forKey: .createdAtLabelAr)
        try container.encode(createdAtLabelEn, forKey: .createdAtLabelEn)
        try container.encode(isIncomingToCurrentUser, forKey: .isIncomingToCurrentUser)
    }
}

/// KOOI notification matching the Kotlin `KooiNotification`
@Model
public final class KooiNotification: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var titleAr: String
    public var titleEn: String
    public var bodyAr: String
    public var bodyEn: String
    public var timeAr: String
    public var timeEn: String
    public var isRead: Bool

    public init(
        id: String = UUID().uuidString,
        titleAr: String,
        titleEn: String,
        bodyAr: String,
        bodyEn: String,
        timeAr: String,
        timeEn: String,
        isRead: Bool = false
    ) {
        self.id = id
        self.titleAr = titleAr
        self.titleEn = titleEn
        self.bodyAr = bodyAr
        self.bodyEn = bodyEn
        self.timeAr = timeAr
        self.timeEn = timeEn
        self.isRead = isRead
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, titleAr, titleEn, bodyAr, bodyEn, timeAr, timeEn, isRead
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        titleAr = try container.decode(String.self, forKey: .titleAr)
        titleEn = try container.decode(String.self, forKey: .titleEn)
        bodyAr = try container.decode(String.self, forKey: .bodyAr)
        bodyEn = try container.decode(String.self, forKey: .bodyEn)
        timeAr = try container.decode(String.self, forKey: .timeAr)
        timeEn = try container.decode(String.self, forKey: .timeEn)
        isRead = try container.decode(Bool.self, forKey: .isRead)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(titleAr, forKey: .titleAr)
        try container.encode(titleEn, forKey: .titleEn)
        try container.encode(bodyAr, forKey: .bodyAr)
        try container.encode(bodyEn, forKey: .bodyEn)
        try container.encode(timeAr, forKey: .timeAr)
        try container.encode(timeEn, forKey: .timeEn)
        try container.encode(isRead, forKey: .isRead)
    }
}