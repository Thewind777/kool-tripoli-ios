import Foundation

// MARK: - Group Order State Machine & Split-Share Allocation Engine

/// State machine for group order lifecycle and payment allocation logic
/// Ported from Kotlin `GroupOrderStateMachine`
public struct GroupOrderStateMachine {

    // MARK: - State Transitions

    /// Validates if a state transition is allowed
    public static func canTransition(from: GroupStatus, to: GroupStatus) -> Bool {
        if from == to { return false }
        switch from {
        case .draft:
            return [.open, .cancelled].contains(to)
        case .open:
            return [.locked, .cancelled, .expired].contains(to)
        case .locked:
            return [.open, .awaitingPayment, .readyToPlace, .cancelled, .expired].contains(to)
        case .awaitingPayment:
            return [.locked, .readyToPlace, .cancelled, .expired].contains(to)
        case .readyToPlace:
            return [.placed, .locked, .cancelled].contains(to)
        case .placed:
            return [.completed, .cancelled].contains(to)
        case .completed, .cancelled, .expired:
            return false
        }
    }

    /// Checks if a participant's basket is editable
    public static func isParticipantBasketEditable(group: GroupOrder, participantId: String) -> Bool {
        guard group.status == .open else { return false }
        guard let participant = group.participants.first(where: { $0.id == participantId }) else { return false }
        return participant.isActiveInOrder && participant.status != .paid
    }

    /// Returns permitted payment methods for a group based on payment mode
    public static func permittedPaymentMethodsForGroup(paymentMode: GroupPaymentMode) -> [PaymentMethod] {
        switch paymentMode {
        case .organizerPays:
            return PaymentMethod.allCases
        case .everyonePaysOwnShare:
            return PaymentMethod.allCases.filter { $0.supportsIndependentSplitShare }
        }
    }

    /// Combines all participant cart items into a unified list for order placement
    public static func groupCombinedCartItems(group: GroupOrder) -> [CartItem] {
        return group.participants
            .filter { $0.isActiveInOrder }
            .flatMap { participant in
                participant.items.map { gItem in
                    CartItem(
                        id: gItem.id,
                        menuItem: gItem.menuItem,
                        quantity: gItem.quantity,
                        note: gItem.customizationNote,
                        modifierExtraLyd: gItem.modifierExtraLyd,
                        quotedUnitPriceLyd: gItem.quotedUnitPriceLyd,
                        participantId: participant.id
                    )
                }
            }
    }

    // MARK: - Payment Allocation

    /// Calculates payment allocations for all active participants based on fee allocation mode
    public static func calculateAllocations(
        group: GroupOrder,
        breakdown: OrderPriceBreakdown
    ) -> [GroupPaymentAllocation] {

        let activeWithItems = group.participants.filter { $0.isActiveInOrder && !$0.items.isEmpty }
        if activeWithItems.isEmpty { return [] }

        let totalItemsSubtotal = activeWithItems.reduce(0) { $0 + $1.itemsSubtotalLyd }.coerceAtLeast(1)
        let totalSharedFees = breakdown.baseDeliveryFeeLyd + breakdown.coordinationFeesLyd + breakdown.serviceFeeLyd
        let totalDiscounts = breakdown.totalDiscountsLyd

        var allocatedFeesSoFar = 0
        var allocatedDiscountSoFar = 0

        return activeWithItems.enumerated().map { index, participant in
            let isLast = index == activeWithItems.count - 1
            let sub = participant.itemsSubtotalLyd

            // Fee allocation based on group mode
            let feeShare: Int
            switch group.feeAllocationMode {
            case .organizerPaysFees:
                feeShare = (participant.id == group.organizerId) ? totalSharedFees : 0
            case .proportionalBySubtotal:
                if isLast {
                    feeShare = max(0, totalSharedFees - allocatedFeesSoFar)
                } else {
                    let raw = Int((Double(totalSharedFees) * Double(sub) / Double(totalItemsSubtotal)).rounded())
                    allocatedFeesSoFar += raw
                    feeShare = raw
                }
            }

            // Discount allocation (proportional)
            let discountShare: Int
            if totalDiscounts == 0 {
                discountShare = 0
            } else if isLast {
                discountShare = max(0, totalDiscounts - allocatedDiscountSoFar)
            } else {
                let raw = Int((Double(totalDiscounts) * Double(sub) / Double(totalItemsSubtotal)).rounded())
                allocatedDiscountSoFar += raw
                discountShare = raw
            }

            let due = max(0, sub + feeShare - discountShare)
            let isPaid = participant.status == .paid && participant.paidAmountLyd >= due

            return GroupPaymentAllocation(
                participantId: participant.id,
                participantNameAr: participant.nameAr,
                participantNameEn: participant.nameEn,
                itemsSubtotalLyd: sub,
                allocatedSharedFeesLyd: feeShare,
                allocatedDiscountLyd: discountShare,
                totalDueLyd: due,
                isPaid: isPaid
            )
        }
    }

    // MARK: - Lock Group for Checkout

    /// Locks the group and prepares for checkout, transitioning to appropriate next state
    public static func lockGroupAndPrepareCheckout(
        group: GroupOrder,
        excludeUnsubmitted: Bool
    ) -> GroupOrder {

        guard canTransition(from: group.status, to: .locked) else { return group }

        let updatedParticipants = group.participants.map { participant in
            if !participant.isActiveInOrder { return participant }

            if excludeUnsubmitted &&
               participant.status != .submitted &&
               participant.status != .paid &&
               !participant.isOrganizer {
                return participant.copy(
                    status: .removed,
                    items: []
                )
            }

            if !participant.items.isEmpty && participant.status != .paid {
                let nextStatus: ParticipantStatus = (group.paymentMode == .everyonePaysOwnShare)
                    ? .paymentPending
                    : .submitted
                return participant.copy(status: nextStatus)
            }
            return participant
        }

        let hasItems = updatedParticipants.contains { $0.isActiveInOrder && !$0.items.isEmpty }
        let nextGroupStatus: GroupStatus = {
            if !hasItems { return .locked }
            if group.paymentMode == .organizerPays { return .readyToPlace }
            return .awaitingPayment
        }()

        let log = GroupActivity(
            id: "act_\(Int64(Date().timeIntervalSince1970 * 1000))",
            timestampLabelAr: "الآن",
            timestampLabelEn: "Just now",
            messageAr: "أقفل المنظم السلة الجماعية للمراجعة والدفع",
            messageEn: "Organizer locked group basket for checkout"
        )

        return group.copy(
            status: nextGroupStatus,
            participants: updatedParticipants,
            activities: [log] + group.activities
        )
    }

    // MARK: - Record Participant Share Payment

    /// Records a participant's share payment in a split-share group
    public static func recordParticipantSharePayment(
        group: GroupOrder,
        participantId: String,
        method: PaymentMethod,
        dueAmountLyd: Int,
        simulateFailure: Bool = false
    ) -> Result<GroupOrder, Error> {

        guard group.paymentMode == .everyonePaysOwnShare else {
            return .failure(GroupOrderError.organizerPaysMode)
        }
        guard method.supportsIndependentSplitShare else {
            return .failure(GroupOrderError.cashOnDeliveryNotAllowed)
        }
        guard [.awaitingPayment, .locked].contains(group.status) else {
            return .failure(GroupOrderError.notAwaitingSplitPayments)
        }

        guard let target = group.participants.first(where: { $0.id == participantId }) else {
            return .failure(GroupOrderError.participantNotFound)
        }
        guard target.status != .paid else {
            return .failure(GroupOrderError.duplicatePayment)
        }

        if simulateFailure {
            let failedParticipants = group.participants.map { p -> GroupParticipant in
                if p.id == participantId {
                    return p.copy(
                        status: .paymentPending,
                        selectedPaymentMethod: method,
                        lastPaymentErrorAr: "تعذر تفويض الدفع (محاكاة) — يرجى المحاولة مجدداً أو اختيار وسيلة أخرى",
                        lastPaymentErrorEn: "Simulated authorization declined — retry or pick another method"
                    )
                }
                return p
            }
            let log = GroupActivity(
                id: "act_\(Int64(Date().timeIntervalSince1970 * 1000))",
                timestampLabelAr: "الآن",
                timestampLabelEn: "Just now",
                messageAr: "فشلت محاولة دفع حصة \(target.nameAr)",
                messageEn: "Payment attempt failed for \(target.nameEn)"
            )
            return .success(group.copy(
                participants: failedParticipants,
                activities: [log] + group.activities
            ))
        }

        let updatedParticipants = group.participants.map { p -> GroupParticipant in
            if p.id == participantId {
                return p.copy(
                    status: .paid,
                    selectedPaymentMethod: method,
                    paidAmountLyd: dueAmountLyd,
                    lastPaymentErrorAr: nil,
                    lastPaymentErrorEn: nil
                )
            }
            return p
        }

        let allActivePaid = updatedParticipants
            .filter { $0.isActiveInOrder && !$0.items.isEmpty }
            .allSatisfy { $0.status == .paid }

        let nextStatus = allActivePaid ? GroupStatus.readyToPlace : GroupStatus.awaitingPayment

        let log = GroupActivity(
            id: "act_\(Int64(Date().timeIntervalSince1970 * 1000))",
            timestampLabelAr: "الآن",
            timestampLabelEn: "Just now",
            messageAr: "سدد \(target.nameAr) حصته (\(dueAmountLyd) د.ل)",
            messageEn: "\(target.nameEn) paid their share (\(dueAmountLyd) LYD)"
        )

        return .success(group.copy(
            status: nextStatus,
            participants: updatedParticipants,
            activities: [log] + group.activities
        ))
    }
}

// MARK: - Group Order Errors

public enum GroupOrderError: LocalizedError {
    case organizerPaysMode
    case cashOnDeliveryNotAllowed
    case notAwaitingSplitPayments
    case participantNotFound
    case duplicatePayment

    public var errorDescription: String? {
        switch self {
        case .organizerPaysMode: return "Group uses organizer-pays mode"
        case .cashOnDeliveryNotAllowed: return "Cash on Delivery cannot be used for individual split shares"
        case .notAwaitingSplitPayments: return "Group is not awaiting split payments"
        case .participantNotFound: return "Participant not found"
        case .duplicatePayment: return "Duplicate payment prevented: participant already paid"
        }
    }
}