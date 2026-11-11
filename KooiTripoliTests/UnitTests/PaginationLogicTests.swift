import XCTest
@testable import KooiTripoli

/// Unit tests for pagination logic
final class PaginationLogicTests: XCTestCase {
    var viewModel: RestaurantsViewModel!
    var mockAPIClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        viewModel = RestaurantsViewModel()
        // Inject mock client
    }

    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        super.tearDown()
    }

    func testInitialPageLoad() async {
        // Given
        let mockRestaurants = createMockRestaurants(count: 12)
        let mockCuisines = createMockCuisines(count: 5)
        mockAPIClient.mockFeed = RestaurantFeed(
            restaurants: mockRestaurants,
            cuisines: mockCuisines,
            totalStores: 100,
            nextPage: 1,
            currentPage: 0
        )

        // When
        await viewModel.refreshRestaurants()

        // Then
        XCTAssertEqual(viewModel.restaurants.count, 12)
        XCTAssertEqual(viewModel.currentRestaurantPage, 0)
        XCTAssertTrue(viewModel.hasMoreRestaurantPages)
        XCTAssertEqual(viewModel.totalStoreCount, 100)
        XCTAssertFalse(viewModel.isLoadingRestaurants)
    }

    func testLoadMoreRestaurants() async {
        // Given
        let initialRestaurants = createMockRestaurants(count: 12)
        let moreRestaurants = createMockRestaurants(count: 12, offset: 12)
        mockAPIClient.mockFeed = RestaurantFeed(
            restaurants: initialRestaurants,
            cuisines: [],
            totalStores: 100,
            nextPage: 1,
            currentPage: 0
        )

        await viewModel.refreshRestaurants()

        // Second page
        mockAPIClient.mockFeed = RestaurantFeed(
            restaurants: moreRestaurants,
            cuisines: [],
            totalStores: 100,
            nextPage: 2,
            currentPage: 1
        )

        // When
        await viewModel.loadMoreRestaurants()

        // Then
        XCTAssertEqual(viewModel.restaurants.count, 24)
        XCTAssertEqual(viewModel.currentRestaurantPage, 1)
        XCTAssertTrue(viewModel.hasMoreRestaurantPages)
    }

    func testNoMorePagesWhenNextPageIsNull() async {
        // Given
        mockAPIClient.mockFeed = RestaurantFeed(
            restaurants: createMockRestaurants(count: 10),
            cuisines: [],
            totalStores: 10,
            nextPage: nil,
            currentPage: 0
        )

        // When
        await viewModel.refreshRestaurants()

        // Then
        XCTAssertFalse(viewModel.hasMoreRestaurantPages)
    }

    func testPullToRefreshResetsPagination() async {
        // Given
        mockAPIClient.mockFeed = RestaurantFeed(
            restaurants: createMockRestaurants(count: 12),
            cuisines: [],
            totalStores: 100,
            nextPage: 1,
            currentPage: 0
        )

        await viewModel.refreshRestaurants()
        XCTAssertEqual(viewModel.currentRestaurantPage, 0)

        // When
        mockAPIClient.mockFeed = RestaurantFeed(
            restaurants: createMockRestaurants(count: 15),
            cuisines: [],
            totalStores: 100,
            nextPage: 1,
            currentPage: 0
        )
        await viewModel.onPullToRefresh()

        // Then
        XCTAssertEqual(viewModel.currentRestaurantPage, 0)
        XCTAssertEqual(viewModel.restaurants.count, 15)
    }

    func testFilteredRestaurantsByCollection() {
        // Given
        viewModel.restaurants = [
            createMockRestaurant(id: "1", hasOffer: true, isRecommended: false, isPopular: false, isNew: false, isNearby: false),
            createMockRestaurant(id: "2", hasOffer: false, isRecommended: true, isPopular: false, isNew: false, isNearby: false),
            createMockRestaurant(id: "3", hasOffer: false, isRecommended: false, isPopular: true, isNew: false, isNearby: false),
            createMockRestaurant(id: "4", hasOffer: false, isRecommended: false, isPopular: false, isNew: true, isNearby: false),
            createMockRestaurant(id: "5", hasOffer: false, isRecommended: false, isPopular: false, isNew: false, isNearby: true),
        ]

        // When/Then
        viewModel.activeCollectionFilter = .offers
        XCTAssertEqual(viewModel.filteredRestaurants().count, 1)

        viewModel.activeCollectionFilter = .recommended
        XCTAssertEqual(viewModel.filteredRestaurants().count, 1)

        viewModel.activeCollectionFilter = .popular
        XCTAssertEqual(viewModel.filteredRestaurants().count, 1)

        viewModel.activeCollectionFilter = .new
        XCTAssertEqual(viewModel.filteredRestaurants().count, 1)

        viewModel.activeCollectionFilter = .nearby
        XCTAssertEqual(viewModel.filteredRestaurants().count, 1)

        viewModel.activeCollectionFilter = .all
        XCTAssertEqual(viewModel.filteredRestaurants().count, 5)
    }

    func testFilteredRestaurantsByCategory() {
        // Given
        viewModel.restaurants = [
            createMockRestaurant(id: "1", category: .pizza),
            createMockRestaurant(id: "2", category: .burger),
            createMockRestaurant(id: "3", category: .libyan),
        ]

        // When/Then
        viewModel.activeCategoryFilter = .pizza
        XCTAssertEqual(viewModel.filteredRestaurants().count, 1)

        viewModel.activeCategoryFilter = .burger
        XCTAssertEqual(viewModel.filteredRestaurants().count, 1)

        viewModel.activeCategoryFilter = .all
        XCTAssertEqual(viewModel.filteredRestaurants().count, 3)
    }

    func testSearchQueryFiltering() {
        // Given
        viewModel.restaurants = [
            createMockRestaurant(id: "1", nameAr: "بيتزا فرن المدينة", nameEn: "Pizza Forn Al-Medina"),
            createMockRestaurant(id: "2", nameAr: "قرقارش سماش برجر", nameEn: "Gargaresh Smash Lab"),
            createMockRestaurant(id: "3", nameAr: "دار عزيزة", nameEn: "Dar Aziza"),
        ]

        // When
        viewModel.searchQuery = "بيتزا"
        // Then
        XCTAssertEqual(viewModel.filteredRestaurants().count, 1)
        XCTAssertTrue(viewModel.filteredRestaurants().first?.nameAr.contains("بيتزا") ?? false)

        // When
        viewModel.searchQuery = "pizza"
        // Then
        XCTAssertEqual(viewModel.filteredRestaurants().count, 1)
    }

    // MARK: - Helpers

    private func createMockRestaurants(count: Int, offset: Int = 0) -> [Restaurant] {
        return (offset..<offset+count).map { i in
            createMockRestaurant(id: "rest_\(i)")
        }
    }

    private func createMockRestaurant(
        id: String,
        nameAr: String = "مطعم تجريبي",
        nameEn: String = "Test Restaurant",
        category: FoodCategory = .pizza,
        hasOffer: Bool = false,
        isRecommended: Bool = true,
        isPopular: Bool = true,
        isNew: Bool = false,
        isNearby: Bool = false
    ) -> Restaurant {
        return Restaurant(
            id: id,
            nameAr: nameAr,
            nameEn: nameEn,
            cuisineAr: category.labelAr,
            cuisineEn: category.labelEn,
            districtAr: "طرابلس",
            districtEn: "Tripoli",
            microZoneId: "zone_central",
            category: category,
            rating: 4.5,
            deliveryMinutes: 30,
            pickupPrepMinutes: 20,
            deliveryFeeLyd: 5,
            coordinationFeeLyd: 3,
            minDeliveryOrderLyd: 20,
            distanceKm: isNearby ? 1.5 : 3.0,
            loyaltyCompleted: 0,
            loyaltyTarget: 5,
            promoTagAr: hasOffer ? "خصم 20%" : nil,
            promoTagEn: hasOffer ? "20% Off" : nil,
            isRecommended: isRecommended,
            isPopular: isPopular,
            isNew: isNew,
            supportsDelivery: true,
            supportsPickup: true,
            supportsPeakDelayedSlot: true,
            operationalStatus: .open,
            pickupAddressAr: "",
            pickupAddressEn: "",
            pickupInstructionsAr: "",
            pickupInstructionsEn: "",
            supportedMicroZones: [],
            heroArt: .woodfiredPizza,
            menu: []
        )
    }

    private func createMockCuisines(count: Int) -> [ApiCuisine] {
        return (0..<count).map { i in
            ApiCuisine(
                id: "cuisine_\(i)",
                nameAr: "مطبخ \(i)",
                nameEn: "Cuisine \(i)",
                imageUrl: nil
            )
        }
    }
}

/// Unit tests for group cart model calculations
final class GroupCartModelTests: XCTestCase {
    var cartVM: CartViewModel!
    var mockRestaurants: [Restaurant]!

    override func setUp() {
        super.setUp()
        cartVM = CartViewModel()
        mockRestaurants = createMockRestaurants()
    }

    override func tearDown() {
        cartVM = nil
        mockRestaurants = nil
        super.tearDown()
    }

    func testSingleRestaurantCartTotals() {
        // Given
        let restaurant = mockRestaurants[0]
        let menuItem = restaurant.menu[0]
        let cartItem = CartItem(menuItem: menuItem, quantity: 2)

        cartVM.cartStore.cartItems = [cartItem]

        // When
        cartVM.recompute(cartItems: [cartItem], restaurants: mockRestaurants)

        // Then
        XCTAssertEqual(cartVM.totalCartCount, 2)
        XCTAssertEqual(cartVM.totalCartLyd, menuItem.priceLyd * 2)
        XCTAssertEqual(cartVM.distinctCartStoreCount, 1)
        XCTAssertEqual(cartVM.effectiveScopeForCart, .singleRestaurant)
    }

    func testMultiRestaurantCartTotals() {
        // Given
        let restaurant1 = mockRestaurants[0]
        let restaurant2 = mockRestaurants[1]
        let item1 = restaurant1.menu[0]
        let item2 = restaurant2.menu[0]

        let cartItem1 = CartItem(menuItem: item1, quantity: 1)
        let cartItem2 = CartItem(menuItem: item2, quantity: 2)

        cartVM.cartStore.cartItems = [cartItem1, cartItem2]

        // When
        cartVM.recompute(cartItems: [cartItem1, cartItem2], restaurants: mockRestaurants)

        // Then
        XCTAssertEqual(cartVM.totalCartCount, 3)
        XCTAssertEqual(cartVM.totalCartLyd, item1.priceLyd + item2.priceLyd * 2)
        XCTAssertEqual(cartVM.distinctCartStoreCount, 2)
        XCTAssertEqual(cartVM.effectiveScopeForCart, .multiRestaurant)
    }

    func testRestaurantOrderGroups() {
        // Given
        let restaurant1 = mockRestaurants[0]
        let restaurant2 = mockRestaurants[1]
        let item1 = restaurant1.menu[0]
        let item2 = restaurant2.menu[0]

        let cartItem1 = CartItem(menuItem: item1, quantity: 2)
        let cartItem2 = CartItem(menuItem: item2, quantity: 1)

        // When
        cartVM.recompute(cartItems: [cartItem1, cartItem2], restaurants: mockRestaurants)

        // Then
        XCTAssertEqual(cartVM.restaurantOrderGroups.count, 2)

        let group1 = cartVM.restaurantOrderGroups.first { $0.restaurantId == restaurant1.id }
        let group2 = cartVM.restaurantOrderGroups.first { $0.restaurantId == restaurant2.id }

        XCTAssertNotNil(group1)
        XCTAssertNotNil(group2)
        XCTAssertEqual(group1?.items.count, 1)
        XCTAssertEqual(group2?.items.count, 1)
        XCTAssertEqual(group1?.subtotalLyd, item1.priceLyd * 2)
        XCTAssertEqual(group2?.subtotalLyd, item2.priceLyd)
    }

    func testPriceBreakdownCalculation() {
        // Given
        let restaurant = mockRestaurants[0]
        let item = restaurant.menu[0]
        let cartItem = CartItem(menuItem: item, quantity: 2)

        // When
        cartVM.recompute(cartItems: [cartItem], restaurants: mockRestaurants)

        // Then
        let breakdown = cartVM.orderPriceBreakdown
        XCTAssertEqual(breakdown.foodSubtotalLyd, item.priceLyd * 2)
        XCTAssertEqual(breakdown.baseDeliveryFeeLyd, restaurant.deliveryFeeLyd)
        XCTAssertEqual(breakdown.coordinationFeesLyd, 0) // Single restaurant = no coordination fee
        XCTAssertGreaterThan(breakdown.finalTotalLyd, 0)
    }

    func testMultiRestaurantPriceBreakdown() {
        // Given
        let restaurant1 = mockRestaurants[0]
        let restaurant2 = mockRestaurants[1]
        let item1 = restaurant1.menu[0]
        let item2 = restaurant2.menu[0]

        let cartItem1 = CartItem(menuItem: item1, quantity: 1)
        let cartItem2 = CartItem(menuItem: item2, quantity: 1)

        cartVM.cartStore.fulfillmentMode = .delivery
        cartVM.cartStore.orderingScope = .multiRestaurant

        // When
        cartVM.recompute(cartItems: [cartItem1, cartItem2], restaurants: mockRestaurants)

        // Then
        let breakdown = cartVM.orderPriceBreakdown
        XCTAssertEqual(breakdown.foodSubtotalLyd, item1.priceLyd + item2.priceLyd)
        XCTAssertGreaterThan(breakdown.coordinationFeesLyd, 0) // Should have coordination fee
        XCTAssertEqual(breakdown.coordinationBreakdown.count, 1) // One secondary restaurant
    }

    func testQuantityOperations() {
        // Given
        let restaurant = mockRestaurants[0]
        let item = restaurant.menu[0]
        let cartItem = CartItem(menuItem: item, quantity: 1)
        cartVM.cartStore.cartItems = [cartItem]

        // When
        cartVM.incrementQuantity(for: cartItem.id)

        // Then
        XCTAssertEqual(cartVM.cartStore.cartItems.first?.quantity, 2)

        // When
        cartVM.decrementQuantity(for: cartItem.id)

        // Then
        XCTAssertEqual(cartVM.cartStore.cartItems.first?.quantity, 1)
    }

    func testCartClearing() {
        // Given
        let restaurant = mockRestaurants[0]
        let item = restaurant.menu[0]
        cartVM.cartStore.cartItems = [CartItem(menuItem: item, quantity: 1)]

        // When
        cartVM.clearCart()

        // Then
        XCTAssertTrue(cartVM.cartStore.cartItems.isEmpty)
        XCTAssertEqual(cartVM.totalCartCount, 0)
        XCTAssertEqual(cartVM.totalCartLyd, 0)
    }

    // MARK: - Helpers

    private func createMockRestaurants() -> [Restaurant] {
        let restaurant1 = Restaurant(
            id: "rest_1",
            nameAr: "مطعم 1",
            nameEn: "Restaurant 1",
            cuisineAr: "بيتزا",
            cuisineEn: "Pizza",
            districtAr: "طرابلس",
            districtEn: "Tripoli",
            microZoneId: "zone_central",
            category: .pizza,
            rating: 4.5,
            deliveryMinutes: 30,
            pickupPrepMinutes: 20,
            deliveryFeeLyd: 5,
            coordinationFeeLyd: 3,
            minDeliveryOrderLyd: 20,
            distanceKm: 2.0,
            loyaltyCompleted: 0,
            loyaltyTarget: 5,
            promoTagAr: nil,
            promoTagEn: nil,
            isRecommended: true,
            isPopular: true,
            isNew: false,
            supportsDelivery: true,
            supportsPickup: true,
            supportsPeakDelayedSlot: true,
            operationalStatus: .open,
            pickupAddressAr: "",
            pickupAddressEn: "",
            pickupInstructionsAr: "",
            pickupInstructionsEn: "",
            supportedMicroZones: [],
            heroArt: .woodfiredPizza,
            menu: [
                MenuItem(
                    id: "item_1",
                    restaurantId: "rest_1",
                    restaurantNameAr: "مطعم 1",
                    restaurantNameEn: "Restaurant 1",
                    categoryAr: "بيتزا",
                    categoryEn: "Pizza",
                    nameAr: "بيتزا مارغريتا",
                    nameEn: "Margherita Pizza",
                    descriptionAr: "",
                    descriptionEn: "",
                    priceLyd: 30,
                    originalPriceLyd: nil,
                    artType: .woodfiredPizza,
                    isPopular: true,
                    isCombo: false,
                    isNewAddition: false,
                    offerBadgeAr: nil,
                    offerBadgeEn: nil,
                    calories: 500,
                    isAvailable: true,
                    prepMinutesEstimate: 15,
                    modifiers: [],
                    options: nil,
                    imageUrl: nil,
                    extraImageUrls: []
                )
            ],
            imageUrl: nil,
            coverImageUrl: nil
        )

        let restaurant2 = Restaurant(
            id: "rest_2",
            nameAr: "مطعم 2",
            nameEn: "Restaurant 2",
            cuisineAr: "برجر",
            cuisineEn: "Burger",
            districtAr: "طرابلس",
            districtEn: "Tripoli",
            microZoneId: "zone_central",
            category: .burger,
            rating: 4.7,
            deliveryMinutes: 25,
            pickupPrepMinutes: 15,
            deliveryFeeLyd: 4,
            coordinationFeeLyd: 3,
            minDeliveryOrderLyd: 20,
            distanceKm: 1.5,
            loyaltyCompleted: 0,
            loyaltyTarget: 5,
            promoTagAr: nil,
            promoTagEn: nil,
            isRecommended: true,
            isPopular: true,
            isNew: false,
            supportsDelivery: true,
            supportsPickup: true,
            supportsPeakDelayedSlot: true,
            operationalStatus: .open,
            pickupAddressAr: "",
            pickupAddressEn: "",
            pickupInstructionsAr: "",
            pickupInstructionsEn: "",
            supportedMicroZones: [],
            heroArt: .burgerCombo,
            menu: [
                MenuItem(
                    id: "item_2",
                    restaurantId: "rest_2",
                    restaurantNameAr: "مطعم 2",
                    restaurantNameEn: "Restaurant 2",
                    categoryAr: "برجر",
                    categoryEn: "Burger",
                    nameAr: "برجر كلاسيك",
                    nameEn: "Classic Burger",
                    descriptionAr: "",
                    descriptionEn: "",
                    priceLyd: 25,
                    originalPriceLyd: nil,
                    artType: .burgerCombo,
                    isPopular: true,
                    isCombo: false,
                    isNewAddition: false,
                    offerBadgeAr: nil,
                    offerBadgeEn: nil,
                    calories: 600,
                    isAvailable: true,
                    prepMinutesEstimate: 12,
                    modifiers: [],
                    options: nil,
                    imageUrl: nil,
                    extraImageUrls: []
                )
            ],
            imageUrl: nil,
            coverImageUrl: nil
        )

        return [restaurant1, restaurant2]
    }
}

/// Unit tests for ViewModels
final class ViewModelTests: XCTestCase {
    var restaurantsVM: RestaurantsViewModel!
    var itemDetailVM: ItemDetailViewModel!
    var cartVM: CartViewModel!
    var onboardingVM: OnboardingViewModel!

    override func setUp() {
        super.setUp()
        restaurantsVM = RestaurantsViewModel()
        itemDetailVM = ItemDetailViewModel()
        cartVM = CartViewModel()
        onboardingVM = OnboardingViewModel()
    }

    override func tearDown() {
        restaurantsVM = nil
        itemDetailVM = nil
        cartVM = nil
        onboardingVM = nil
        super.tearDown()
    }

    func testOnboardingStateTransitions() {
        // Given
        XCTAssertEqual(onboardingVM.envelopeState, .closed)
        XCTAssertFalse(onboardingVM.showContent)

        // When
        onboardingVM.startOnboarding()

        // Then - State should transition through opening -> open -> revealing -> completed
        // (Actual animation testing would need UI tests)
    }

    func testOnboardingSkip() {
        // Given
        onboardingVM.startOnboarding()

        // When
        onboardingVM.skipOnboarding()

        // Then
        XCTAssertEqual(onboardingVM.envelopeState, .skipped)
        XCTAssertTrue(onboardingVM.showContent)
    }

    func testOnboardingComplete() {
        // Given
        onboardingVM.startOnboarding()

        // When
        onboardingVM.completeOnboarding()

        // Then
        XCTAssertEqual(onboardingVM.envelopeState, .completed)
        XCTAssertTrue(onboardingVM.showContent)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "onboardingCompleted"))
    }

    func testItemDetailQuantity() {
        // Given
        let item = createMockMenuItem()
        itemDetailVM.setMenuItem(item)

        // When
        itemDetailVM.incrementQuantity()
        itemDetailVM.incrementQuantity()
        itemDetailVM.decrementQuantity()

        // Then
        XCTAssertEqual(itemDetailVM.selectedQuantity, 2)
    }

    func testItemDetailModifierSelection() {
        // Given
        let item = createMockMenuItem(withModifiers: true)
        itemDetailVM.setMenuItem(item)
        let modifier = item.modifiers.first!

        // When
        itemDetailVM.toggleModifier(modifier.id)

        // Then
        XCTAssertTrue(itemDetailVM.isModifierSelected(modifier.id))
        XCTAssertEqual(itemDetailVM.modifierExtraLyd, modifier.extraPriceLyd)

        // When - toggle off
        itemDetailVM.toggleModifier(modifier.id)

        // Then
        XCTAssertFalse(itemDetailVM.isModifierSelected(modifier.id))
        XCTAssertEqual(itemDetailVM.modifierExtraLyd, 0)
    }

    func testCartViewModelBindings() {
        // Given
        let restaurant = createMockRestaurant()
        let item = restaurant.menu[0]
        let cartItem = CartItem(menuItem: item, quantity: 1)

        // When
        cartVM.addItem(cartItem)

        // Then
        XCTAssertEqual(cartVM.cartItems.count, 1)
        XCTAssertEqual(cartVM.totalCartCount, 1)
        XCTAssertEqual(cartVM.totalCartLyd, item.priceLyd)
    }

    // MARK: - Helpers

    private func createMockMenuItem(withModifiers: Bool = false) -> MenuItem {
        let modifiers = withModifiers ? [
            MenuModifierOption(
                id: "mod_1",
                labelAr: "إضافي",
                labelEn: "Extra",
                extraPriceLyd: 5,
                isAvailable: true,
                modifierType: "Addon",
                isDefault: false
            )
        ] : []

        return MenuItem(
            id: "item_1",
            restaurantId: "rest_1",
            restaurantNameAr: "مطعم",
            restaurantNameEn: "Restaurant",
            categoryAr: "بيتزا",
            categoryEn: "Pizza",
            nameAr: "بيتزا تجريبية",
            nameEn: "Test Pizza",
            descriptionAr: "وصف",
            descriptionEn: "Description",
            priceLyd: 30,
            originalPriceLyd: nil,
            artType: .woodfiredPizza,
            isPopular: false,
            isCombo: false,
            isNewAddition: false,
            offerBadgeAr: nil,
            offerBadgeEn: nil,
            calories: 500,
            isAvailable: true,
            prepMinutesEstimate: 15,
            modifiers: modifiers,
            options: nil,
            imageUrl: nil,
            extraImageUrls: []
        )
    }

    private func createMockRestaurant() -> Restaurant {
        return Restaurant(
            id: "rest_1",
            nameAr: "مطعم تجريبي",
            nameEn: "Test Restaurant",
            cuisineAr: "بيتزا",
            cuisineEn: "Pizza",
            districtAr: "طرابلس",
            districtEn: "Tripoli",
            microZoneId: "zone_central",
            category: .pizza,
            rating: 4.5,
            deliveryMinutes: 30,
            pickupPrepMinutes: 20,
            deliveryFeeLyd: 5,
            coordinationFeeLyd: 3,
            minDeliveryOrderLyd: 20,
            distanceKm: 2.0,
            loyaltyCompleted: 0,
            loyaltyTarget: 5,
            promoTagAr: nil,
            promoTagEn: nil,
            isRecommended: true,
            isPopular: true,
            isNew: false,
            supportsDelivery: true,
            supportsPickup: true,
            supportsPeakDelayedSlot: true,
            operationalStatus: .open,
            pickupAddressAr: "",
            pickupAddressEn: "",
            pickupInstructionsAr: "",
            pickupInstructionsEn: "",
            supportedMicroZones: [],
            heroArt: .woodfiredPizza,
            menu: [createMockMenuItem()],
            imageUrl: nil,
            coverImageUrl: nil
        )
    }
}