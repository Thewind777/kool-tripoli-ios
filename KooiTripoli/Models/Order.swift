import Foundation
import SwiftData

/// Order price breakdown matching the Kotlin `OrderPriceBreakdown`
@Model
public final class OrderPriceBreakdown: Codable {
    public var foodSubtotalLyd: Int
    public var modifiersSubtotalLyd: Int
    public var baseDeliveryFeeLyd: Int
    public var coordinationFeesLyd: Int
    @Relationship(deleteRule: .cascade) public var coordinationBreakdown: [RestaurantCoordinationFee]
    public var serviceFeeLyd: Int
    public var scheduledDiscountLyd: Int
    public var loyaltyDiscountLyd: Int
    public var taxesLyd: Int
    public var finalTotalLyd: Int

    public init(
        foodSubtotalLyd: Int = 0,
        modifiersSubtotalLyd: Int = 0,
        baseDeliveryFeeLyd: Int = 0,
        coordinationFeesLyd: Int = 0,
        coordinationBreakdown: [RestaurantCoordinationFee] = [],
        serviceFeeLyd: Int = 0,
        scheduledDiscountLyd: Int = 0,
        loyaltyDiscountLyd: Int = 0,
        taxesLyd: Int = 0,
        finalTotalLyd: Int = 0
    ) {
        self.foodSubtotalLyd = foodSubtotalLyd
        self.modifiersSubtotalLyd = modifiersSubtotalLyd
        self.baseDeliveryFeeLyd = baseDeliveryFeeLyd
        self.coordinationFeesLyd = coordinationFeesLyd
        self.coordinationBreakdown = coordinationBreakdown
        self.serviceFeeLyd = serviceFeeLyd
        self.scheduledDiscountLyd = scheduledDiscountLyd
        self.loyaltyDiscountLyd = loyaltyDiscountLyd
        self.taxesLyd = taxesLyd
        self.finalTotalLyd = finalTotalLyd
    }

    public var totalDiscountsLyd: Int {
        scheduledDiscountLyd + loyaltyDiscountLyd
    }

    public var grossBeforeDiscountsLyd: Int {
        foodSubtotalLyd + modifiersSubtotalLyd + baseDeliveryFeeLyd + coordinationFeesLyd + serviceFeeLyd + taxesLyd
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case foodSubtotalLyd, modifiersSubtotalLyd, baseDeliveryFeeLyd, coordinationFeesLyd,
             coordinationBreakdown, serviceFeeLyd, scheduledDiscountLyd, loyaltyDiscountLyd,
             taxesLyd, finalTotalLyd
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        foodSubtotalLyd = try container.decode(Int.self, forKey: .foodSubtotalLyd)
        modifiersSubtotalLyd = try container.decode(Int.self, forKey: .modifiersSubtotalLyd)
        baseDeliveryFeeLyd = try container.decode(Int.self, forKey: .baseDeliveryFeeLyd)
        coordinationFeesLyd = try container.decode(Int.self, forKey: .coordinationFeesLyd)
        coordinationBreakdown = try container.decode([RestaurantCoordinationFee].self, forKey: .coordinationBreakdown)
        serviceFeeLyd = try container.decode(Int.self, forKey: .serviceFeeLyd)
        scheduledDiscountLyd = try container.decode(Int.self, forKey: .scheduledDiscountLyd)
        loyaltyDiscountLyd = try container.decode(Int.self, forKey: .loyaltyDiscountLyd)
        taxesLyd = try container.decode(Int.self, forKey: .taxesLyd)
        finalTotalLyd = try container.decode(Int.self, forKey: .finalTotalLyd)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(foodSubtotalLyd, forKey: .foodSubtotalLyd)
        try container.encode(modifiersSubtotalLyd, forKey: .modifiersSubtotalLyd)
        try container.encode(baseDeliveryFeeLyd, forKey: .baseDeliveryFeeLyd)
        try container.encode(coordinationFeesLyd, forKey: .coordinationFeesLyd)
        try container.encode(coordinationBreakdown, forKey: .coordinationBreakdown)
        try container.encode(serviceFeeLyd, forKey: .serviceFeeLyd)
        try container.encode(scheduledDiscountLyd, forKey: .scheduledDiscountLyd)
        try container.encode(loyaltyDiscountLyd, forKey: .loyaltyDiscountLyd)
        try container.encode(taxesLyd, forKey: .taxesLyd)
        try container.encode(finalTotalLyd, forKey: .finalTotalLyd)
    }
}

/// Restaurant coordination fee matching the Kotlin `RestaurantCoordinationFee`
@Model
public final class RestaurantCoordinationFee: Codable, Identifiable {
    @Attribute(.unique) public var id: String = UUID().uuidString
    public var restaurantId: String
    public var restaurantNameAr: String
    public var restaurantNameEn: String
    public var feeLyd: Int
    public var isPrimaryAnchor: Bool

    public init(
        restaurantId: String,
        restaurantNameAr: String,
        restaurantNameEn: String,
        feeLyd: Int,
        isPrimaryAnchor: Bool = false
    ) {
        self.restaurantId = restaurantId
        self.restaurantNameAr = restaurantNameAr
        self.restaurantNameEn = restaurantNameEn
        self.feeLyd = feeLyd
        self.isPrimaryAnchor = isPrimaryAnchor
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, restaurantId, restaurantNameAr, restaurantNameEn, feeLyd, isPrimaryAnchor
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        restaurantId = try container.decode(String.self, forKey: .restaurantId)
        restaurantNameAr = try container.decode(String.self, forKey: .restaurantNameAr)
        restaurantNameEn = try container.decode(String.self, forKey: .restaurantNameEn)
        feeLyd = try container.decode(Int.self, forKey: .feeLyd)
        isPrimaryAnchor = try container.decode(Bool.self, forKey: .isPrimaryAnchor)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(restaurantId, forKey: .restaurantId)
        try container.encode(restaurantNameAr, forKey: .restaurantNameAr)
        try container.encode(restaurantNameEn, forKey: .restaurantNameEn)
        try container.encode(feeLyd, forKey: .feeLyd)
        try container.encode(isPrimaryAnchor, forKey: .isPrimaryAnchor)
    }
}

/// Order item matching the Kotlin `OrderItem`
@Model
public final class OrderItem: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var menuItemId: String
    public var restaurantId: String
    public var restaurantNameAr: String
    public var restaurantNameEn: String
    public var nameAr: String
    public var nameEn: String
    public var quantity: Int
    public var unitFoodPriceLyd: Int
    public var modifierPriceLyd: Int
    public var customizationNote: String
    public var participantId: String
    public var participantName: String

    public init(
        id: String = UUID().uuidString,
        menuItemId: String,
        restaurantId: String,
        restaurantNameAr: String,
        restaurantNameEn: String,
        nameAr: String,
        nameEn: String,
        quantity: Int,
        unitFoodPriceLyd: Int,
        modifierPriceLyd: Int,
        customizationNote: String,
        participantId: String = "user_self",
        participantName: String = ""
    ) {
        self.id = id
        self.menuItemId = menuItemId
        self.restaurantId = restaurantId
        self.restaurantNameAr = restaurantNameAr
        self.restaurantNameEn = restaurantNameEn
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.quantity = quantity
        self.unitFoodPriceLyd = unitFoodPriceLyd
        self.modifierPriceLyd = modifierPriceLyd
        self.customizationNote = customizationNote
        self.participantId = participantId
        self.participantName = participantName
    }

    public var lineTotalLyd: Int {
        (unitFoodPriceLyd + modifierPriceLyd) * quantity
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, menuItemId, restaurantId, restaurantNameAr, restaurantNameEn,
             nameAr, nameEn, quantity, unitFoodPriceLyd, modifierPriceLyd,
             customizationNote, participantId, participantName
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        menuItemId = try container.decode(String.self, forKey: .menuItemId)
        restaurantId = try container.decode(String.self, forKey: .restaurantId)
        restaurantNameAr = try container.decode(String.self, forKey: .restaurantNameAr)
        restaurantNameEn = try container.decode(String.self, forKey: .restaurantNameEn)
        nameAr = try container.decode(String.self, forKey: .nameAr)
        nameEn = try container.decode(String.self, forKey: .nameEn)
        quantity = try container.decode(Int.self, forKey: .quantity)
        unitFoodPriceLyd = try container.decode(Int.self, forKey: .unitFoodPriceLyd)
        modifierPriceLyd = try container.decode(Int.self, forKey: .modifierPriceLyd)
        customizationNote = try container.decode(String.self, forKey: .customizationNote)
        participantId = try container.decode(String.self, forKey: .participantId)
        participantName = try container.decode(String.self, forKey: .participantName)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(menuItemId, forKey: .menuItemId)
        try container.encode(restaurantId, forKey: .restaurantId)
        try container.encode(restaurantNameAr, forKey: .restaurantNameAr)
        try container.encode(restaurantNameEn, forKey: .restaurantNameEn)
        try container.encode(nameAr, forKey: .nameAr)
        try container.encode(nameEn, forKey: .nameEn)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(unitFoodPriceLyd, forKey: .unitFoodPriceLyd)
        try container.encode(modifierPriceLyd, forKey: .modifierPriceLyd)
        try container.encode(customizationNote, forKey: .customizationNote)
        try container.encode(participantId, forKey: .participantId)
        try container.encode(participantName, forKey: .participantName)
    }
}

/// Restaurant order group matching the Kotlin `RestaurantOrderGroup`
@Model
public final class RestaurantOrderGroup: Codable, Identifiable {
    @Attribute(.unique) public var id: String = UUID().uuidString
    public var restaurantId: String
    public var restaurantNameAr: String
    public var restaurantNameEn: String
    @Relationship(deleteRule: .cascade) public var items: [CartItem]
    public var subtotalLyd: Int
    public var coordinationFeeLyd: Int
    public var isAvailable: Bool
    public var statusNoteAr: String?
    public var statusNoteEn: String?
    public var prepMinutes: Int

    public init(
        restaurantId: String,
        restaurantNameAr: String,
        restaurantNameEn: String,
        items: [CartItem] = [],
        subtotalLyd: Int = 0,
        coordinationFeeLyd: Int = 0,
        isAvailable: Bool = true,
        statusNoteAr: String? = nil,
        statusNoteEn: String? = nil,
        prepMinutes: Int = 20
    ) {
        self.restaurantId = restaurantId
        self.restaurantNameAr = restaurantNameAr
        self.restaurantNameEn = restaurantNameEn
        self.items = items
        self.subtotalLyd = subtotalLyd
        self.coordinationFeeLyd = coordinationFeeLyd
        self.isAvailable = isAvailable
        self.statusNoteAr = statusNoteAr
        self.statusNoteEn = statusNoteEn
        self.prepMinutes = prepMinutes
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, restaurantId, restaurantNameAr, restaurantNameEn, items,
             subtotalLyd, coordinationFeeLyd, isAvailable, statusNoteAr, statusNoteEn, prepMinutes
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        restaurantId = try container.decode(String.self, forKey: .restaurantId)
        restaurantNameAr = try container.decode(String.self, forKey: .restaurantNameAr)
        restaurantNameEn = try container.decode(String.self, forKey: .restaurantNameEn)
        items = try container.decode([CartItem].self, forKey: .items)
        subtotalLyd = try container.decode(Int.self, forKey: .subtotalLyd)
        coordinationFeeLyd = try container.decode(Int.self, forKey: .coordinationFeeLyd)
        isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
        statusNoteAr = try container.decodeIfPresent(String.self, forKey: .statusNoteAr)
        statusNoteEn = try container.decodeIfPresent(String.self, forKey: .statusNoteEn)
        prepMinutes = try container.decode(Int.self, forKey: .prepMinutes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(restaurantId, forKey: .restaurantId)
        try container.encode(restaurantNameAr, forKey: .restaurantNameAr)
        try container.encode(restaurantNameEn, forKey: .restaurantNameEn)
        try container.encode(items, forKey: .items)
        try container.encode(subtotalLyd, forKey: .subtotalLyd)
        try container.encode(coordinationFeeLyd, forKey: .coordinationFeeLyd)
        try container.encode(isAvailable, forKey: .isAvailable)
        try container.encodeIfPresent(statusNoteAr, forKey: .statusNoteAr)
        try container.encodeIfPresent(statusNoteEn, forKey: .statusNoteEn)
        try container.encode(prepMinutes, forKey: .prepMinutes)
    }
}

/// Pickup stop info matching the Kotlin `PickupStopInfo`
@Model
public final class PickupStopInfo: Codable, Identifiable {
    @Attribute(.unique) public var id: String = UUID().uuidString
    public var sequenceNumber: Int
    public var restaurantId: String
    public var restaurantNameAr: String
    public var restaurantNameEn: String
    public var addressAr: String
    public var addressEn: String
    public var instructionsAr: String
    public var instructionsEn: String
    public var estimatedReadyMinutes: Int
    public var isReady: Bool

    public init(
        sequenceNumber: Int,
        restaurantId: String,
        restaurantNameAr: String,
        restaurantNameEn: String,
        addressAr: String,
        addressEn: String,
        instructionsAr: String,
        instructionsEn: String,
        estimatedReadyMinutes: Int,
        isReady: Bool = false
    ) {
        self.sequenceNumber = sequenceNumber
        self.restaurantId = restaurantId
        self.restaurantNameAr = restaurantNameAr
        self.restaurantNameEn = restaurantNameEn
        self.addressAr = addressAr
        self.addressEn = addressEn
        self.instructionsAr = instructionsAr
        self.instructionsEn = instructionsEn
        self.estimatedReadyMinutes = estimatedReadyMinutes
        self.isReady = isReady
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, sequenceNumber, restaurantId, restaurantNameAr, restaurantNameEn,
             addressAr, addressEn, instructionsAr, instructionsEn, estimatedReadyMinutes, isReady
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        sequenceNumber = try container.decode(Int.self, forKey: .sequenceNumber)
        restaurantId = try container.decode(String.self, forKey: .restaurantId)
        restaurantNameAr = try container.decode(String.self, forKey: .restaurantNameAr)
        restaurantNameEn = try container.decode(String.self, forKey: .restaurantNameEn)
        addressAr = try container.decode(String.self, forKey: .addressAr)
        addressEn = try container.decode(String.self, forKey: .addressEn)
        instructionsAr = try container.decode(String.self, forKey: .instructionsAr)
        instructionsEn = try container.decode(String.self, forKey: .instructionsEn)
        estimatedReadyMinutes = try container.decode(Int.self, forKey: .estimatedReadyMinutes)
        isReady = try container.decode(Bool.self, forKey: .isReady)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sequenceNumber, forKey: .sequenceNumber)
        try container.encode(restaurantId, forKey: .restaurantId)
        try container.encode(restaurantNameAr, forKey: .restaurantNameAr)
        try container.encode(restaurantNameEn, forKey: .restaurantNameEn)
        try container.encode(addressAr, forKey: .addressAr)
        try container.encode(addressEn, forKey: .addressEn)
        try container.encode(instructionsAr, forKey: .instructionsAr)
        try container.encode(instructionsEn, forKey: .instructionsEn)
        try container.encode(estimatedReadyMinutes, forKey: .estimatedReadyMinutes)
        try container.encode(isReady, forKey: .isReady)
    }
}

/// Active order matching the Kotlin `ActiveOrder`
@Model
public final class ActiveOrder: Codable, Identifiable {
    @Attribute(.unique) public var id: String = UUID().uuidString
    public var orderNumber: String
    public var storeSummaryAr: String
    public var storeSummaryEn: String
    public var restaurantIds: [String]
    public var fulfillmentMode: FulfillmentMode
    public var orderingScope: OrderingScope
    public var participationMode: ParticipationMode
    public var orderStatus: OrderStatus
    public var priceBreakdown: OrderPriceBreakdown?
    public var pickupStops: [PickupStopInfo]
    public var totalLyd: Int
    public var foodSubtotalLyd: Int
    public var itemCount: Int
    public var etaMinutes: Int
    public var addressAr: String
    public var addressEn: String
    public var paymentMethod: PaymentMethod
    public var scheduledSlot: String?
    public var appliedLoyaltyRewardId: String?
    public var stage: TrackingStage

    public init(
        orderNumber: String,
        storeSummaryAr: String,
        storeSummaryEn: String,
        restaurantIds: [String] = [],
        fulfillmentMode: FulfillmentMode = .delivery,
        orderingScope: OrderingScope = .singleRestaurant,
        participationMode: ParticipationMode = .individual,
        orderStatus: OrderStatus = .restaurantAccepted,
        priceBreakdown: OrderPriceBreakdown? = nil,
        pickupStops: [PickupStopInfo] = [],
        totalLyd: Int,
        foodSubtotalLyd: Int? = nil,
        itemCount: Int,
        etaMinutes: Int,
        addressAr: String,
        addressEn: String,
        paymentMethod: PaymentMethod,
        scheduledSlot: String? = nil,
        appliedLoyaltyRewardId: String? = nil,
        stage: TrackingStage = .confirmed
    ) {
        self.orderNumber = orderNumber
        self.storeSummaryAr = storeSummaryAr
        self.storeSummaryEn = storeSummaryEn
        self.restaurantIds = restaurantIds
        self.fulfillmentMode = fulfillmentMode
        self.orderingScope = orderingScope
        self.participationMode = participationMode
        self.orderStatus = orderStatus
        self.priceBreakdown = priceBreakdown
        self.pickupStops = pickupStops
        self.totalLyd = totalLyd
        self.foodSubtotalLyd = foodSubtotalLyd ?? totalLyd
        self.itemCount = itemCount
        self.etaMinutes = etaMinutes
        self.addressAr = addressAr
        self.addressEn = addressEn
        self.paymentMethod = paymentMethod
        self.scheduledSlot = scheduledSlot
        self.appliedLoyaltyRewardId = appliedLoyaltyRewardId
        self.stage = stage
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, orderNumber, storeSummaryAr, storeSummaryEn, restaurantIds,
             fulfillmentMode, orderingScope, participationMode, orderStatus,
             priceBreakdown, pickupStops, totalLyd, foodSubtotalLyd, itemCount,
             etaMinutes, addressAr, addressEn, paymentMethod, scheduledSlot,
             appliedLoyaltyRewardId, stage
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        orderNumber = try container.decode(String.self, forKey: .orderNumber)
        storeSummaryAr = try container.decode(String.self, forKey: .storeSummaryAr)
        storeSummaryEn = try container.decode(String.self, forKey: .storeSummaryEn)
        restaurantIds = try container.decode([String].self, forKey: .restaurantIds)
        fulfillmentMode = try container.decode(FulfillmentMode.self, forKey: .fulfillmentMode)
        orderingScope = try container.decode(OrderingScope.self, forKey: .orderingScope)
        participationMode = try container.decode(ParticipationMode.self, forKey: .participationMode)
        orderStatus = try container.decode(OrderStatus.self, forKey: .orderStatus)
        priceBreakdown = try container.decodeIfPresent(OrderPriceBreakdown.self, forKey: .priceBreakdown)
        pickupStops = try container.decode([PickupStopInfo].self, forKey: .pickupStops)
        totalLyd = try container.decode(Int.self, forKey: .totalLyd)
        foodSubtotalLyd = try container.decode(Int.self, forKey: .foodSubtotalLyd)
        itemCount = try container.decode(Int.self, forKey: .itemCount)
        etaMinutes = try container.decode(Int.self, forKey: .etaMinutes)
        addressAr = try container.decode(String.self, forKey: .addressAr)
        addressEn = try container.decode(String.self, forKey: .addressEn)
        paymentMethod = try container.decode(PaymentMethod.self, forKey: .paymentMethod)
        scheduledSlot = try container.decodeIfPresent(String.self, forKey: .scheduledSlot)
        appliedLoyaltyRewardId = try container.decodeIfPresent(String.self, forKey: .appliedLoyaltyRewardId)
        stage = try container.decode(TrackingStage.self, forKey: .stage)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(orderNumber, forKey: .orderNumber)
        try container.encode(storeSummaryAr, forKey: .storeSummaryAr)
        try container.encode(storeSummaryEn, forKey: .storeSummaryEn)
        try container.encode(restaurantIds, forKey: .restaurantIds)
        try container.encode(fulfillmentMode, forKey: .fulfillmentMode)
        try container.encode(orderingScope, forKey: .orderingScope)
        try container.encode(participationMode, forKey: .participationMode)
        try container.encode(orderStatus, forKey: .orderStatus)
        try container.encodeIfPresent(priceBreakdown, forKey: .priceBreakdown)
        try container.encode(pickupStops, forKey: .pickupStops)
        try container.encode(totalLyd, forKey: .totalLyd)
        try container.encode(foodSubtotalLyd, forKey: .foodSubtotalLyd)
        try container.encode(itemCount, forKey: .itemCount)
        try container.encode(etaMinutes, forKey: .etaMinutes)
        try container.encode(addressAr, forKey: .addressAr)
        try container.encode(addressEn, forKey: .addressEn)
        try container.encode(paymentMethod, forKey: .paymentMethod)
        try container.encodeIfPresent(scheduledSlot, forKey: .scheduledSlot)
        try container.encodeIfPresent(appliedLoyaltyRewardId, forKey: .appliedLoyaltyRewardId)
        try container.encode(stage, forKey: .stage)
    }
}

/// Order matching the Kotlin `Order`
@Model
public final class Order: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var orderNumber: String
    public var createdAtEpochMs: Int64
    public var fulfillmentMode: FulfillmentMode
    public var orderingScope: OrderingScope
    public var participationMode: ParticipationMode
    public var groupId: String?
    public var status: OrderStatus
    @Relationship(deleteRule: .cascade) public var restaurantGroups: [RestaurantOrderGroup]
    public var priceBreakdown: OrderPriceBreakdown
    public var paymentMethod: PaymentMethod
    public var deliveryAddress: DeliveryAddress?
    public var pickupStops: [PickupStopInfo]
    public var scheduledSlotLabel: String?
    public var etaMinutes: Int

    public init(
        id: String = UUID().uuidString,
        orderNumber: String,
        createdAtEpochMs: Int64 = Int64(Date().timeIntervalSince1970 * 1000),
        fulfillmentMode: FulfillmentMode,
        orderingScope: OrderingScope,
        participationMode: ParticipationMode,
        groupId: String? = nil,
        status: OrderStatus,
        restaurantGroups: [RestaurantOrderGroup] = [],
        priceBreakdown: OrderPriceBreakdown,
        paymentMethod: PaymentMethod,
        deliveryAddress: DeliveryAddress? = nil,
        pickupStops: [PickupStopInfo] = [],
        scheduledSlotLabel: String? = nil,
        etaMinutes: Int
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.createdAtEpochMs = createdAtEpochMs
        self.fulfillmentMode = fulfillmentMode
        self.orderingScope = orderingScope
        self.participationMode = participationMode
        self.groupId = groupId
        self.status = status
        self.restaurantGroups = restaurantGroups
        self.priceBreakdown = priceBreakdown
        self.paymentMethod = paymentMethod
        self.deliveryAddress = deliveryAddress
        self.pickupStops = pickupStops
        self.scheduledSlotLabel = scheduledSlotLabel
        self.etaMinutes = etaMinutes
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, orderNumber, createdAtEpochMs, fulfillmentMode, orderingScope,
             participationMode, groupId, status, restaurantGroups, priceBreakdown,
             paymentMethod, deliveryAddress, pickupStops, scheduledSlotLabel, etaMinutes
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        orderNumber = try container.decode(String.self, forKey: .orderNumber)
        createdAtEpochMs = try container.decode(Int64.self, forKey: .createdAtEpochMs)
        fulfillmentMode = try container.decode(FulfillmentMode.self, forKey: .fulfillmentMode)
        orderingScope = try container.decode(OrderingScope.self, forKey: .orderingScope)
        participationMode = try container.decode(ParticipationMode.self, forKey: .participationMode)
        groupId = try container.decodeIfPresent(String.self, forKey: .groupId)
        status = try container.decode(OrderStatus.self, forKey: .status)
        restaurantGroups = try container.decode([RestaurantOrderGroup].self, forKey: .restaurantGroups)
        priceBreakdown = try container.decode(OrderPriceBreakdown.self, forKey: .priceBreakdown)
        paymentMethod = try container.decode(PaymentMethod.self, forKey: .paymentMethod)
        deliveryAddress = try container.decodeIfPresent(DeliveryAddress.self, forKey: .deliveryAddress)
        pickupStops = try container.decode([PickupStopInfo].self, forKey: .pickupStops)
        scheduledSlotLabel = try container.decodeIfPresent(String.self, forKey: .scheduledSlotLabel)
        etaMinutes = try container.decode(Int.self, forKey: .etaMinutes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(orderNumber, forKey: .orderNumber)
        try container.encode(createdAtEpochMs, forKey: .createdAtEpochMs)
        try container.encode(fulfillmentMode, forKey: .fulfillmentMode)
        try container.encode(orderingScope, forKey: .orderingScope)
        try container.encode(participationMode, forKey: .participationMode)
        try container.encodeIfPresent(groupId, forKey: .groupId)
        try container.encode(status, forKey: .status)
        try container.encode(restaurantGroups, forKey: .restaurantGroups)
        try container.encode(priceBreakdown, forKey: .priceBreakdown)
        try container.encode(paymentMethod, forKey: .paymentMethod)
        try container.encodeIfPresent(deliveryAddress, forKey: .deliveryAddress)
        try container.encode(pickupStops, forKey: .pickupStops)
        try container.encodeIfPresent(scheduledSlotLabel, forKey: .scheduledSlotLabel)
        try container.encode(etaMinutes, forKey: .etaMinutes)
    }
}

/// Fulfillment switch prompt matching the Kotlin `FulfillmentSwitchPrompt`
public struct FulfillmentSwitchPrompt: Codable {
    public var requestedMode: FulfillmentMode
    public var currentFeeTotalLyd: Int
    public var newFeeTotalLyd: Int
    public var incompatibleRestaurantNamesAr: [String]
    public var incompatibleRestaurantNamesEn: [String]
    public var blockedReasonAr: String?
    public var blockedReasonEn: String?

    public var isBlocked: Bool {
        blockedReasonAr != nil || !incompatibleRestaurantNamesEn.isEmpty
    }

    public init(
        requestedMode: FulfillmentMode,
        currentFeeTotalLyd: Int,
        newFeeTotalLyd: Int,
        incompatibleRestaurantNamesAr: [String] = [],
        incompatibleRestaurantNamesEn: [String] = [],
        blockedReasonAr: String? = nil,
        blockedReasonEn: String? = nil
    ) {
        self.requestedMode = requestedMode
        self.currentFeeTotalLyd = currentFeeTotalLyd
        self.newFeeTotalLyd = newFeeTotalLyd
        self.incompatibleRestaurantNamesAr = incompatibleRestaurantNamesAr
        self.incompatibleRestaurantNamesEn = incompatibleRestaurantNamesEn
        self.blockedReasonAr = blockedReasonAr
        self.blockedReasonEn = blockedReasonEn
    }
}