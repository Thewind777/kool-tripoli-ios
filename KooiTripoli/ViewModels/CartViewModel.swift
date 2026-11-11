import Foundation
import Combine
import SwiftUI

/// ViewModel for multi-restaurant group cart logic
/// Uses domain engines for pricing, scheduling, and fulfillment validation
@MainActor
public final class CartViewModel: ObservableObject {

    // MARK: - Published State (sourced from LocalCartStore)

    @Published public var cartItems: [CartItem] = []
    @Published public var selectedPaymentMethod: PaymentMethod = .cashOnDelivery
    @Published public var fulfillmentMode: FulfillmentMode = .delivery
    @Published public var orderingScope: OrderingScope = .singleRestaurant
    @Published public var participationMode: ParticipationMode = .individual
    @Published public var appliedLoyaltyReward: LoyaltyReward?
    @Published public var scheduledSlotLabel: String?
    @Published public var acceptedScheduledOffer: ScheduledOffer?
    @Published public var isCheckoutOpen: Bool = false
    @Published public var isCheckoutPaymentStep: Bool = false
    @Published public var showClearCartDialog: Bool = false

    // Computed from cart items and restaurants
    @Published public var restaurantOrderGroups: [RestaurantOrderGroup] = []
    @Published public var orderPriceBreakdown: OrderPriceBreakdown = OrderPriceBreakdown()
    @Published public var pickupStopsForCart: [PickupStopInfo] = []
    @Published public var availablePeakCheckoutOffer: ScheduledOffer?
    @Published public var baseBreakdownWithoutScheduledOffer: OrderPriceBreakdown = OrderPriceBreakdown()

    // Dependencies
    private let cartStore = LocalCartStore.shared
    private let restaurantsViewModel = RestaurantsViewModel()
    private var cancellables = Set<AnyCancellable>()

    public init() {
        cartStore.$cartItems
            .assign(to: &$cartItems)

        cartStore.$selectedPaymentMethod
            .assign(to: &$selectedPaymentMethod)

        cartStore.$fulfillmentMode
            .assign(to: &$fulfillmentMode)

        cartStore.$orderingScope
            .assign(to: &$orderingScope)

        cartStore.$participationMode
            .assign(to: &$participationMode)

        $cartItems
            .combineLatest(restaurantsViewModel.$restaurants)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] cartItems, restaurants in
                self?.recompute(cartItems: cartItems, restaurants: restaurants)
            }
            .store(in: &cancellables)
    }

    public func addItem(_ item: CartItem) {
        cartStore.addCartItem(item)
    }

    public func removeItem(id: String) {
        cartStore.removeCartItem(id: id)
    }

    public func updateItemQuantity(id: String, quantity: Int) {
        guard let index = cartItems.firstIndex(where: { $0.id == id }) else { return }
        var item = cartItems[index]
        item.quantity = quantity
        cartStore.updateCartItem(item)
    }

    public func incrementQuantity(for id: String) {
        guard let index = cartItems.firstIndex(where: { $0.id == id }) else { return }
        var item = cartItems[index]
        item.quantity += 1
        cartStore.updateCartItem(item)
    }

    public func decrementQuantity(for id: String) {
        guard let index = cartItems.firstIndex(where: { $0.id == id }) else { return }
        var item = cartItems[index]
        if item.quantity > 1 {
            item.quantity -= 1
            cartStore.updateCartItem(item)
        } else {
            cartStore.removeCartItem(id: id)
        }
    }

    public func clearCart() {
        cartStore.clearCart()
    }

    public func updateNote(for id: String, note: String) {
        guard let index = cartItems.firstIndex(where: { $0.id == id }) else { return }
        var item = cartItems[index]
        item.note = note
        cartStore.updateCartItem(item)
    }

    public func setPaymentMethod(_ method: PaymentMethod) {
        selectedPaymentMethod = method
        cartStore.selectedPaymentMethod = method
    }

    public func setFulfillmentMode(_ mode: FulfillmentMode) {
        fulfillmentMode = mode
        cartStore.fulfillmentMode = mode
    }

    public func applyLoyaltyReward(_ reward: LoyaltyReward) {
        appliedLoyaltyReward = reward
    }

    public func removeLoyaltyReward() {
        appliedLoyaltyReward = nil
    }

    public func acceptScheduledOffer(_ offer: ScheduledOffer) {
        acceptedScheduledOffer = offer
        scheduledSlotLabel = offer.slot.windowLabelEn
    }

    public func declineScheduledOffer() {
        acceptedScheduledOffer = nil
        scheduledSlotLabel = nil
    }

    public func openCheckout() {
        isCheckoutOpen = true
    }

    public func closeCheckout() {
        isCheckoutOpen = false
        isCheckoutPaymentStep = false
    }

    public func proceedToPayment() {
        isCheckoutPaymentStep = true
    }

    public func showClearCartConfirmation() {
        showClearCartDialog = true
    }

    public func hideClearCartConfirmation() {
        showClearCartDialog = false
    }

    public var totalCartCount: Int { cartStore.totalCartCount }
    public var totalCartLyd: Int { cartStore.totalCartLyd }
    public var distinctCartStoreCount: Int { cartStore.distinctCartStoreCount }
    public var singleCartStoreNameAr: String? { cartStore.singleCartStoreNameAr }
    public var singleCartStoreNameEn: String? { cartStore.singleCartStoreNameEn }
    public var effectiveScopeForCart: OrderingScope { cartStore.effectiveScopeForCart }
    public var selectedAddress: DeliveryAddress? { cartStore.selectedAddress }
    public var currentDistrictAr: String { selectedAddress?.districtAr ?? "" }
    public var currentDistrictEn: String { selectedAddress?.districtEn ?? "" }

    private func recompute(cartItems: [CartItem], restaurants: [Restaurant]) {
        let activeMrStreet = restaurantsViewModel.activeMrStreet

        let groups = OrderPricingAndQuoteEngine.buildRestaurantOrderGroups(
            cartItems: cartItems,
            allRestaurants: restaurants,
            breakdown: orderPriceBreakdown
        )
        self.restaurantOrderGroups = groups

        let baseBreakdown = OrderPricingAndQuoteEngine.calculateOrderPriceBreakdown(
            cartItems: cartItems,
            allRestaurants: restaurants,
            fulfillmentMode: fulfillmentMode,
            orderingScope: effectiveScopeForCart,
            mrStreet: activeMrStreet,
            scheduledOffer: nil,
            loyaltyReward: appliedLoyaltyReward
        )
        self.baseBreakdownWithoutScheduledOffer = baseBreakdown

        let finalBreakdown = OrderPricingAndQuoteEngine.calculateOrderPriceBreakdown(
            cartItems: cartItems,
            allRestaurants: restaurants,
            fulfillmentMode: fulfillmentMode,
            orderingScope: effectiveScopeForCart,
            mrStreet: activeMrStreet,
            scheduledOffer: acceptedScheduledOffer,
            loyaltyReward: appliedLoyaltyReward
        )
        self.orderPriceBreakdown = finalBreakdown

        let finalGroups = OrderPricingAndQuoteEngine.buildRestaurantOrderGroups(
            cartItems: cartItems,
            allRestaurants: restaurants,
            breakdown: finalBreakdown
        )
        self.restaurantOrderGroups = finalGroups

        self.pickupStopsForCart = OrderPricingAndQuoteEngine.buildPickupStops(
            restaurantIds: cartItems.map { $0.menuItem.restaurantId }.removingDuplicates(),
            restaurants: restaurants
        )

        if acceptedScheduledOffer == nil && !cartItems.isEmpty {
            let storeIds = cartItems.map { $0.menuItem.restaurantId }.removingDuplicates()
            let stores = storeIds.compactMap { id in restaurants.first { $0.id == id } }
            let estMinutes = stores.map {
                fulfillmentMode == .pickup ? $0.pickupPrepMinutes : $0.deliveryMinutes
            }.max() ?? 24

            self.availablePeakCheckoutOffer = ScheduledOfferEngine.buildOfferIfEligible(
                config: ScheduledOfferConfig(),
                cartItems: cartItems,
                participatingRestaurants: stores,
                fulfillmentMode: fulfillmentMode,
                baseBreakdownWithoutOffer: baseBreakdown,
                originalEtaMinutes: estMinutes,
                alreadyScheduledSlot: scheduledSlotLabel,
                declinedOfferIds: [],
                nowEpochMs: Int64(Date().timeIntervalSince1970 * 1000)
            )
        } else {
            self.availablePeakCheckoutOffer = nil
        }
    }

    public func buildFulfillmentSwitchPrompt(for mode: FulfillmentMode) -> FulfillmentSwitchPrompt {
        let activeMrStreet = restaurantsViewModel.activeMrStreet
        return OrderPricingAndQuoteEngine.buildFulfillmentSwitchPrompt(
            requestedMode: mode,
            cartItems: cartItems,
            allRestaurants: restaurantsViewModel.restaurants,
            currentBreakdown: orderPriceBreakdown,
            orderingScope: effectiveScopeForCart,
            mrStreet: activeMrStreet,
            deliveryAddress: selectedAddress
        )
    }

    public func confirmFulfillmentModeSwitch(_ prompt: FulfillmentSwitchPrompt) {
        if !prompt.isBlocked {
            setFulfillmentMode(prompt.requestedMode)
            acceptedScheduledOffer = nil
            scheduledSlotLabel = nil
        }
    }

    public func buildMrUnavailableRecovery() -> MrUnavailableRecoveryPrompt? {
        let activeMrStreet = restaurantsViewModel.activeMrStreet
        return OrderPricingAndQuoteEngine.buildMrUnavailableRecovery(
            street: activeMrStreet,
            selectedRestaurantIds: restaurantsViewModel.mrSelectedRestaurantIds,
            allRestaurants: restaurantsViewModel.restaurants,
            fulfillmentMode: fulfillmentMode,
            deliveryAddress: selectedAddress
        )
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}