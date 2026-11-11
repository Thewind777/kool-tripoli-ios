import Foundation

// MARK: - Scheduled Offer Engine

/// Peak-hour scheduled delivery discount engine with eligibility evaluation and group consent handling
/// Ported from Kotlin `ScheduledOfferEngine`
public struct ScheduledOfferEngine {

    // MARK: - Eligibility Evaluation

    /// Evaluates if a scheduled offer is eligible for the current cart and restaurants
    public static func evaluateEligibility(
        config: ScheduledOfferConfig,
        cartItems: [CartItem],
        participatingRestaurants: [Restaurant],
        alreadyScheduledSlot: String?,
        declinedOfferIds: Set<String>
    ) -> OfferEligibility {

        if !config.isPeakDemandDemoActive {
            return OfferEligibility(
                isEligible: false,
                ineligibilityReasonAr: "لا يوجد ازدحام ذروة حالياً",
                ineligibilityReasonEn: "Off-peak period — no delayed-slot incentive active",
                isDemoRuleEvaluation: true
            )
        }

        if alreadyScheduledSlot != nil {
            return OfferEligibility(
                isEligible: false,
                ineligibilityReasonAr: "تم تحديد موعد مسبق بالفعل",
                ineligibilityReasonEn: "Order already uses a pre-scheduled slot",
                isDemoRuleEvaluation: true
            )
        }

        if config.candidateSlot.availableCapacity <= 0 {
            return OfferEligibility(
                isEligible: false,
                ineligibilityReasonAr: "اكتملت سعة الفترة المجدولة المقترحة",
                ineligibilityReasonEn: "Candidate scheduled slot has no remaining capacity",
                isDemoRuleEvaluation: true
            )
        }

        let subtotal = cartItems.reduce(0) { $0 + $1.lineTotalLyd }
        if subtotal < config.minEligibleSubtotalLyd {
            return OfferEligibility(
                isEligible: false,
                ineligibilityReasonAr: "الحد الأدنى لقيمة السلة المؤهلة للعرض هو \(config.minEligibleSubtotalLyd) د.ل",
                ineligibilityReasonEn: "Minimum subtotal of \(config.minEligibleSubtotalLyd) LYD required",
                isDemoRuleEvaluation: true
            )
        }

        if participatingRestaurants.isEmpty || participatingRestaurants.contains(where: { !$0.isAvailableForOrdering || !$0.supportsPeakDelayedSlot }) {
            return OfferEligibility(
                isEligible: false,
                ineligibilityReasonAr: "أحد المطاعم المختارة لا يدعم التأجيل لهذه الفترة الزمنية",
                ineligibilityReasonEn: "One or more selected restaurants cannot support the delayed slot",
                isDemoRuleEvaluation: true
            )
        }

        // Deterministic offer ID based on slot + restaurant IDs
        let deterministicOfferId = "peak_\(config.candidateSlot.id)_\(participatingRestaurants.map { $0.id }.joined(separator: "_"))"
        if declinedOfferIds.contains(deterministicOfferId) {
            return OfferEligibility(
                isEligible: false,
                ineligibilityReasonAr: "تم رفض هذا العرض مسبقاً في نفس الطلب",
                ineligibilityReasonEn: "Identical offer was already declined for this order",
                isDemoRuleEvaluation: true
            )
        }

        return OfferEligibility(isEligible: true, isDemoRuleEvaluation: true)
    }

    // MARK: - Build Offer If Eligible

    /// Builds a scheduled offer if all eligibility criteria are met
    public static func buildOfferIfEligible(
        config: ScheduledOfferConfig,
        cartItems: [CartItem],
        participatingRestaurants: [Restaurant],
        fulfillmentMode: FulfillmentMode,
        baseBreakdownWithoutOffer: OrderPriceBreakdown,
        originalEtaMinutes: Int,
        alreadyScheduledSlot: String?,
        declinedOfferIds: Set<String>,
        nowEpochMs: Int64
    ) -> ScheduledOffer? {

        let eligibility = evaluateEligibility(
            config: config,
            cartItems: cartItems,
            participatingRestaurants: participatingRestaurants,
            alreadyScheduledSlot: alreadyScheduledSlot,
            declinedOfferIds: declinedOfferIds
        )
        if !eligibility.isEligible { return nil }

        let eligibleFoodTotal = baseBreakdownWithoutOffer.foodSubtotalLyd + baseBreakdownWithoutOffer.modifiersSubtotalLyd
        let rawSavings = Int((Double(eligibleFoodTotal) * Double(config.discountPercent) / 100.0).rounded())
        let cappedSavings = min(rawSavings, config.maxDiscountCapLyd, eligibleFoodTotal)
        if cappedSavings <= 0 { return nil }

        let expectedFinal = max(0, baseBreakdownWithoutOffer.finalTotalLyd - cappedSavings)
        let offerId = "peak_\(config.candidateSlot.id)_\(participatingRestaurants.map { $0.id }.joined(separator: "_"))"

        let modeWordAr = fulfillmentMode == .pickup ? "الاستلام" : "التوصيل"
        let modeWordEn = fulfillmentMode == .pickup ? "pickup" : "delivery"

        return ScheduledOffer(
            id: offerId,
            discountPercent: config.discountPercent,
            maxDiscountCapLyd: config.maxDiscountCapLyd,
            calculatedSavingsLyd: cappedSavings,
            originalEstimateAr: "\(modeWordAr) فوري خلال ~\(originalEtaMinutes) دقيقة",
            originalEstimateEn: "Immediate \(modeWordEn) in ~\(originalEtaMinutes) min",
            slot: config.candidateSlot,
            applicableToLabelAr: "ينطبق على قيمة الأصناف (بحد أقصى \(config.maxDiscountCapLyd) د.ل)",
            applicableToLabelEn: "Applies to food subtotal (up to \(config.maxDiscountCapLyd) LYD cap)",
            expiresAtEpochMs: nowEpochMs + Int64(config.offerTtlMinutes) * 60_000,
            expectedFinalPriceLyd: expectedFinal,
            isDemoPeakRule: true
        )
    }

    // MARK: - Revalidate Offer Before Payment

    /// Revalidates a scheduled offer before payment (checks expiry, capacity, restaurant availability, group consent)
    public static func revalidateOfferBeforePayment(
        offer: ScheduledOffer,
        config: ScheduledOfferConfig,
        participatingRestaurants: [Restaurant],
        nowEpochMs: Int64,
        groupOrder: GroupOrder? = nil
    ) -> (Bool, (String, String)?) {

        // Check expiry
        if nowEpochMs > offer.expiresAtEpochMs {
            return (false, (
                "انتهت صلاحية عرض الجدولة الزمني؛ تمت إعادة التسعير الأصلي.",
                "Scheduled offer expired; original checkout total restored."
            ))
        }

        // Check capacity and restaurant availability
        if config.candidateSlot.availableCapacity <= 0 ||
           participatingRestaurants.contains(where: { !$0.isAvailableForOrdering || !$0.supportsPeakDelayedSlot }) {
            return (false, (
                "لم تعد الفترة المجدولة متاحة لجميع المطاعم المختارة.",
                "Scheduled slot is no longer supported by all participating kitchens."
            ))
        }

        // Check group consent if applicable
        if let groupOrder = groupOrder {
            let activeParticipants = groupOrder.participants.filter { $0.isActiveInOrder && !$0.items.isEmpty }
            let unconsented = activeParticipants.filter { !$0.isOrganizer && $0.consentedToScheduledOfferId != offer.id }
            if !unconsented.isEmpty {
                return (false, (
                    "يجب موافقة جميع المشاركين في المجموعة على تغيير موعد التسليم أولاً.",
                    "All active group participants must consent to the revised delivery slot first."
                ))
            }
        }

        return (true, nil)
    }
}