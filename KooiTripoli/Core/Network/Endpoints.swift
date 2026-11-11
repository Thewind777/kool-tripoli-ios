import Foundation

/// API endpoints and configuration matching the Kotlin `KooiApi` interface
public enum KooiEndpoints {
    // Base URL
    public static let baseURL = "https://www.kool.com.ly/"

    // Endpoint paths
    public static let webserviceShark = "webservice_shark.php"

    // Type parameters for the webservice
    public enum APITypes: String {
        // Auth
        case checkMemberAccount = "CheckMemberAccount"
        case authenticateMember = "AuthenticateMember"
        case sendAuthOtp = "sendAuthOtp"
        case signIn = "signIn"
        case signUp = "signup"
        case forgotPassword = "forgotPassword"
        case resetPassword = "resetPassword"
        case verifyOtp = "verifyOtp"

        // Profile
        case loadProfile = "loadProfile"
        case updateProfile = "updateProfile"
        case uploadAvatar = "uploadAvatar"
        case deleteAccount = "deleteAccount"

        // Static Config
        case countryList = "countryList"
        case loadStaticInfo = "loadStaticInfo"

        // Restaurants & Menu
        case loadAvailableRestaurants = "loadAvailableRestaurants"
        case getRestaurantDetails = "getRestaurantDetails"
        case getStoreDetails = "GetRestaurantDetails"
        case getItemOptionAddonDetails = "GetItemOptionAddonDetails"
        case getMenuItems = "getMenuItems"

        // Food Streets
        case getFoodStreets = "getFoodStreets"
        case getFoodStreetDetails = "getFoodStreetDetails"

        // Wallet
        case getWalletBalance = "GetMemberWalletBalance"
        case getTransactionHistory = "getTransactionHistory"
        case getWalletContacts = "getWalletContacts"
        case addWalletContact = "addWalletContact"
        case removeWalletContact = "removeWalletContact"
        case topUpWallet = "topUpWallet"
        case sendWalletMoney = "sendWalletMoney"
        case createWalletMoneyRequest = "createWalletMoneyRequest"
        case settleWalletMoneyRequest = "settleWalletMoneyRequest"
        case cancelWalletMoneyRequest = "cancelWalletMoneyRequest"
        case getWalletMoneyRequests = "getWalletMoneyRequests"

        // Loyalty
        case getLoyaltyCategories = "getLoyaltyCategories"
        case getLoyaltyPrograms = "getLoyaltyPrograms"
        case getLoyaltyCards = "getLoyaltyCards"
        case getLoyaltyTransactions = "getLoyaltyTransactions"
        case getRedemptions = "getRedemptions"
        case redeemLoyaltyReward = "redeemLoyaltyReward"

        // Orders
        case getOrders = "GetMyOrdersList"
        case getOrderDetails = "GetOrderDetails"
        case getActiveOrder = "getActiveOrder"
        case placeOrder = "placeOrder"
        case cancelOrder = "cancelOrder"
        case rateOrder = "rateOrder"

        // Addresses
        case getAddresses = "GetDriverAddressList"
        case addAddress = "AddDriverAddress"
        case updateAddress = "UpdateDriverAddress"
        case deleteAddress = "DeleteDriverAddress"

        // Notifications
        case getNotifications = "getNewsNotification"
        case markNotificationRead = "markNotificationRead"
        case markAllNotificationsRead = "markAllNotificationsRead"

        // Group Orders
        case createGroupOrder = "createGroupOrder"
        case getGroupOrder = "getGroupOrder"
        case updateGroupOrder = "updateGroupOrder"
        case joinGroupOrder = "joinGroupOrder"
        case leaveGroupOrder = "leaveGroupOrder"
        case lockGroupOrder = "lockGroupOrder"
        case placeGroupOrder = "placeGroupOrder"
        case getGroupQuote = "getGroupQuote"

        // Scheduled Offers
        case getScheduledOfferConfig = "getScheduledOfferConfig"
        case getScheduledOffers = "getScheduledOffers"
        case acceptScheduledOffer = "acceptScheduledOffer"
        case declineScheduledOffer = "declineScheduledOffer"

        // Support
        case submitSupportTicket = "submitSupportTicket"
        case getSupportTickets = "getSupportTickets"

        // Emergency
        case getEmergencyContacts = "loadEmergencyContacts"
        case addEmergencyContact = "addEmergencyContact"
        case deleteEmergencyContact = "deleteEmergencyContacts"
        case triggerEmergency = "triggerEmergency"

        // Preferences
        case getUserPreferences = "getUserPreferences"
        case updateUserPreference = "updateUserPreference"
    }

    // Field names (matching the Kotlin API field names)
    public enum Fields: String {
        case type = "type"
        case vPhone = "vPhone"
        case vCode = "vCode"
        case vPassword = "vPassword"
        case vUserType = "vUserType"
        case vDeviceToken = "vDeviceToken"
        case vDeviceType = "vDeviceType"
        case vAppVersion = "vAppVersion"
        case vName = "vName"
        case vEmail = "vEmail"
        case vOtp = "vOtp"
        case iRefUserId = "iRefUserId"
        case vSessionToken = "vSessionToken"
        case vNameAr = "vNameAr"
        case vNameEn = "vNameEn"
        case vLang = "vLang"
        case iRefRestaurantId = "iRefRestaurantId"
        case iCompanyId = "iCompanyId"
        case iUserId = "iUserId"
        case vCategory = "vCategory"
        case eSystem = "eSystem"
        case CheckNonVegFoodType = "CheckNonVegFoodType"
        case iMenuItemId = "iMenuItemId"
        case vMicroZoneId = "vMicroZoneId"
        case iRefFoodStreetId = "iRefFoodStreetId"
        case iRefUserIdWallet = "iRefUserId"
        case vSessionTokenWallet = "vSessionToken"
        case iPage = "iPage"
        case iLimit = "iLimit"
        case vHandle = "vHandle"
        case fAmount = "fAmount"
        case vPaymentMethod = "vPaymentMethod"
        case vPaymentToken = "vPaymentToken"
        case iRefContactId = "iRefContactId"
        case vNote = "vNote"
        case iRefRequestId = "iRefRequestId"
        case vStatus = "vStatus"
        case vCategoryId = "vCategoryId"
        case iRefProgramId = "iRefProgramId"
        case iRefOrderId = "iRefOrderId"
        case fRating = "fRating"
        case vReviewAr = "vReviewAr"
        case vReviewEn = "vReviewEn"
        case vTitleAr = "vTitleAr"
        case vTitleEn = "vTitleEn"
        case vDistrictAr = "vDistrictAr"
        case vDistrictEn = "vDistrictEn"
        case vDetailsAr = "vDetailsAr"
        case vDetailsEn = "vDetailsEn"
        case iIsDefault = "iIsDefault"
        case iRefAddressId = "iRefAddressId"
        case iRefNotificationId = "iRefNotificationId"
        case vGroupData = "vGroupData"
        case iRefGroupId = "iRefGroupId"
        case vInviteCode = "vInviteCode"
        case iExcludeUnsubmitted = "iExcludeUnsubmitted"
        case vFulfillmentMode = "vFulfillmentMode"
        case vCartData = "vCartData"
        case vAppliedLoyaltyRewardId = "vAppliedLoyaltyRewardId"
        case vOrderingScope = "vOrderingScope"
        case vParticipationMode = "vParticipationMode"
        case vScheduledSlot = "vScheduledSlot"
        case iRefOfferId = "iRefOfferId"
        case vSubjectAr = "vSubjectAr"
        case vSubjectEn = "vSubjectEn"
        case vBodyAr = "vBodyAr"
        case vBodyEn = "vBodyEn"
        case vCategory = "vCategory"
        case vRelationshipAr = "vRelationshipAr"
        case vRelationshipEn = "vRelationshipEn"
        case vLatitude = "vLatitude"
        case vLongitude = "vLongitude"
        case vAddress = "vAddress"
        case vKey = "vKey"
        case vValue = "vValue"
        case cuisineId = "cuisineId"
        case iCategoryId = "iCategoryId"
        case vAddressPassenger = "vAddress"
        case UserType = "UserType"
        case page = "page"
        case PassengerLat = "PassengerLat"
        case PassengerLon = "PassengerLon"
    }

    // HTTP Headers
    public enum Headers: String {
        case accept = "Accept"
        case contentType = "Content-Type"
        case userAgent = "User-Agent"
        case xSessionToken = "X-Session-Token"
    }

    public static let defaultHeaders: [String: String] = [
        Headers.accept.rawValue: "application/json",
        Headers.contentType.rawValue: "application/x-www-form-urlencoded",
        Headers.userAgent.rawValue: "KOOI-iOS/1.0.0 (iOS)"
    ]

    // User Types
    public enum UserType: String {
        case passenger = "Passenger"
        case driver = "Driver"
    }

    // Systems
    public enum System: String {
        case deliverAll = "DeliverAll"
    }
}

/// API error matching the Kotlin `KooiApiResponse.Error`
public struct KooiAPIError: Error, Codable, Equatable {
    public let code: String
    public let messageAr: String
    public let messageEn: String
    public let raw: [String: Any]?

    public init(code: String, messageAr: String, messageEn: String, raw: [String: Any]? = nil) {
        self.code = code
        self.messageAr = messageAr
        self.messageEn = messageEn
        self.raw = raw
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case code, messageAr, messageEn
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        messageAr = try container.decode(String.self, forKey: .messageAr)
        messageEn = try container.decode(String.self, forKey: .messageEn)
        raw = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(messageAr, forKey: .messageAr)
        try container.encode(messageEn, forKey: .messageEn)
    }

    public static func == (lhs: KooiAPIError, rhs: KooiAPIError) -> Bool {
        lhs.code == rhs.code && lhs.messageAr == rhs.messageAr && lhs.messageEn == rhs.messageEn
    }
}

/// API response envelope matching the Kotlin `KooiApiResponse`
public enum KooiAPIResponse<T: Codable>: Codable {
    case success(T)
    case failure(KooiAPIError)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Try to decode as success first
        if let data = try? container.decode(T.self) {
            self = .success(data)
        } else if let error = try? container.decode(KooiAPIError.self) {
            self = .failure(error)
        } else {
            // Try to parse the raw JSON to determine success/failure
            let json = try container.decode([String: AnyCodable].self)
            if let action = json["Action"]?.value as? String, action == "1" {
                if let message = json["message"]?.value as? String {
                    // Parse message as the data payload
                    if let data = try? JSONDecoder().decode(T.self, from: Data(message.utf8)) {
                        self = .success(data)
                    } else {
                        self = .failure(KooiAPIError(code: "PARSE_ERROR", messageAr: "فشل تحليل البيانات", messageEn: "Failed to parse data"))
                    }
                } else {
                    self = .failure(KooiAPIError(code: "API_ERROR", messageAr: "استجابة غير صالحة", messageEn: "Invalid response"))
                }
            } else {
                let message = json["message"]?.value as? String ?? "Unknown error"
                self = .failure(KooiAPIError(code: "API_ERROR", messageAr: message, messageEn: message))
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .success(let data):
            try container.encode(data)
        case .failure(let error):
            try container.encode(error)
        }
    }
}

/// Helper for decoding Any values in JSON
public struct AnyCodable: Codable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intVal as Int:
            try container.encode(intVal)
        case let doubleVal as Double:
            try container.encode(doubleVal)
        case let stringVal as String:
            try container.encode(stringVal)
        case let boolVal as Bool:
            try container.encode(boolVal)
        case let arrayVal as [Any]:
            try container.encode(arrayVal.map { AnyCodable($0) })
        case let dictVal as [String: Any]:
            try container.encode(dictVal.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}