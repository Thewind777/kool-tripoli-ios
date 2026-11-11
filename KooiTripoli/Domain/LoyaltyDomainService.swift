import Foundation

// MARK: - Loyalty Domain Service

/// Loyalty wallet domain service for processing orders, awarding stamps/points, reversals, and redemptions
/// Ported from Kotlin `LoyaltyDomainService`
public struct LoyaltyDomainService {

    // MARK: - Card Filtering

    /// Filters loyalty cards by filter type and category
    public static func filterCards(
        cards: [LoyaltyCard],
        filter: LoyaltyFilter,
        selectedCategoryId: String?
    ) -> [LoyaltyCard] {
        return cards.filter { card in
            let categoryMatch = selectedCategoryId == nil ||
                selectedCategoryId == "cat_all" ||
                card.program.category?.id == selectedCategoryId

            let statusMatch: Bool
            switch filter {
            case .all:
                statusMatch = true
            case .active:
                statusMatch = card.currentUnits > 0 && !card.isReadyToRedeem
            case .almostComplete:
                statusMatch = card.isAlmostComplete
            case .readyToRedeem:
                statusMatch = card.isReadyToRedeem
            case .expiringSoon:
                statusMatch = card.isExpiringSoon
            case .redeemed:
                statusMatch = card.redeemedCount > 0
            }

            return categoryMatch && statusMatch
        }
    }

    // MARK: - Process Completed Order

    /// Awards stamps/points ONLY when an eligible order reaches DELIVERED status
    /// Prevents duplicate issuance for the same orderNumber
    public static func processCompletedOrder(
        order: ActiveOrder,
        cards: [LoyaltyCard],
        currentKooiPoints: Int
    ) -> LoyaltyProcessingOutcome {

        if order.orderStatus != .delivered {
            return LoyaltyProcessingOutcome(
                updatedCards: cards,
                newTransactions: [],
                updatedKooiPoints: currentKooiPoints
            )
        }

        var newTransactions: [LoyaltyTransaction] = []
        var nextKooiPoints = currentKooiPoints

        let updatedCards = cards.map { card -> LoyaltyCard in
            let prog = card.program

            // Idempotency guard: never credit the same completed order twice
            if card.creditedOrderIds.contains(order.orderNumber) {
                return card
            }

            // Check if order qualifies for this program
            let qualifies: Bool
            if prog.isKooiWideMembership {
                qualifies = order.foodSubtotalLyd >= prog.minQualifyingOrderLyd
            } else {
                qualifies = (prog.restaurantId != nil && order.restaurantIds.contains(prog.restaurantId!)) &&
                           order.foodSubtotalLyd >= prog.minQualifyingOrderLyd
            }

            if !qualifies { return card }

            // Calculate earned units
            let earnedUnits: Int
            switch prog.ruleType {
            case .stampsPerOrder:
                earnedUnits = 1
            case .pointsPerSpend:
                earnedUnits = max(1, order.foodSubtotalLyd * prog.pointsPerLyd)
            }

            if prog.isKooiWideMembership {
                nextKooiPoints += earnedUnits
            }

            let rawTotalUnits = card.currentUnits + earnedUnits
            let unlockedRewards = rawTotalUnits / prog.targetUnits
            let remainderUnits = rawTotalUnits % prog.targetUnits

            newTransactions.append(LoyaltyTransaction(
                id: "ltx_\(Int64(Date().timeIntervalSince1970 * 1000))_\(prog.id)",
                programId: prog.id,
                orderNumber: order.orderNumber,
                titleAr: "مكافأة طلب مكتمل · \(prog.titleAr)",
                titleEn: "Completed Order Credit · \(prog.titleEn)",
                deltaDescriptionAr: prog.ruleType == .stampsPerOrder ? "+١ ختم" : "+\(earnedUnits) نقطة",
                deltaDescriptionEn: prog.ruleType == .stampsPerOrder ? "+1 stamp" : "+\(earnedUnits) pts",
                timestampLabelAr: "الآن",
                timestampLabelEn: "Just now"
            ))

            return card.copy(
                currentUnits: remainderUnits,
                availableRewardsCount: card.availableRewardsCount + unlockedRewards,
                creditedOrderIds: card.creditedOrderIds.union([order.orderNumber])
            )
        }

        return LoyaltyProcessingOutcome(
            updatedCards: updatedCards,
            newTransactions: newTransactions,
            updatedKooiPoints: nextKooiPoints
        )
    }

    // MARK: - Reverse Cancelled/Refunded Order

    /// Reverses stamps/points if a previously credited order is refunded/cancelled
    public static func reverseCancelledOrRefundedOrder(
        order: ActiveOrder,
        cards: [LoyaltyCard],
        currentKooiPoints: Int
    ) -> LoyaltyProcessingOutcome {

        var newTransactions: [LoyaltyTransaction] = []
        var nextKooiPoints = currentKooiPoints

        let updatedCards = cards.map { card -> LoyaltyCard in
            if !card.creditedOrderIds.contains(order.orderNumber) { return card }

            let prog = card.program
            let unitsToReverse: Int
            switch prog.ruleType {
            case .stampsPerOrder:
                unitsToReverse = 1
            case .pointsPerSpend:
                unitsToReverse = max(1, order.foodSubtotalLyd * prog.pointsPerLyd)
            }

            if prog.isKooiWideMembership {
                nextKooiPoints = max(0, nextKooiPoints - unitsToReverse)
            }

            let totalPool = card.availableRewardsCount * prog.targetUnits + card.currentUnits
            let reducedPool = max(0, totalPool - unitsToReverse)

            newTransactions.append(LoyaltyTransaction(
                id: "ltx_rev_\(Int64(Date().timeIntervalSince1970 * 1000))_\(prog.id)",
                programId: prog.id,
                orderNumber: order.orderNumber,
                titleAr: "عكس مكافأة طلب مسترد · \(prog.titleAr)",
                titleEn: "Refund Reversal · \(prog.titleEn)",
                deltaDescriptionAr: "-\(unitsToReverse)",
                deltaDescriptionEn: "-\(unitsToReverse)",
                timestampLabelAr: "الآن",
                timestampLabelEn: "Just now",
                isReversal: true
            ))

            return card.copy(
                currentUnits: reducedPool % prog.targetUnits,
                availableRewardsCount: reducedPool / prog.targetUnits,
                creditedOrderIds: card.creditedOrderIds.subtracting([order.orderNumber])
            )
        }

        return LoyaltyProcessingOutcome(
            updatedCards: updatedCards,
            newTransactions: newTransactions,
            updatedKooiPoints: nextKooiPoints
        )
    }

    // MARK: - Redeem Card Reward

    /// Redeems a loyalty reward from a card
    public static func redeemCardReward(
        programId: String,
        cards: [LoyaltyCard]
    ) -> (updatedCards: [LoyaltyCard], reward: LoyaltyReward, redemption: Redemption)? {

        guard let target = cards.first(where: { $0.program.id == programId }) else { return nil }
        guard target.isReadyToRedeem else { return nil }

        let prog = target.program
        let updatedCard: LoyaltyCard
        if target.availableRewardsCount > 0 {
            updatedCard = target.copy(
                availableRewardsCount: target.availableRewardsCount - 1,
                redeemedCount: target.redeemedCount + 1
            )
        } else {
            updatedCard = target.copy(
                currentUnits: max(0, target.currentUnits - prog.targetUnits),
                redeemedCount: target.redeemedCount + 1
            )
        }

        let reward = LoyaltyReward(
            id: "rew_\(Int64(Date().timeIntervalSince1970 * 1000))",
            programId: prog.id,
            restaurantId: prog.restaurantId,
            titleAr: prog.rewardTitleAr,
            titleEn: prog.rewardTitleEn,
            discountValueLyd: prog.rewardValueLyd,
            isRedeemed: false
        )

        let redemption = Redemption(
            id: "red_\(Int64(Date().timeIntervalSince1970 * 1000))",
            programId: prog.id,
            rewardTitleAr: prog.rewardTitleAr,
            rewardTitleEn: prog.rewardTitleEn,
            valueLyd: prog.rewardValueLyd,
            redeemedAtLabelAr: "الآن",
            redeemedAtLabelEn: "Just now"
        )

        let nextList = cards.map { $0.program.id == programId ? updatedCard : $0 }
        return (nextList, reward, redemption)
    }
}

// MARK: - Loyalty Processing Outcome

public struct LoyaltyProcessingOutcome {
    public let updatedCards: [LoyaltyCard]
    public let newTransactions: [LoyaltyTransaction]
    public let updatedKooiPoints: Int

    public init(
        updatedCards: [LoyaltyCard],
        newTransactions: [LoyaltyTransaction],
        updatedKooiPoints: Int
    ) {
        self.updatedCards = updatedCards
        self.newTransactions = newTransactions
        self.updatedKooiPoints = updatedKooiPoints
    }
}