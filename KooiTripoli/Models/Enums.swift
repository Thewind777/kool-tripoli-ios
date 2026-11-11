import Foundation
import SwiftData

/// Primary tab enumeration matching the Kotlin `PrimaryTab`
public enum PrimaryTab: String, CaseIterable, Identifiable, Codable {
    case home = "HOME"
    case restaurants = "RESTAURANTS"
    case foodStreets = "FOOD_STREETS"
    case circle = "CIRCLE"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .home: return "الرئيسية"
        case .restaurants: return "المطاعم"
        case .foodStreets: return "شوارع الطعام"
        case .circle: return "الولاء"
        }
    }

    public var labelEn: String {
        switch self {
        case .home: return "Home"
        case .restaurants: return "Restaurants"
        case .foodStreets: return "Streets"
        case .circle: return "Loyalty"
        }
    }
}

/// Restaurant collection filter matching the Kotlin `RestaurantCollectionFilter`
public enum RestaurantCollectionFilter: String, CaseIterable, Identifiable, Codable {
    case all = "ALL"
    case offers = "OFFERS"
    case recommended = "RECOMMENDED"
    case popular = "POPULAR"
    case new = "NEW"
    case nearby = "NEARBY"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .all: return "الكل"
        case .offers: return "العروض"
        case .recommended: return "مقترحة لك"
        case .popular: return "الأكثر شعبية"
        case .new: return "جديد في كوي"
        case .nearby: return "قريبة منك"
        }
    }

    public var labelEn: String {
        switch self {
        case .all: return "All"
        case .offers: return "Offers"
        case .recommended: return "Recommended"
        case .popular: return "Popular"
        case .new: return "New"
        case .nearby: return "Nearby"
        }
    }

    public var subtitleAr: String {
        switch self {
        case .all: return "جميع مطاعم طرابلس المتاحة الآن"
        case .offers: return "مطاعم تقدم خصومات وعروض توصيل حصرية"
        case .recommended: return "اختيارات منسّقة بعناية لذوقك في طرابلس"
        case .popular: return "الأعلى تقييماً والأكثر طلباً هذا الأسبوع"
        case .new: return "مطاعم ومطابخ انضمت حديثاً إلى كوي"
        case .nearby: return "توصيل سريع خلال دقائق في محيط منطقتك"
        }
    }

    public var subtitleEn: String {
        switch self {
        case .all: return "All available Tripoli kitchens"
        case .offers: return "Restaurants with active discounts and deals"
        case .recommended: return "Handpicked Tripoli spots tailored for you"
        case .popular: return "Highest-rated & most ordered this week"
        case .new: return "Freshly launched kitchens on KOOI"
        case .nearby: return "Fast delivery within 2.5 km of your location"
        }
    }
}

/// Food category matching the Kotlin `FoodCategory`
public enum FoodCategory: String, CaseIterable, Identifiable, Codable {
    case all = "ALL"
    case pizza = "PIZZA"
    case burger = "BURGER"
    case libyan = "LIBYAN"
    case grill = "GRILL"
    case sushi = "SUSHI"
    case sweets = "SWEETS"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .all: return "الكل"
        case .pizza: return "بيتزا حطب"
        case .burger: return "برجر"
        case .libyan: return "مطبخ ليبي"
        case .grill: return "مشويات"
        case .sushi: return "سوشي وبحري"
        case .sweets: return "حلويات وقهوة"
        }
    }

    public var labelEn: String {
        switch self {
        case .all: return "All"
        case .pizza: return "Pizza"
        case .burger: return "Burgers"
        case .libyan: return "Libyan"
        case .grill: return "Grill"
        case .sushi: return "Sushi & Sea"
        case .sweets: return "Sweets"
        }
    }

    /// Maps a live backend cuisine label onto one of the app's discovery categories
    public static func fromLiveCuisine(_ cuisine: String) -> FoodCategory {
        let label = cuisine.trimmingCharacters(in: .whitespacesAndNewlines)
        if label.isEmpty { return .all }

        let lowercased = label.lowercased()
        if lowercased.contains("بيتزا") || lowercased.contains("إيطالي") || lowercased.contains("معجنات") || lowercased.contains("فطائر") {
            return .pizza
        }
        if lowercased.contains("برجر") || lowercased.contains("ساندويتش") || lowercased.contains("دجاج") || lowercased.contains("فرايد") {
            return .burger
        }
        if lowercased.contains("شعبي") || lowercased.contains("ليبي") || lowercased.contains("مطبخ") || lowercased.contains("بيت") || lowercased.contains("مندي") || lowercased.contains("كسكسي") {
            return .libyan
        }
        if lowercased.contains("مشوي") || lowercased.contains("شواية") || lowercased.contains("كباب") || lowercased.contains("لحم") || lowercased.contains("مشويات") || lowercased.contains("شاورما") || lowercased.contains("شرقي") {
            return .grill
        }
        if lowercased.contains("بحر") || lowercased.contains("سمك") || lowercased.contains("سوشي") {
            return .sushi
        }
        if lowercased.contains("حلو") || lowercased.contains("قهوة") || lowercased.contains("كيك") || lowercased.contains("مخبز") || lowercased.contains("مخبوزات") || lowercased.contains("آيس") || lowercased.contains("عصير") || lowercased.contains("مقهى") {
            return .sweets
        }
        return .all
    }
}

/// Dish art type matching the Kotlin `DishArtType`
public enum DishArtType: String, CaseIterable, Identifiable, Codable {
    case burgerCombo = "BURGER_COMBO"
    case burgerStudio = "BURGER_STUDIO"
    case woodfiredPizza = "WOODFIRED_PIZZA"
    case sushiPlatter = "SUSHI_PLATTER"
    case tripoliMbatten = "TRIPOLI_MBATTEN"
    case seafoodCouscous = "SEAFOOD_COUSCOUS"
    case pistachioKunafa = "PISTACHIO_KUNAFA"
    case lambKoftaGrill = "LAMB_KOFTA_GRILL"

    public var id: String { rawValue }

    /// Asset key for the dish illustration
    public var assetKey: String {
        switch self {
        case .burgerCombo: return "cat_smash_burger"
        case .burgerStudio: return "cat_smash_burger"
        case .woodfiredPizza: return "cat_wood_pizza"
        case .sushiPlatter: return "cat_sushi_coastal"
        case .tripoliMbatten: return "cat_libyan_heritage"
        case .seafoodCouscous: return "cat_sushi_coastal"
        case .pistachioKunafa: return "cat_sweets_coffee"
        case .lambKoftaGrill: return "cat_charcoal_grill"
        }
    }
}

/// Restaurant operational status matching the Kotlin `RestaurantOperationalStatus`
public enum RestaurantOperationalStatus: String, CaseIterable, Identifiable, Codable {
    case open = "OPEN"
    case closingSoon = "CLOSING_SOON"
    case capacityLimited = "CAPACITY_LIMITED"
    case temporarilyUnavailable = "TEMPORARILY_UNAVAILABLE"
    case closed = "CLOSED"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .open: return "مفتوح الآن"
        case .closingSoon: return "يغلق قريباً"
        case .capacityLimited: return "ضغط تحضير مرتفع"
        case .temporarilyUnavailable: return "متوقف مؤقتاً"
        case .closed: return "مغلق حالياً"
        }
    }

    public var labelEn: String {
        switch self {
        case .open: return "Open Now"
        case .closingSoon: return "Closing Soon"
        case .capacityLimited: return "High Kitchen Load"
        case .temporarilyUnavailable: return "Temporarily Paused"
        case .closed: return "Closed"
        }
    }

    public var canAcceptNewOrders: Bool {
        switch self {
        case .open, .closingSoon, .capacityLimited: return true
        case .temporarilyUnavailable, .closed: return false
        }
    }
}

/// Fulfillment mode matching the Kotlin `FulfillmentMode`
public enum FulfillmentMode: String, CaseIterable, Identifiable, Codable {
    case delivery = "DELIVERY"
    case pickup = "PICKUP"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .delivery: return "توصيل"
        case .pickup: return "استلام من المطعم"
        }
    }

    public var labelEn: String {
        switch self {
        case .delivery: return "Delivery"
        case .pickup: return "Pickup"
        }
    }
}

/// Ordering scope matching the Kotlin `OrderingScope`
public enum OrderingScope: String, CaseIterable, Identifiable, Codable {
    case singleRestaurant = "SINGLE_RESTAURANT"
    case multiRestaurant = "MULTI_RESTAURANT"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .singleRestaurant: return "مطعم واحد"
        case .multiRestaurant: return "عدة مطاعم (شارع طعام)"
        }
    }

    public var labelEn: String {
        switch self {
        case .singleRestaurant: return "Single Restaurant"
        case .multiRestaurant: return "Multi-Restaurant (Food Street)"
        }
    }
}

/// Participation mode matching the Kotlin `ParticipationMode`
public enum ParticipationMode: String, CaseIterable, Identifiable, Codable {
    case individual = "INDIVIDUAL"
    case group = "GROUP"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .individual: return "طلب فردي"
        case .group: return "طلب جماعي"
        }
    }

    public var labelEn: String {
        switch self {
        case .individual: return "Individual"
        case .group: return "Group Order"
        }
    }
}

/// Payment method matching the Kotlin `PaymentMethod`
public enum PaymentMethod: String, CaseIterable, Identifiable, Codable {
    case cashOnDelivery = "CASH_ON_DELIVERY"
    case kooiWallet = "KOOI_WALLET"
    case localCard = "LOCAL_CARD"
    case askFriendToPay = "ASK_FRIEND_TO_PAY"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .cashOnDelivery: return "الدفع نقداً عند الاستلام"
        case .kooiWallet: return "رصيد محفظة كوي"
        case .localCard: return "بطاقة مصرفية محلية / سداد (محاكاة)"
        case .askFriendToPay: return "اطلب من صديق الدفع عنك"
        }
    }

    public var labelEn: String {
        switch self {
        case .cashOnDelivery: return "Cash on Delivery (LYD)"
        case .kooiWallet: return "KOOI Wallet Balance"
        case .localCard: return "Local Bank Card / Sadad (Simulated)"
        case .askFriendToPay: return "Ask Friend to Pay"
        }
    }

    public var subtitleAr: String {
        switch self {
        case .cashOnDelivery: return "ادفع مباشرة للمندوب عند وصول الطلب"
        case .kooiWallet: return "خصم فوري من الرصيد المحلي بدون رسوم إضافية"
        case .localCard: return "بوابة دفع محلية تجريبية للتحقق من التدفق"
        case .askFriendToPay: return "اختر مشاركاً من المجموعة ليدفع حصتك"
        }
    }

    public var subtitleEn: String {
        switch self {
        case .cashOnDelivery: return "Pay courier directly upon arrival"
        case .kooiWallet: return "Instant deduction from wallet balance"
        case .localCard: return "Local prototype payment authorization"
        case .askFriendToPay: return "Select a group member to pay your share"
        }
    }

    public var supportsIndependentSplitShare: Bool {
        switch self {
        case .cashOnDelivery: return false
        case .kooiWallet: return true
        case .localCard: return true
        case .askFriendToPay: return false
        }
    }
}

/// Tracking stage matching the Kotlin `TrackingStage`
public enum TrackingStage: Int, CaseIterable, Identifiable, Codable {
    case confirmed = 0
    case preparing = 1
    case onTheWay = 2
    case arriving = 3

    public var id: Int { rawValue }

    public var titleAr: String {
        switch self {
        case .confirmed: return "تم تأكيد الطلب"
        case .preparing: return "قيد التحضير في المطبخ"
        case .onTheWay: return "المندوب في الطريق إليك"
        case .arriving: return "تم التسليم / جاهز للاستلام"
        }
    }

    public var titleEn: String {
        switch self {
        case .confirmed: return "Order Confirmed"
        case .preparing: return "Preparing Fresh"
        case .onTheWay: return "Courier En Route"
        case .arriving: return "Delivered / Ready"
        }
    }

    public var detailAr: String {
        switch self {
        case .confirmed: return "استلم المطبخ طلبك وبدأ التجهيز الفوري"
        case .preparing: return "يتم تجهيز أطباقك وتغليفها حرارياً"
        case .onTheWay: return "تتبع محلي تجريبي: المندوب في طريقه لعنوانك"
        case .arriving: return "اكتمل الطلب بنجاح، نتمنى لك وجبة شهية!"
        }
    }

    public var detailEn: String {
        switch self {
        case .confirmed: return "Kitchen received your order and started prep"
        case .preparing: return "Dishes are being cooked & thermally packed"
        case .onTheWay: return "Simulated local status: Courier heading to your address"
        case .arriving: return "Order fulfilled — enjoy your meal!"
        }
    }
}

/// Order status matching the Kotlin `OrderStatus`
public enum OrderStatus: String, CaseIterable, Identifiable, Codable {
    case orderCreated = "ORDER_CREATED"
    case paymentPending = "PAYMENT_PENDING"
    case paymentConfirmed = "PAYMENT_CONFIRMED"
    case restaurantConfirmationPending = "RESTAURANT_CONFIRMATION_PENDING"
    case restaurantAccepted = "RESTAURANT_ACCEPTED"
    case preparing = "PREPARING"
    case readyForPickup = "READY_FOR_PICKUP"
    case courierAssigned = "COURIER_ASSIGNED"
    case collected = "COLLECTED"
    case enRoute = "EN_ROUTE"
    case delivered = "DELIVERED"
    case cancelled = "CANCELLED"
    case partiallyFulfilled = "PARTIALLY_FULFILLED"

    public var id: String { rawValue }

    public var labelAr: String {
        switch self {
        case .orderCreated: return "تم إنشاء الطلب"
        case .paymentPending: return "بانتظار تأكيد الدفع"
        case .paymentConfirmed: return "تم تأكيد الدفع"
        case .restaurantConfirmationPending: return "بانتظار قبول المطعم"
        case .restaurantAccepted: return "قبِل المطعم الطلب"
        case .preparing: return "قيد التحضير"
        case .readyForPickup: return "جاهز للاستلام"
        case .courierAssigned: return "تم تعيين المندوب"
        case .collected: return "استلم المندوب الطلب"
        case .enRoute: return "في الطريق إليك"
        case .delivered: return "تم التوصيل والاستلام"
        case .cancelled: return "ملغي"
        case .partiallyFulfilled: return "مكتمل جزئياً"
        }
    }

    public var labelEn: String {
        switch self {
        case .orderCreated: return "Order Created"
        case .paymentPending: return "Payment Pending"
        case .paymentConfirmed: return "Payment Confirmed"
        case .restaurantConfirmationPending: return "Awaiting Kitchen Acceptance"
        case .restaurantAccepted: return "Restaurant Accepted"
        case .preparing: return "Preparing"
        case .readyForPickup: return "Ready for Pickup"
        case .courierAssigned: return "Courier Assigned"
        case .collected: return "Collected by Courier"
        case .enRoute: return "En Route"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        case .partiallyFulfilled: return "Partially Fulfilled"
        }
    }

    public var isTerminal: Bool {
        switch self {
        case .delivered, .cancelled, .partiallyFulfilled: return true
        default: return false
        }
    }
}