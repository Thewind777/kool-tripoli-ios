import Foundation

// MARK: - Wallet Ledger Service

/// Wallet payment gateway boundary & atomic ledger service for transfers, money requests, and QR/link resolution
/// Ported from Kotlin `WalletLedgerService`
public struct WalletLedgerService {

    // MARK: - QR/Link Resolution

    /// Resolves a QR code or deep link to either a recipient contact or a payment request
    public static func resolveQrOrLink(
        rawInput: String,
        contacts: [WalletContact],
        requests: [MoneyRequest],
        nowEpochMs: Int64
    ) -> Result<ResolvedWalletLink, Error> {

        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .failure(WalletError.emptyQrOrLink)
        }

        // Check money request token or link
        if let matchedReq = requests.first(where: { req in
            trimmed == req.tokenInfo.token ||
            trimmed == req.tokenInfo.shareableLink ||
            trimmed == req.tokenInfo.qrPayload ||
            trimmed.hasSuffix("/\(req.tokenInfo.token)")
        }) {
            if matchedReq.tokenInfo.isRevoked || matchedReq.status == .cancelled {
                return .failure(WalletError.requestCancelled)
            }
            if nowEpochMs > matchedReq.tokenInfo.expiresAtEpochMs || matchedReq.status == .expired {
                return .failure(WalletError.requestExpired)
            }
            return .success(.paymentRequestLink(matchedReq))
        }

        // Check contact public receive token or handle
        if let matchedContact = contacts.first(where: { contact in
            trimmed == contact.publicReceiveToken ||
            trimmed.hasSuffix("/\(contact.publicReceiveToken)") ||
            trimmed == "KOOI:USER:\(contact.publicReceiveToken)" ||
            trimmed.caseInsensitiveCompare(contact.handle) == .orderedSame
        }) {
            return .success(.recipientLink(matchedContact))
        }

        return .failure(WalletError.unrecognizedQrOrLink)
    }

    // MARK: - Atomic Transfer

    /// Executes an atomic wallet transfer with idempotency protection
    public static func executeAtomicTransfer(
        ledger: WalletLedgerState,
        recipientId: String,
        amountLyd: Int,
        note: String,
        idempotencyKey: String
    ) -> Result<(WalletLedgerState, MoneyTransfer), Error> {

        if ledger.processedIdempotencyKeys.contains(idempotencyKey) {
            return .failure(WalletError.duplicateTransfer)
        }
        if amountLyd <= 0 {
            return .failure(WalletError.invalidAmount)
        }
        guard let recipient = ledger.contacts.first(where: { $0.id == recipientId }) else {
            return .failure(WalletError.recipientNotFound)
        }
        if ledger.userBalanceLyd < amountLyd {
            return .failure(WalletError.insufficientBalance(available: ledger.userBalanceLyd))
        }

        let refCode = "KTR-\(String(format: "%06d", Int.random(in: 100000...999999)))"
        let updatedUserBalance = ledger.userBalanceLyd - amountLyd
        let updatedContacts = ledger.contacts.map { contact in
            if contact.id == recipientId {
                return contact.copy(balanceLyd: contact.balanceLyd + amountLyd)
            }
            return contact
        }

        let transfer = MoneyTransfer(
            id: "tr_\(Int64(Date().timeIntervalSince1970 * 1000))",
            referenceCode: refCode,
            idempotencyKey: idempotencyKey,
            senderId: "user_self",
            recipientId: recipient.id,
            recipientNameAr: recipient.nameAr,
            recipientNameEn: recipient.nameEn,
            amountLyd: amountLyd,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            status: .completed,
            createdAtLabelAr: "الآن",
            createdAtLabelEn: "Just now",
            isSimulated: true
        )

        let walletTx = WalletTransaction(
            id: transfer.id,
            referenceCode: refCode,
            titleAr: "تحويل محلي (محاكاة) إلى \(recipient.nameAr)",
            titleEn: "Simulated Transfer to \(recipient.nameEn)",
            timeAr: "الآن",
            timeEn: "Just now",
            amountLyd: amountLyd,
            isCredit: false,
            status: .completed,
            isSimulatedDemo: true
        )

        let nextLedger = WalletLedgerState(
            userBalanceLyd: updatedUserBalance,
            contacts: updatedContacts,
            transactions: [walletTx] + ledger.transactions,
            transfers: [transfer] + ledger.transfers,
            requests: ledger.requests,
            processedIdempotencyKeys: ledger.processedIdempotencyKeys.union([idempotencyKey])
        )

        return .success((nextLedger, transfer))
    }

    // MARK: - Create Money Request

    /// Creates a money request (outgoing) with shareable token/QR
    public static func createMoneyRequest(
        ledger: WalletLedgerState,
        requesterNameAr: String,
        requesterNameEn: String,
        amountLyd: Int,
        note: String,
        targetContactId: String?,
        nowEpochMs: Int64,
        ttlMinutes: Int = 120
    ) -> Result<(WalletLedgerState, MoneyRequest), Error> {

        if amountLyd <= 0 {
            return .failure(WalletError.invalidAmount)
        }

        let targetContact = targetContactId.flatMap { id in ledger.contacts.first { $0.id == id } }
        let reqId = "mreq_\(Int64(Date().timeIntervalSince1970 * 1000))"
        let refCode = "KRQ-\(String(format: "%06d", Int.random(in: 100000...999999)))"

        let tokenInfo = SecureTokenGenerator.createMoneyRequestToken(
            requestId: reqId,
            nowEpochMs: nowEpochMs,
            ttlMinutes: ttlMinutes
        )

        let request = MoneyRequest(
            id: reqId,
            referenceCode: refCode,
            requesterId: "user_self",
            requesterNameAr: requesterNameAr,
            requesterNameEn: requesterNameEn,
            payerContactId: targetContact?.id,
            payerNameAr: targetContact?.nameAr,
            payerNameEn: targetContact?.nameEn,
            amountLyd: amountLyd,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            status: .pending,
            tokenInfo: tokenInfo,
            createdAtLabelAr: "الآن",
            createdAtLabelEn: "Just now",
            isIncomingToCurrentUser: false
        )

        return .success((
            ledger.copy(requests: [request] + ledger.requests),
            request
        ))
    }

    // MARK: - Cancel Outgoing Request

    /// Cancels a pending outgoing money request
    public static func cancelOutgoingRequest(
        ledger: WalletLedgerState,
        requestId: String
    ) -> Result<WalletLedgerState, Error> {

        guard let req = ledger.requests.first(where: { $0.id == requestId }) else {
            return .failure(WalletError.requestNotFound)
        }
        if req.status != .pending {
            return .failure(WalletError.onlyPendingCancellable)
        }

        let updated = ledger.requests.map { r in
            if r.id == requestId {
                return r.copy(
                    status: .cancelled,
                    tokenInfo: r.tokenInfo.copy(isRevoked: true)
                )
            }
            return r
        }

        return .success(ledger.copy(requests: updated))
    }

    // MARK: - Settle Money Request

    /// Settles a pending MoneyRequest atomically
    /// - If `isIncomingToCurrentUser == true`: current user pays the requester (deducts user balance, credits contact)
    /// - If `isIncomingToCurrentUser == false`: simulates the invited contact paying current user's request
    public static func settleMoneyRequest(
        ledger: WalletLedgerState,
        requestId: String,
        nowEpochMs: Int64
    ) -> Result<WalletLedgerState, Error> {

        guard let req = ledger.requests.first(where: { $0.id == requestId }) else {
            return .failure(WalletError.requestNotFound)
        }

        let settleKey = "settle_req_\(req.id)"
        if ledger.processedIdempotencyKeys.contains(settleKey) || req.status == .paid {
            return .failure(WalletError.duplicateSettlement)
        }
        if req.status != .pending || req.tokenInfo.isRevoked {
            return .failure(WalletError.requestNotActive(status: req.status))
        }
        if nowEpochMs > req.tokenInfo.expiresAtEpochMs {
            let expiredList = ledger.requests.map { r in
                if r.id == requestId { return r.copy(status: .expired) }
                return r
            }
            return .failure(WalletError.requestExpired)
        }

        if req.isIncomingToCurrentUser {
            // Current user pays the requester
            if ledger.userBalanceLyd < req.amountLyd {
                return .failure(WalletError.insufficientBalance(available: ledger.userBalanceLyd))
            }

            let updatedContacts = ledger.contacts.map { contact in
                if contact.id == req.requesterId {
                    return contact.copy(balanceLyd: contact.balanceLyd + req.amountLyd)
                }
                return contact
            }

            let tx = WalletTransaction(
                id: "tx_req_\(Int64(Date().timeIntervalSince1970 * 1000))",
                referenceCode: req.referenceCode,
                titleAr: "سداد طلب مالي (محاكاة) · \(req.requesterNameAr)",
                titleEn: "Paid Money Request (Simulated) · \(req.requesterNameEn)",
                timeAr: "الآن",
                timeEn: "Just now",
                amountLyd: req.amountLyd,
                isCredit: false,
                status: .completed,
                isSimulatedDemo: true
            )

            let updatedReqs = ledger.requests.map { r in
                if r.id == requestId { return r.copy(status: .paid) }
                return r
            }

            return .success(WalletLedgerState(
                userBalanceLyd: ledger.userBalanceLyd - req.amountLyd,
                contacts: updatedContacts,
                transactions: [tx] + ledger.transactions,
                transfers: ledger.transfers,
                requests: updatedReqs,
                processedIdempotencyKeys: ledger.processedIdempotencyKeys.union([settleKey])
            ))

        } else {
            // Outgoing request paid by contact into current user's simulated wallet
            if let payerId = req.payerContactId,
               let payer = ledger.contacts.first(where: { $0.id == payerId }),
               payer.balanceLyd < req.amountLyd {
                return .failure(WalletError.contactInsufficientBalance)
            }

            let updatedContacts = ledger.contacts.map { contact in
                if let payerId = req.payerContactId, contact.id == payerId {
                    return contact.copy(balanceLyd: max(0, contact.balanceLyd - req.amountLyd))
                }
                return contact
            }

            let tx = WalletTransaction(
                id: "tx_req_in_\(Int64(Date().timeIntervalSince1970 * 1000))",
                referenceCode: req.referenceCode,
                titleAr: "استلام طلب مالي (محاكاة) · \(req.payerNameAr ?? "رابط مشاركة")",
                titleEn: "Received Request Payment (Simulated) · \(req.payerNameEn ?? "Shared Link")",
                timeAr: "الآن",
                timeEn: "Just now",
                amountLyd: req.amountLyd,
                isCredit: true,
                status: .completed,
                isSimulatedDemo: true
            )

            let updatedReqs = ledger.requests.map { r in
                if r.id == requestId { return r.copy(status: .paid) }
                return r
            }

            return .success(WalletLedgerState(
                userBalanceLyd: ledger.userBalanceLyd + req.amountLyd,
                contacts: updatedContacts,
                transactions: [tx] + ledger.transactions,
                transfers: ledger.transfers,
                requests: updatedReqs,
                processedIdempotencyKeys: ledger.processedIdempotencyKeys.union([settleKey])
            ))
        }
    }
}

// MARK: - Wallet Ledger State

/// Complete wallet ledger state for atomic operations
public struct WalletLedgerState {
    public let userBalanceLyd: Int
    public let contacts: [WalletContact]
    public let transactions: [WalletTransaction]
    public let transfers: [MoneyTransfer]
    public let requests: [MoneyRequest]
    public let processedIdempotencyKeys: Set<String>

    public init(
        userBalanceLyd: Int,
        contacts: [WalletContact],
        transactions: [WalletTransaction],
        transfers: [MoneyTransfer],
        requests: [MoneyRequest],
        processedIdempotencyKeys: Set<String> = []
    ) {
        self.userBalanceLyd = userBalanceLyd
        self.contacts = contacts
        self.transactions = transactions
        self.transfers = transfers
        self.requests = requests
        self.processedIdempotencyKeys = processedIdempotencyKeys
    }

    func copy(
        userBalanceLyd: Int? = nil,
        contacts: [WalletContact]? = nil,
        transactions: [WalletTransaction]? = nil,
        transfers: [MoneyTransfer]? = nil,
        requests: [MoneyRequest]? = nil,
        processedIdempotencyKeys: Set<String>? = nil
    ) -> WalletLedgerState {
        WalletLedgerState(
            userBalanceLyd: userBalanceLyd ?? self.userBalanceLyd,
            contacts: contacts ?? self.contacts,
            transactions: transactions ?? self.transactions,
            transfers: transfers ?? self.transfers,
            requests: requests ?? self.requests,
            processedIdempotencyKeys: processedIdempotencyKeys ?? self.processedIdempotencyKeys
        )
    }
}

// MARK: - Resolved Wallet Link

public enum ResolvedWalletLink {
    case recipientLink(WalletContact)
    case paymentRequestLink(MoneyRequest)
}

// MARK: - Wallet Errors

public enum WalletError: LocalizedError {
    case emptyQrOrLink
    case requestCancelled
    case requestExpired
    case unrecognizedQrOrLink
    case duplicateTransfer
    case invalidAmount
    case recipientNotFound
    case insufficientBalance(available: Int)
    case requestNotFound
    case onlyPendingCancellable
    case duplicateSettlement
    case requestNotActive(status: MoneyRequestStatus)
    case contactInsufficientBalance

    public var errorDescription: String? {
        switch self {
        case .emptyQrOrLink: return "Empty QR or link"
        case .requestCancelled: return "This payment request was cancelled"
        case .requestExpired: return "This payment request has expired"
        case .unrecognizedQrOrLink: return "Unrecognized or invalid KOOI QR / payment link"
        case .duplicateTransfer: return "Duplicate transfer prevented"
        case .invalidAmount: return "Transfer amount must be positive"
        case .recipientNotFound: return "Recipient not found"
        case .insufficientBalance(let available): return "Insufficient wallet balance (\(available) LYD available)"
        case .requestNotFound: return "Request not found"
        case .onlyPendingCancellable: return "Only pending requests can be cancelled"
        case .duplicateSettlement: return "Duplicate settlement prevented: request is already paid"
        case .requestNotActive(let status): return "Request is no longer active (\(status.rawValue))"
        case .contactInsufficientBalance: return "Contact has insufficient balance"
        }
    }
}