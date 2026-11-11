import Foundation
import SwiftData

/// Menu modifier option matching the Kotlin `MenuModifierOption`
@Model
public final class MenuModifierOption: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var labelAr: String
    public var labelEn: String
    public var extraPriceLyd: Int
    public var isAvailable: Bool
    public var modifierType: String // "Addon" or "Options"
    public var isDefault: Bool

    public init(
        id: String,
        labelAr: String,
        labelEn: String,
        extraPriceLyd: Int = 0,
        isAvailable: Bool = true,
        modifierType: String = "Options",
        isDefault: Bool = false
    ) {
        self.id = id
        self.labelAr = labelAr
        self.labelEn = labelEn
        self.extraPriceLyd = extraPriceLyd
        self.isAvailable = isAvailable
        self.modifierType = modifierType
        self.isDefault = isDefault
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, labelAr, labelEn, extraPriceLyd, isAvailable, modifierType, isDefault
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        labelAr = try container.decode(String.self, forKey: .labelAr)
        labelEn = try container.decode(String.self, forKey: .labelEn)
        extraPriceLyd = try container.decode(Int.self, forKey: .extraPriceLyd)
        isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
        modifierType = try container.decode(String.self, forKey: .modifierType)
        isDefault = try container.decode(Bool.self, forKey: .isDefault)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(labelAr, forKey: .labelAr)
        try container.encode(labelEn, forKey: .labelEn)
        try container.encode(extraPriceLyd, forKey: .extraPriceLyd)
        try container.encode(isAvailable, forKey: .isAvailable)
        try container.encode(modifierType, forKey: .modifierType)
        try container.encode(isDefault, forKey: .isDefault)
    }
}

/// Menu item option category matching the Kotlin `MenuItemOptionCategory`
@Model
public final class MenuItemOptionCategory: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var nameAr: String
    public var nameEn: String
    public var categoryType: String // "Addon" or "Options"
    public var addonTitleAr: String
    public var addonTitleEn: String
    public var optionTitleAr: String
    public var optionTitleEn: String
    @Relationship(deleteRule: .cascade) public var options: [MenuModifierOption]

    public init(
        id: String,
        nameAr: String,
        nameEn: String,
        categoryType: String,
        addonTitleAr: String,
        addonTitleEn: String,
        optionTitleAr: String,
        optionTitleEn: String,
        options: [MenuModifierOption] = []
    ) {
        self.id = id
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.categoryType = categoryType
        self.addonTitleAr = addonTitleAr
        self.addonTitleEn = addonTitleEn
        self.optionTitleAr = optionTitleAr
        self.optionTitleEn = optionTitleEn
        self.options = options
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, nameAr, nameEn, categoryType, addonTitleAr, addonTitleEn, optionTitleAr, optionTitleEn, options
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        nameAr = try container.decode(String.self, forKey: .nameAr)
        nameEn = try container.decode(String.self, forKey: .nameEn)
        categoryType = try container.decode(String.self, forKey: .categoryType)
        addonTitleAr = try container.decode(String.self, forKey: .addonTitleAr)
        addonTitleEn = try container.decode(String.self, forKey: .addonTitleEn)
        optionTitleAr = try container.decode(String.self, forKey: .optionTitleAr)
        optionTitleEn = try container.decode(String.self, forKey: .optionTitleEn)
        options = try container.decode([MenuModifierOption].self, forKey: .options)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nameAr, forKey: .nameAr)
        try container.encode(nameEn, forKey: .nameEn)
        try container.encode(categoryType, forKey: .categoryType)
        try container.encode(addonTitleAr, forKey: .addonTitleAr)
        try container.encode(addonTitleEn, forKey: .addonTitleEn)
        try container.encode(optionTitleAr, forKey: .optionTitleAr)
        try container.encode(optionTitleEn, forKey: .optionTitleEn)
        try container.encode(options, forKey: .options)
    }
}

/// Full options/addons structure for a menu item matching the Kotlin `MenuItemOptions`
@Model
public final class MenuItemOptions: Codable {
    @Relationship(deleteRule: .cascade) public var categories: [MenuItemOptionCategory]

    public init(categories: [MenuItemOptionCategory] = []) {
        self.categories = categories
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case categories
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        categories = try container.decode([MenuItemOptionCategory].self, forKey: .categories)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(categories, forKey: .categories)
    }
}

/// Menu item matching the Kotlin `MenuItem`
@Model
public final class MenuItem: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var restaurantId: String
    public var restaurantNameAr: String
    public var restaurantNameEn: String
    public var categoryAr: String
    public var categoryEn: String
    public var nameAr: String
    public var nameEn: String
    public var descriptionAr: String
    public var descriptionEn: String
    public var priceLyd: Int
    public var originalPriceLyd: Int?
    public var artType: DishArtType
    public var isPopular: Bool
    public var isCombo: Bool
    public var isNewAddition: Bool
    public var offerBadgeAr: String?
    public var offerBadgeEn: String?
    public var calories: Int?
    public var isAvailable: Bool
    public var prepMinutesEstimate: Int
    @Relationship(deleteRule: .cascade) public var modifiers: [MenuModifierOption]
    public var options: MenuItemOptions?
    public var imageUrl: String?
    public var extraImageUrls: [String]

    public init(
        id: String,
        restaurantId: String,
        restaurantNameAr: String,
        restaurantNameEn: String,
        categoryAr: String,
        categoryEn: String,
        nameAr: String,
        nameEn: String,
        descriptionAr: String,
        descriptionEn: String,
        priceLyd: Int,
        originalPriceLyd: Int? = nil,
        artType: DishArtType,
        isPopular: Bool = false,
        isCombo: Bool = false,
        isNewAddition: Bool = false,
        offerBadgeAr: String? = nil,
        offerBadgeEn: String? = nil,
        calories: Int? = 540,
        isAvailable: Bool = true,
        prepMinutesEstimate: Int = 15,
        modifiers: [MenuModifierOption] = [],
        options: MenuItemOptions? = nil,
        imageUrl: String? = nil,
        extraImageUrls: [String] = []
    ) {
        self.id = id
        self.restaurantId = restaurantId
        self.restaurantNameAr = restaurantNameAr
        self.restaurantNameEn = restaurantNameEn
        self.categoryAr = categoryAr
        self.categoryEn = categoryEn
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.descriptionAr = descriptionAr
        self.descriptionEn = descriptionEn
        self.priceLyd = priceLyd
        self.originalPriceLyd = originalPriceLyd
        self.artType = artType
        self.isPopular = isPopular
        self.isCombo = isCombo
        self.isNewAddition = isNewAddition
        self.offerBadgeAr = offerBadgeAr
        self.offerBadgeEn = offerBadgeEn
        self.calories = calories
        self.isAvailable = isAvailable
        self.prepMinutesEstimate = prepMinutesEstimate
        self.modifiers = modifiers
        self.options = options
        self.imageUrl = imageUrl
        self.extraImageUrls = extraImageUrls
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, restaurantId, restaurantNameAr, restaurantNameEn, categoryAr, categoryEn,
             nameAr, nameEn, descriptionAr, descriptionEn, priceLyd, originalPriceLyd,
             artType, isPopular, isCombo, isNewAddition, offerBadgeAr, offerBadgeEn,
             calories, isAvailable, prepMinutesEstimate, modifiers, options, imageUrl, extraImageUrls
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        restaurantId = try container.decode(String.self, forKey: .restaurantId)
        restaurantNameAr = try container.decode(String.self, forKey: .restaurantNameAr)
        restaurantNameEn = try container.decode(String.self, forKey: .restaurantNameEn)
        categoryAr = try container.decode(String.self, forKey: .categoryAr)
        categoryEn = try container.decode(String.self, forKey: .categoryEn)
        nameAr = try container.decode(String.self, forKey: .nameAr)
        nameEn = try container.decode(String.self, forKey: .nameEn)
        descriptionAr = try container.decode(String.self, forKey: .descriptionAr)
        descriptionEn = try container.decode(String.self, forKey: .descriptionEn)
        priceLyd = try container.decode(Int.self, forKey: .priceLyd)
        originalPriceLyd = try container.decodeIfPresent(Int.self, forKey: .originalPriceLyd)
        artType = try container.decode(DishArtType.self, forKey: .artType)
        isPopular = try container.decode(Bool.self, forKey: .isPopular)
        isCombo = try container.decode(Bool.self, forKey: .isCombo)
        isNewAddition = try container.decode(Bool.self, forKey: .isNewAddition)
        offerBadgeAr = try container.decodeIfPresent(String.self, forKey: .offerBadgeAr)
        offerBadgeEn = try container.decodeIfPresent(String.self, forKey: .offerBadgeEn)
        calories = try container.decodeIfPresent(Int.self, forKey: .calories)
        isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
        prepMinutesEstimate = try container.decode(Int.self, forKey: .prepMinutesEstimate)
        modifiers = try container.decode([MenuModifierOption].self, forKey: .modifiers)
        options = try container.decodeIfPresent(MenuItemOptions.self, forKey: .options)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        extraImageUrls = try container.decodeIfPresent([String].self, forKey: .extraImageUrls) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(restaurantId, forKey: .restaurantId)
        try container.encode(restaurantNameAr, forKey: .restaurantNameAr)
        try container.encode(restaurantNameEn, forKey: .restaurantNameEn)
        try container.encode(categoryAr, forKey: .categoryAr)
        try container.encode(categoryEn, forKey: .categoryEn)
        try container.encode(nameAr, forKey: .nameAr)
        try container.encode(nameEn, forKey: .nameEn)
        try container.encode(descriptionAr, forKey: .descriptionAr)
        try container.encode(descriptionEn, forKey: .descriptionEn)
        try container.encode(priceLyd, forKey: .priceLyd)
        try container.encodeIfPresent(originalPriceLyd, forKey: .originalPriceLyd)
        try container.encode(artType, forKey: .artType)
        try container.encode(isPopular, forKey: .isPopular)
        try container.encode(isCombo, forKey: .isCombo)
        try container.encode(isNewAddition, forKey: .isNewAddition)
        try container.encodeIfPresent(offerBadgeAr, forKey: .offerBadgeAr)
        try container.encodeIfPresent(offerBadgeEn, forKey: .offerBadgeEn)
        try container.encodeIfPresent(calories, forKey: .calories)
        try container.encode(isAvailable, forKey: .isAvailable)
        try container.encode(prepMinutesEstimate, forKey: .prepMinutesEstimate)
        try container.encode(modifiers, forKey: .modifiers)
        try container.encodeIfPresent(options, forKey: .options)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encode(extraImageUrls, forKey: .extraImageUrls)
    }
}

/// Restaurant matching the Kotlin `Restaurant`
@Model
public final class Restaurant: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var nameAr: String
    public var nameEn: String
    public var cuisineAr: String
    public var cuisineEn: String
    public var districtAr: String
    public var districtEn: String
    public var microZoneId: String
    public var category: FoodCategory
    public var rating: Double
    public var deliveryMinutes: Int
    public var pickupPrepMinutes: Int
    public var deliveryFeeLyd: Int
    public var coordinationFeeLyd: Int
    public var minDeliveryOrderLyd: Int
    public var distanceKm: Double
    public var loyaltyCompleted: Int
    public var loyaltyTarget: Int
    public var promoTagAr: String?
    public var promoTagEn: String?
    public var isRecommended: Bool
    public var isPopular: Bool
    public var isNew: Bool
    public var supportsDelivery: Bool
    public var supportsPickup: Bool
    public var supportsPeakDelayedSlot: Bool
    public var operationalStatus: RestaurantOperationalStatus
    public var pickupAddressAr: String
    public var pickupAddressEn: String
    public var pickupInstructionsAr: String
    public var pickupInstructionsEn: String
    public var pickupRestrictionAr: String?
    public var pickupRestrictionEn: String?
    public var supportedMicroZones: [String]
    public var heroArt: DishArtType
    @Relationship(deleteRule: .cascade) public var menu: [MenuItem]
    public var imageUrl: String?
    public var coverImageUrl: String?

    public init(
        id: String,
        nameAr: String,
        nameEn: String,
        cuisineAr: String,
        cuisineEn: String,
        districtAr: String,
        districtEn: String,
        microZoneId: String = "zone_central",
        category: FoodCategory,
        rating: Double,
        deliveryMinutes: Int,
        pickupPrepMinutes: Int? = nil,
        deliveryFeeLyd: Int,
        coordinationFeeLyd: Int = 3,
        minDeliveryOrderLyd: Int = 20,
        distanceKm: Double = 1.8,
        loyaltyCompleted: Int,
        loyaltyTarget: Int,
        promoTagAr: String? = nil,
        promoTagEn: String? = nil,
        isRecommended: Bool = true,
        isPopular: Bool = true,
        isNew: Bool = false,
        supportsDelivery: Bool = true,
        supportsPickup: Bool = true,
        supportsPeakDelayedSlot: Bool = true,
        operationalStatus: RestaurantOperationalStatus = .open,
        pickupAddressAr: String = "",
        pickupAddressEn: String = "",
        pickupInstructionsAr: String = "",
        pickupInstructionsEn: String = "",
        pickupRestrictionAr: String? = nil,
        pickupRestrictionEn: String? = nil,
        supportedMicroZones: [String] = [],
        heroArt: DishArtType,
        menu: [MenuItem] = [],
        imageUrl: String? = nil,
        coverImageUrl: String? = nil
    ) {
        self.id = id
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.cuisineAr = cuisineAr
        self.cuisineEn = cuisineEn
        self.districtAr = districtAr
        self.districtEn = districtEn
        self.microZoneId = microZoneId
        self.category = category
        self.rating = rating
        self.deliveryMinutes = deliveryMinutes
        self.pickupPrepMinutes = pickupPrepMinutes ?? max(deliveryMinutes - 10, 10)
        self.deliveryFeeLyd = deliveryFeeLyd
        self.coordinationFeeLyd = coordinationFeeLyd
        self.minDeliveryOrderLyd = minDeliveryOrderLyd
        self.distanceKm = distanceKm
        self.loyaltyCompleted = loyaltyCompleted
        self.loyaltyTarget = loyaltyTarget
        self.promoTagAr = promoTagAr
        self.promoTagEn = promoTagEn
        self.isRecommended = isRecommended
        self.isPopular = isPopular
        self.isNew = isNew
        self.supportsDelivery = supportsDelivery
        self.supportsPickup = supportsPickup
        self.supportsPeakDelayedSlot = supportsPeakDelayedSlot
        self.operationalStatus = operationalStatus
        self.pickupAddressAr = pickupAddressAr.isEmpty ? "\(districtAr) — شباك استلام طلبات كوي المباشر" : pickupAddressAr
        self.pickupAddressEn = pickupAddressEn.isEmpty ? "\(districtEn) — Express KOOI Pickup Counter" : pickupAddressEn
        self.pickupInstructionsAr = pickupInstructionsAr.isEmpty ? "أظهر رقم الطلب عند شباك الاستلام السريع دون انتظار الطابور." : pickupInstructionsAr
        self.pickupInstructionsEn = pickupInstructionsEn.isEmpty ? "Show your order code at the express counter to skip the queue." : pickupInstructionsEn
        self.pickupRestrictionAr = pickupRestrictionAr
        self.pickupRestrictionEn = pickupRestrictionEn
        self.supportedMicroZones = supportedMicroZones.isEmpty ? ["zone_gargaresh", "zone_central", "zone_medina", "zone_andalus"] : supportedMicroZones
        self.heroArt = heroArt
        self.menu = menu
        self.imageUrl = imageUrl
        self.coverImageUrl = coverImageUrl
    }

    // Computed properties matching Kotlin
    public var hasOffer: Bool {
        promoTagAr != nil || menu.contains { $0.originalPriceLyd != nil || $0.offerBadgeAr != nil }
    }

    public var isNearby: Bool {
        distanceKm <= 2.5
    }

    public var isAvailableForOrdering: Bool {
        operationalStatus.canAcceptNewOrders
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, nameAr, nameEn, cuisineAr, cuisineEn, districtAr, districtEn,
             microZoneId, category, rating, deliveryMinutes, pickupPrepMinutes,
             deliveryFeeLyd, coordinationFeeLyd, minDeliveryOrderLyd, distanceKm,
             loyaltyCompleted, loyaltyTarget, promoTagAr, promoTagEn,
             isRecommended, isPopular, isNew, supportsDelivery, supportsPickup,
             supportsPeakDelayedSlot, operationalStatus, pickupAddressAr, pickupAddressEn,
             pickupInstructionsAr, pickupInstructionsEn, pickupRestrictionAr, pickupRestrictionEn,
             supportedMicroZones, heroArt, menu, imageUrl, coverImageUrl
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        nameAr = try container.decode(String.self, forKey: .nameAr)
        nameEn = try container.decode(String.self, forKey: .nameEn)
        cuisineAr = try container.decode(String.self, forKey: .cuisineAr)
        cuisineEn = try container.decode(String.self, forKey: .cuisineEn)
        districtAr = try container.decode(String.self, forKey: .districtAr)
        districtEn = try container.decode(String.self, forKey: .districtEn)
        microZoneId = try container.decode(String.self, forKey: .microZoneId)
        category = try container.decode(FoodCategory.self, forKey: .category)
        rating = try container.decode(Double.self, forKey: .rating)
        deliveryMinutes = try container.decode(Int.self, forKey: .deliveryMinutes)
        pickupPrepMinutes = try container.decode(Int.self, forKey: .pickupPrepMinutes)
        deliveryFeeLyd = try container.decode(Int.self, forKey: .deliveryFeeLyd)
        coordinationFeeLyd = try container.decode(Int.self, forKey: .coordinationFeeLyd)
        minDeliveryOrderLyd = try container.decode(Int.self, forKey: .minDeliveryOrderLyd)
        distanceKm = try container.decode(Double.self, forKey: .distanceKm)
        loyaltyCompleted = try container.decode(Int.self, forKey: .loyaltyCompleted)
        loyaltyTarget = try container.decode(Int.self, forKey: .loyaltyTarget)
        promoTagAr = try container.decodeIfPresent(String.self, forKey: .promoTagAr)
        promoTagEn = try container.decodeIfPresent(String.self, forKey: .promoTagEn)
        isRecommended = try container.decode(Bool.self, forKey: .isRecommended)
        isPopular = try container.decode(Bool.self, forKey: .isPopular)
        isNew = try container.decode(Bool.self, forKey: .isNew)
        supportsDelivery = try container.decode(Bool.self, forKey: .supportsDelivery)
        supportsPickup = try container.decode(Bool.self, forKey: .supportsPickup)
        supportsPeakDelayedSlot = try container.decode(Bool.self, forKey: .supportsPeakDelayedSlot)
        operationalStatus = try container.decode(RestaurantOperationalStatus.self, forKey: .operationalStatus)
        pickupAddressAr = try container.decode(String.self, forKey: .pickupAddressAr)
        pickupAddressEn = try container.decode(String.self, forKey: .pickupAddressEn)
        pickupInstructionsAr = try container.decode(String.self, forKey: .pickupInstructionsAr)
        pickupInstructionsEn = try container.decode(String.self, forKey: .pickupInstructionsEn)
        pickupRestrictionAr = try container.decodeIfPresent(String.self, forKey: .pickupRestrictionAr)
        pickupRestrictionEn = try container.decodeIfPresent(String.self, forKey: .pickupRestrictionEn)
        supportedMicroZones = try container.decode([String].self, forKey: .supportedMicroZones)
        heroArt = try container.decode(DishArtType.self, forKey: .heroArt)
        menu = try container.decode([MenuItem].self, forKey: .menu)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        coverImageUrl = try container.decodeIfPresent(String.self, forKey: .coverImageUrl)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nameAr, forKey: .nameAr)
        try container.encode(nameEn, forKey: .nameEn)
        try container.encode(cuisineAr, forKey: .cuisineAr)
        try container.encode(cuisineEn, forKey: .cuisineEn)
        try container.encode(districtAr, forKey: .districtAr)
        try container.encode(districtEn, forKey: .districtEn)
        try container.encode(microZoneId, forKey: .microZoneId)
        try container.encode(category, forKey: .category)
        try container.encode(rating, forKey: .rating)
        try container.encode(deliveryMinutes, forKey: .deliveryMinutes)
        try container.encode(pickupPrepMinutes, forKey: .pickupPrepMinutes)
        try container.encode(deliveryFeeLyd, forKey: .deliveryFeeLyd)
        try container.encode(coordinationFeeLyd, forKey: .coordinationFeeLyd)
        try container.encode(minDeliveryOrderLyd, forKey: .minDeliveryOrderLyd)
        try container.encode(distanceKm, forKey: .distanceKm)
        try container.encode(loyaltyCompleted, forKey: .loyaltyCompleted)
        try container.encode(loyaltyTarget, forKey: .loyaltyTarget)
        try container.encodeIfPresent(promoTagAr, forKey: .promoTagAr)
        try container.encodeIfPresent(promoTagEn, forKey: .promoTagEn)
        try container.encode(isRecommended, forKey: .isRecommended)
        try container.encode(isPopular, forKey: .isPopular)
        try container.encode(isNew, forKey: .isNew)
        try container.encode(supportsDelivery, forKey: .supportsDelivery)
        try container.encode(supportsPickup, forKey: .supportsPickup)
        try container.encode(supportsPeakDelayedSlot, forKey: .supportsPeakDelayedSlot)
        try container.encode(operationalStatus, forKey: .operationalStatus)
        try container.encode(pickupAddressAr, forKey: .pickupAddressAr)
        try container.encode(pickupAddressEn, forKey: .pickupAddressEn)
        try container.encode(pickupInstructionsAr, forKey: .pickupInstructionsAr)
        try container.encode(pickupInstructionsEn, forKey: .pickupInstructionsEn)
        try container.encodeIfPresent(pickupRestrictionAr, forKey: .pickupRestrictionAr)
        try container.encodeIfPresent(pickupRestrictionEn, forKey: .pickupRestrictionEn)
        try container.encode(supportedMicroZones, forKey: .supportedMicroZones)
        try container.encode(heroArt, forKey: .heroArt)
        try container.encode(menu, forKey: .menu)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(coverImageUrl, forKey: .coverImageUrl)
    }
}

/// Food street matching the Kotlin `FoodStreet`
@Model
public final class FoodStreet: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var nameAr: String
    public var nameEn: String
    public var vibeAr: String
    public var vibeEn: String
    public var microZoneId: String
    public var activeVendors: Int
    public var avgEtaMinutes: Int
    public var recentAreaOrderVolume: Int?
    public var baseStreetDeliveryFeeLyd: Int
    public var serviceFeeLyd: Int
    public var maxSelectableRestaurants: Int
    public var supportsCoordinatedPickup: Bool
    public var multiPickupDisabledReasonAr: String?
    public var multiPickupDisabledReasonEn: String?
    public var featuredArt: DishArtType
    public var restaurantIds: [String]

    public init(
        id: String,
        nameAr: String,
        nameEn: String,
        vibeAr: String,
        vibeEn: String,
        microZoneId: String = "zone_gargaresh",
        activeVendors: Int,
        avgEtaMinutes: Int,
        recentAreaOrderVolume: Int? = nil,
        baseStreetDeliveryFeeLyd: Int = 5,
        serviceFeeLyd: Int = 2,
        maxSelectableRestaurants: Int = 3,
        supportsCoordinatedPickup: Bool = true,
        multiPickupDisabledReasonAr: String? = nil,
        multiPickupDisabledReasonEn: String? = nil,
        featuredArt: DishArtType,
        restaurantIds: [String] = []
    ) {
        self.id = id
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.vibeAr = vibeAr
        self.vibeEn = vibeEn
        self.microZoneId = microZoneId
        self.activeVendors = activeVendors
        self.avgEtaMinutes = avgEtaMinutes
        self.recentAreaOrderVolume = recentAreaOrderVolume
        self.baseStreetDeliveryFeeLyd = baseStreetDeliveryFeeLyd
        self.serviceFeeLyd = serviceFeeLyd
        self.maxSelectableRestaurants = maxSelectableRestaurants
        self.supportsCoordinatedPickup = supportsCoordinatedPickup
        self.multiPickupDisabledReasonAr = multiPickupDisabledReasonAr
        self.multiPickupDisabledReasonEn = multiPickupDisabledReasonEn
        self.featuredArt = featuredArt
        self.restaurantIds = restaurantIds
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, nameAr, nameEn, vibeAr, vibeEn, microZoneId, activeVendors,
             avgEtaMinutes, recentAreaOrderVolume, baseStreetDeliveryFeeLyd,
             serviceFeeLyd, maxSelectableRestaurants, supportsCoordinatedPickup,
             multiPickupDisabledReasonAr, multiPickupDisabledReasonEn,
             featuredArt, restaurantIds
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        nameAr = try container.decode(String.self, forKey: .nameAr)
        nameEn = try container.decode(String.self, forKey: .nameEn)
        vibeAr = try container.decode(String.self, forKey: .vibeAr)
        vibeEn = try container.decode(String.self, forKey: .vibeEn)
        microZoneId = try container.decode(String.self, forKey: .microZoneId)
        activeVendors = try container.decode(Int.self, forKey: .activeVendors)
        avgEtaMinutes = try container.decode(Int.self, forKey: .avgEtaMinutes)
        recentAreaOrderVolume = try container.decodeIfPresent(Int.self, forKey: .recentAreaOrderVolume)
        baseStreetDeliveryFeeLyd = try container.decode(Int.self, forKey: .baseStreetDeliveryFeeLyd)
        serviceFeeLyd = try container.decode(Int.self, forKey: .serviceFeeLyd)
        maxSelectableRestaurants = try container.decode(Int.self, forKey: .maxSelectableRestaurants)
        supportsCoordinatedPickup = try container.decode(Bool.self, forKey: .supportsCoordinatedPickup)
        multiPickupDisabledReasonAr = try container.decodeIfPresent(String.self, forKey: .multiPickupDisabledReasonAr)
        multiPickupDisabledReasonEn = try container.decodeIfPresent(String.self, forKey: .multiPickupDisabledReasonEn)
        featuredArt = try container.decode(DishArtType.self, forKey: .featuredArt)
        restaurantIds = try container.decode([String].self, forKey: .restaurantIds)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nameAr, forKey: .nameAr)
        try container.encode(nameEn, forKey: .nameEn)
        try container.encode(vibeAr, forKey: .vibeAr)
        try container.encode(vibeEn, forKey: .vibeEn)
        try container.encode(microZoneId, forKey: .microZoneId)
        try container.encode(activeVendors, forKey: .activeVendors)
        try container.encode(avgEtaMinutes, forKey: .avgEtaMinutes)
        try container.encodeIfPresent(recentAreaOrderVolume, forKey: .recentAreaOrderVolume)
        try container.encode(baseStreetDeliveryFeeLyd, forKey: .baseStreetDeliveryFeeLyd)
        try container.encode(serviceFeeLyd, forKey: .serviceFeeLyd)
        try container.encode(maxSelectableRestaurants, forKey: .maxSelectableRestaurants)
        try container.encode(supportsCoordinatedPickup, forKey: .supportsCoordinatedPickup)
        try container.encodeIfPresent(multiPickupDisabledReasonAr, forKey: .multiPickupDisabledReasonAr)
        try container.encodeIfPresent(multiPickupDisabledReasonEn, forKey: .multiPickupDisabledReasonEn)
        try container.encode(featuredArt, forKey: .featuredArt)
        try container.encode(restaurantIds, forKey: .restaurantIds)
    }
}

/// Cart item matching the Kotlin `CartItem`
@Model
public final class CartItem: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    @Relationship public var menuItem: MenuItem
    public var quantity: Int
    public var note: String
    public var modifierExtraLyd: Int
    public var quotedUnitPriceLyd: Int
    public var participantId: String

    public init(
        id: String = UUID().uuidString,
        menuItem: MenuItem,
        quantity: Int,
        note: String = "",
        modifierExtraLyd: Int = 0,
        quotedUnitPriceLyd: Int? = nil,
        participantId: String = "user_self"
    ) {
        self.id = id
        self.menuItem = menuItem
        self.quantity = quantity
        self.note = note
        self.modifierExtraLyd = modifierExtraLyd
        self.quotedUnitPriceLyd = quotedUnitPriceLyd ?? menuItem.priceLyd
        self.participantId = participantId
    }

    public var effectiveUnitLyd: Int {
        quotedUnitPriceLyd + modifierExtraLyd
    }

    public var lineTotalLyd: Int {
        effectiveUnitLyd * quantity
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, menuItem, quantity, note, modifierExtraLyd, quotedUnitPriceLyd, participantId
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        menuItem = try container.decode(MenuItem.self, forKey: .menuItem)
        quantity = try container.decode(Int.self, forKey: .quantity)
        note = try container.decode(String.self, forKey: .note)
        modifierExtraLyd = try container.decode(Int.self, forKey: .modifierExtraLyd)
        quotedUnitPriceLyd = try container.decode(Int.self, forKey: .quotedUnitPriceLyd)
        participantId = try container.decode(String.self, forKey: .participantId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(menuItem, forKey: .menuItem)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(note, forKey: .note)
        try container.encode(modifierExtraLyd, forKey: .modifierExtraLyd)
        try container.encode(quotedUnitPriceLyd, forKey: .quotedUnitPriceLyd)
        try container.encode(participantId, forKey: .participantId)
    }
}

/// Delivery address matching the Kotlin `DeliveryAddress`
@Model
public final class DeliveryAddress: Codable, Identifiable {
    @Attribute(.unique) public var id: String
    public var titleAr: String
    public var titleEn: String
    public var districtAr: String
    public var districtEn: String
    public var detailsAr: String
    public var detailsEn: String
    public var microZoneId: String
    public var isDeliverySupported: Bool

    public init(
        id: String = UUID().uuidString,
        titleAr: String,
        titleEn: String,
        districtAr: String,
        districtEn: String,
        detailsAr: String,
        detailsEn: String,
        microZoneId: String = "zone_gargaresh",
        isDeliverySupported: Bool = true
    ) {
        self.id = id
        self.titleAr = titleAr
        self.titleEn = titleEn
        self.districtAr = districtAr
        self.districtEn = districtEn
        self.detailsAr = detailsAr
        self.detailsEn = detailsEn
        self.microZoneId = microZoneId
        self.isDeliverySupported = isDeliverySupported
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, titleAr, titleEn, districtAr, districtEn, detailsAr, detailsEn, microZoneId, isDeliverySupported
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        titleAr = try container.decode(String.self, forKey: .titleAr)
        titleEn = try container.decode(String.self, forKey: .titleEn)
        districtAr = try container.decode(String.self, forKey: .districtAr)
        districtEn = try container.decode(String.self, forKey: .districtEn)
        detailsAr = try container.decode(String.self, forKey: .detailsAr)
        detailsEn = try container.decode(String.self, forKey: .detailsEn)
        microZoneId = try container.decode(String.self, forKey: .microZoneId)
        isDeliverySupported = try container.decode(Bool.self, forKey: .isDeliverySupported)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(titleAr, forKey: .titleAr)
        try container.encode(titleEn, forKey: .titleEn)
        try container.encode(districtAr, forKey: .districtAr)
        try container.encode(districtEn, forKey: .districtEn)
        try container.encode(detailsAr, forKey: .detailsAr)
        try container.encode(detailsEn, forKey: .detailsEn)
        try container.encode(microZoneId, forKey: .microZoneId)
        try container.encode(isDeliverySupported, forKey: .isDeliverySupported)
    }
}

/// API Cuisine chip matching the Kotlin `ApiCuisine`
public struct ApiCuisine: Codable, Identifiable {
    public var id: String
    public var nameAr: String
    public var nameEn: String
    public var imageUrl: String?

    public init(id: String, nameAr: String, nameEn: String, imageUrl: String? = nil) {
        self.id = id
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.imageUrl = imageUrl
    }
}

/// Restaurant feed page matching the Kotlin `RestaurantFeed`
public struct RestaurantFeed: Codable {
    public var restaurants: [Restaurant]
    public var cuisines: [ApiCuisine]
    public var totalStores: Int
    public var nextPage: Int?
    public var currentPage: Int

    public init(
        restaurants: [Restaurant],
        cuisines: [ApiCuisine],
        totalStores: Int,
        nextPage: Int?,
        currentPage: Int = 0
    ) {
        self.restaurants = restaurants
        self.cuisines = cuisines
        self.totalStores = totalStores
        self.nextPage = nextPage
        self.currentPage = currentPage
    }
}