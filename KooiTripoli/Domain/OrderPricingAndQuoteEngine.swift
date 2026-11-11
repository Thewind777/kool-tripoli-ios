import Foundation

// MARK: - Order Pricing & Quote Engine

/// Complete order pricing, multi-restaurant quote, fulfillment validation, and fee breakdown engine
/// Ported from Kotlin `OrderPricingAndQuoteEngine`
public struct OrderPricingAndQuoteEngine {

    // MARK: - Fulfillment Validation

    /// Validates if a restaurant supports the requested fulfillment mode for a given address
    public static func validateRestaurantFulfillment(
        restaurant: Restaurant,
        mode: FulfillmentMode,
        address: DeliveryAddress?
    ) -> (Bool, (String, String)?) {

        if !restaurant.isAvailableForOrdering {
            return (false, (
                "المطعم (\(restaurant.nameAr)) \(restaurant.operationalStatus.labelAr) ولا يستقبل طلبات جديدة حالياً.",
                "\(restaurant.nameEn) is currently \(restaurant.operationalStatus.labelEn.lowercased()) and cannot accept orders."
            ))
        }

        switch mode {
        case .delivery:
            if !restaurant.supportsDelivery {
                return (false, (
                    "التوصيل غير متاح من \(restaurant.nameAr)؛ يمكنك الطلب عبر الاستلام من المطعم.",
                    "Delivery is unavailable for \(restaurant.nameEn); Pickup is available instead."
                ))
            }
            guard let address = address, address.isDeliverySupported else {
                return (false, (
                    "يرجى اختيار عنوان توصيل صالح ضمن نطاق الخدمة في طرابلس.",
                    "Please select a valid Tripoli delivery address within coverage."
                ))
            }
            if !restaurant.supportedMicroZones.contains(address.microZoneId) {
                return (false, (
                    "عنوانك في (\(address.districtAr)) خارج نطاق توصيل \(restaurant.nameAr)؛ يتوفر الاستلام المباشر.",
                    "Your address (\(address.districtEn)) is outside \(restaurant.nameEn)'s delivery zone; Pickup is available."
                ))
            }
            return (true, nil)

        case .pickup:
            if !restaurant.supportsPickup {
                return (false, (
                    "الاستلام المباشر غير متاح في \(restaurant.nameAr)؛ يتوفر التوصيل إلى عنوانك.",
                    "Self-pickup is unavailable at \(restaurant.nameEn); Delivery is supported instead."
                ))
            }
            return (true, nil)
        }
    }

    // MARK: - Multi-Restaurant Quote

    /// Calculates a quote for a multi-restaurant (Food Street) order
    public static func calculateMultiRestaurantQuote(
        street: FoodStreet,
        selectedRestaurantIds: [String],
        allRestaurants: [Restaurant],
        fulfillmentMode: FulfillmentMode,
        deliveryAddress: DeliveryAddress?
    ) -> MultiRestaurantQuote {

        let resolved = selectedRestaurantIds.compactMap { id -> Restaurant? in
            allRestaurants.first { $0.id == id }
        }
        let available = resolved.filter { $0.isAvailableForOrdering }
        let unavailable = resolved.filter { !$0.isAvailableForOrdering }

        // Delivery feasibility
        let deliveryFeasible = !available.isEmpty &&
            deliveryAddress != nil &&
            deliveryAddress!.isDeliverySupported &&
            available.allSatisfy { $0.supportsDelivery && $0.supportedMicroZones.contains(deliveryAddress!.microZoneId) }

        // Pickup feasibility
        let pickupFeasible = !available.isEmpty &&
            street.supportsCoordinatedPickup &&
            available.allSatisfy { $0.supportsPickup }

        // Coordination fees: first restaurant is anchor (0 fee), others pay their coordination fee in delivery mode
        let coordinationList = available.enumerated().map { index, rest -> RestaurantCoordinationFee in
            let isAnchor = index == 0
            let appliedFee: Int
            switch fulfillmentMode {
            case .pickup:
                appliedFee = 0
            case .delivery:
                appliedFee = isAnchor ? 0 : rest.coordinationFeeLyd
            }
            return RestaurantCoordinationFee(
                restaurantId: rest.id,
                restaurantNameAr: rest.nameAr,
                restaurantNameEn: rest.nameEn,
                feeLyd: appliedFee,
                isPrimaryAnchor: isAnchor
            )
        }

        let baseDelivery = (fulfillmentMode == .delivery && !available.isEmpty) ? street.baseStreetDeliveryFeeLyd : 0
        let coordSum = coordinationList.reduce(0) { $0 + $1.feeLyd }
        let serviceFee = (fulfillmentMode == .delivery && available.count > 1) ? street.serviceFeeLyd : 0

        // Combined ETA: max prep time + coordination buffer (5 min per additional restaurant)
        let maxPrep = available.map {
            fulfillmentMode == .pickup ? $0.pickupPrepMinutes : $0.deliveryMinutes
        }.max() ?? street.avgEtaMinutes
        let coordinationBuffer = max(0, available.count - 1) * 5
        let combinedEta = maxPrep + coordinationBuffer

        // Validation errors
        var errorPair: (String, String)? = nil
        if resolved.count > street.maxSelectableRestaurants {
            errorPair = (
                "الحد الأقصى هو \(street.maxSelectableRestaurants) مطاعم في الطلب الموحد.",
                "Maximum \(street.maxSelectableRestaurants) restaurants allowed per MR order."
            )
        } else if !unavailable.isEmpty {
            let namesAr = unavailable.map { $0.nameAr }.joined(separator: "، ")
            let namesEn = unavailable.map { $0.nameEn }.joined(separator: ", ")
            errorPair = (
                "أصبح (\(namesAr)) غير متاح حالياً. يرجى إزالته ومراجعة التسعير المحدّث.",
                "\(namesEn) became unavailable. Remove it to review the updated quote."
            )
        } else if fulfillmentMode == .delivery && !deliveryFeasible {
            errorPair = (
                "التوصيل الموحد غير متاح للعنوان المختار أو لأحد المطاعم المحددة.",
                "Coordinated delivery is not supported for the selected address or kitchens."
            )
        } else if fulfillmentMode == .pickup && !pickupFeasible {
            let ar = street.multiPickupDisabledReasonAr
                ?? "الاستلام المتعدد غير مدعوم لهذا الشارع أو لأحد المطاعم المختارة."
            let en = street.multiPickupDisabledReasonEn
                ?? "Multi-stop pickup is not supported for this street or one of the selected kitchens."
            errorPair = (ar, en)
        }

        return MultiRestaurantQuote(
            street: street,
            selectedRestaurants: available,
            unavailableRestaurants: unavailable,
            fulfillmentMode: fulfillmentMode,
            baseDeliveryFeeLyd: baseDelivery,
            coordinationFees: coordinationList,
            totalCoordinationFeeLyd: coordSum,
            serviceFeeLyd: serviceFee,
            combinedEstimatedMinutes: combinedEta,
            isDeliveryFeasible: deliveryFeasible,
            isPickupFeasible: pickupFeasible,
            validationErrorAr: errorPair?.0,
            validationErrorEn: errorPair?.1
        )
    }

    // MARK: - Order Price Breakdown

    /// Calculates the complete order price breakdown including delivery, coordination, service fees, discounts
    public static func calculateOrderPriceBreakdown(
        cartItems: [CartItem],
        allRestaurants: [Restaurant],
        fulfillmentMode: FulfillmentMode,
        orderingScope: OrderingScope,
        mrStreet: FoodStreet?,
        scheduledOffer: ScheduledOffer? = nil,
        loyaltyReward: LoyaltyReward? = nil
    ) -> OrderPriceBreakdown {

        if cartItems.isEmpty {
            return OrderPriceBreakdown(
                foodSubtotalLyd: 0,
                modifiersSubtotalLyd: 0,
                baseDeliveryFeeLyd: 0,
                coordinationFeesLyd: 0,
                coordinationBreakdown: [],
                serviceFeeLyd: 0,
                scheduledDiscountLyd: 0,
                loyaltyDiscountLyd: 0,
                taxesLyd: 0,
                finalTotalLyd: 0
            )
        }

        let foodSub = cartItems.reduce(0) { $0 + $1.quotedUnitPriceLyd * $1.quantity }
        let modSub = cartItems.reduce(0) { $0 + $1.modifierExtraLyd * $1.quantity }

        let distinctIds = cartItems.map { $0.menuItem.restaurantId }.removingDuplicates()
        let distinctRestaurants = distinctIds.compactMap { id in allRestaurants.first { $0.id == id } }

        let isMulti = orderingScope == .multiRestaurant || distinctRestaurants.count > 1

        // Base delivery fee
        let baseDeliveryFee: Int
        switch fulfillmentMode {
        case .pickup:
            baseDeliveryFee = 0
        case .delivery:
            if isMulti {
                baseDeliveryFee = mrStreet?.baseStreetDeliveryFeeLyd ?? (distinctRestaurants.first?.deliveryFeeLyd ?? 5)
            } else {
                baseDeliveryFee = distinctRestaurants.first?.deliveryFeeLyd ?? 5
            }
        }

        // Coordination fees breakdown
        let coordBreakdown: [RestaurantCoordinationFee]
        if isMulti {
            coordBreakdown = distinctRestaurants.enumerated().map { idx, r in
                let fee = (fulfillmentMode == .delivery && idx > 0) ? r.coordinationFeeLyd : 0
                return RestaurantCoordinationFee(
                    restaurantId: r.id,
                    restaurantNameAr: r.nameAr,
                    restaurantNameEn: r.nameEn,
                    feeLyd: fee,
                    isPrimaryAnchor: idx == 0
                )
            }
        } else {
            coordBreakdown = []
        }
        let coordTotal = coordBreakdown.reduce(0) { $0 + $1.feeLyd }

        // Service fee
        let serviceFee = (fulfillmentMode == .delivery && isMulti && distinctRestaurants.count > 1)
            ? (mrStreet?.serviceFeeLyd ?? 2)
            : 0

        // Scheduled offer discount
        let eligibleFoodAndMod = foodSub + modSub
        let scheduledDisc = scheduledOffer.map { offer in
            let raw = Int((Double(eligibleFoodAndMod) * Double(offer.discountPercent) / 100.0).rounded())
            return min(raw, offer.maxDiscountCapLyd, eligibleFoodAndMod)
        } ?? 0

        let remainingAfterSched = max(0, eligibleFoodAndMod - scheduledDisc)

        // Loyalty discount
        let loyaltyDisc = loyaltyReward.map { min($0.discountValueLyd, remainingAfterSched) } ?? 0

        let gross = eligibleFoodAndMod + baseDeliveryFee + coordTotal + serviceFee
        let finalTotal = max(0, gross - scheduledDisc - loyaltyDisc)

        return OrderPriceBreakdown(
            foodSubtotalLyd: foodSub,
            modifiersSubtotalLyd: modSub,
            baseDeliveryFeeLyd: baseDeliveryFee,
            coordinationFeesLyd: coordTotal,
            coordinationBreakdown: coordBreakdown,
            serviceFeeLyd: serviceFee,
            scheduledDiscountLyd: scheduledDisc,
            loyaltyDiscountLyd: loyaltyDisc,
            taxesLyd: 0,
            finalTotalLyd: finalTotal
        )
    }

    // MARK: - Restaurant Order Groups

    /// Builds restaurant order groups from cart items with subtotals and coordination fees
    public static func buildRestaurantOrderGroups(
        cartItems: [CartItem],
        allRestaurants: [Restaurant],
        breakdown: OrderPriceBreakdown
    ) -> [RestaurantOrderGroup] {

        let grouped = Dictionary(grouping: cartItems, by: { $0.menuItem.restaurantId })

        return grouped.map { (restId, items) in
            let rest = allRestaurants.first { $0.id == restId }
            let coordFee = breakdown.coordinationBreakdown.first { $0.restaurantId == restId }?.feeLyd ?? 0
            let available = (rest?.isAvailableForOrdering == true) && items.allSatisfy { $0.menuItem.isAvailable }

            return RestaurantOrderGroup(
                restaurantId: restId,
                restaurantNameAr: rest?.nameAr ?? items.first?.menuItem.restaurantNameAr ?? "",
                restaurantNameEn: rest?.nameEn ?? items.first?.menuItem.restaurantNameEn ?? "",
                items: items,
                subtotalLyd: items.reduce(0) { $0 + $1.lineTotalLyd },
                coordinationFeeLyd: coordFee,
                isAvailable: available,
                statusNoteAr: (rest != nil && !rest!.isAvailableForOrdering) ? rest!.operationalStatus.labelAr : nil,
                statusNoteEn: (rest != nil && !rest!.isAvailableForOrdering) ? rest!.operationalStatus.labelEn : nil,
                prepMinutes: rest?.pickupPrepMinutes ?? 18
            )
        }
    }

    // MARK: - Pickup Stops

    /// Builds pickup stop info for multi-restaurant pickup orders
    public static func buildPickupStops(
        restaurantIds: [String],
        allRestaurants: [Restaurant]
    ) -> [PickupStopInfo] {

        let resolved = restaurantIds.removingDuplicates()
            .compactMap { id in allRestaurants.first { $0.id == id } }
            .sorted { $0.pickupPrepMinutes < $1.pickupPrepMinutes }

        return resolved.enumerated().map { idx, r in
            PickupStopInfo(
                sequenceNumber: idx + 1,
                restaurantId: r.id,
                restaurantNameAr: r.nameAr,
                restaurantNameEn: r.nameEn,
                addressAr: r.pickupAddressAr,
                addressEn: r.pickupAddressEn,
                instructionsAr: r.pickupInstructionsAr,
                instructionsEn: r.pickupInstructionsEn,
                estimatedReadyMinutes: r.pickupPrepMinutes
            )
        }
    }

    // MARK: - Fulfillment Switch Prompt

    /// Builds a confirmation prompt when switching Delivery <-> Pickup with existing cart
    public static func buildFulfillmentSwitchPrompt(
        requestedMode: FulfillmentMode,
        cartItems: [CartItem],
        allRestaurants: [Restaurant],
        currentBreakdown: OrderPriceBreakdown,
        orderingScope: OrderingScope,
        mrStreet: FoodStreet?,
        deliveryAddress: DeliveryAddress?
    ) -> FulfillmentSwitchPrompt {

        let distinctIds = cartItems.map { $0.menuItem.restaurantId }.removingDuplicates()
        let stores = distinctIds.compactMap { id in allRestaurants.first { $0.id == id } }

        let incompatible = stores.filter { store in
            !validateRestaurantFulfillment(restaurant: store, mode: requestedMode, address: deliveryAddress).0
        }

        let multiPickupBlocked = requestedMode == .pickup &&
            stores.count > 1 &&
            mrStreet != nil &&
            !mrStreet!.supportsCoordinatedPickup

        let nextBreakdown = calculateOrderPriceBreakdown(
            cartItems: cartItems,
            allRestaurants: allRestaurants,
            fulfillmentMode: requestedMode,
            orderingScope: orderingScope,
            mrStreet: mrStreet
        )

        let currentLogistics = currentBreakdown.baseDeliveryFeeLyd + currentBreakdown.coordinationFeesLyd + currentBreakdown.serviceFeeLyd
        let nextLogistics = nextBreakdown.baseDeliveryFeeLyd + nextBreakdown.coordinationFeesLyd + nextBreakdown.serviceFeeLyd

        return FulfillmentSwitchPrompt(
            requestedMode: requestedMode,
            currentFeeTotalLyd: currentLogistics,
            newFeeTotalLyd: nextLogistics,
            incompatibleRestaurantNamesAr: incompatible.map { $0.nameAr },
            incompatibleRestaurantNamesEn: incompatible.map { $0.nameEn },
            blockedReasonAr: multiPickupBlocked ? (mrStreet?.multiPickupDisabledReasonAr ?? "الاستلام المتعدد غير مدعوم لهذا الشارع.") : nil,
            blockedReasonEn: multiPickupBlocked ? (mrStreet?.multiPickupDisabledReasonEn ?? "Multi-stop pickup is not supported on this street.") : nil
        )
    }

    // MARK: - MR Unavailable Recovery

    /// Builds recovery prompt when MR restaurants become unavailable
    public static func buildMrUnavailableRecovery(
        street: FoodStreet,
        selectedRestaurantIds: [String],
        allRestaurants: [Restaurant],
        fulfillmentMode: FulfillmentMode,
        deliveryAddress: DeliveryAddress?
    ) -> MrUnavailableRecoveryPrompt? {

        let resolved = selectedRestaurantIds.compactMap { id in allRestaurants.first { $0.id == id } }
        let unavailable = resolved.filter { !$0.isAvailableForOrdering }
        if unavailable.isEmpty { return nil }

        let remainingIds = resolved.filter { $0.isAvailableForOrdering }.map { $0.id }
        let revised = remainingIds.isEmpty ? nil : calculateMultiRestaurantQuote(
            street: street,
            selectedRestaurantIds: remainingIds,
            allRestaurants: allRestaurants,
            fulfillmentMode: fulfillmentMode,
            deliveryAddress: deliveryAddress
        )

        return MrUnavailableRecoveryPrompt(
            unavailableRestaurantIds: unavailable.map { $0.id },
            unavailableNamesAr: unavailable.map { $0.nameAr }.joined(separator: "، "),
            unavailableNamesEn: unavailable.map { $0.nameEn }.joined(separator: ", "),
            remainingRestaurantIds: remainingIds,
            revisedQuote: revised
        )
    }
}

// Extension for Array.removeDuplicates (Kotlin compatibility)
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}