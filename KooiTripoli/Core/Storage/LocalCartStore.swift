import Foundation
import SwiftData
import Combine

/// Local cart store using SwiftData for multi-restaurant persistence
/// Mirrors the Kotlin local cart persistence
@MainActor
public final class LocalCartStore: ObservableObject {
    public static let shared = LocalCartStore()

    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @Published public var cartItems: [CartItem] = []
    @Published public var selectedAddress: DeliveryAddress?
    @Published public var selectedPaymentMethod: PaymentMethod = .cashOnDelivery
    @Published public var fulfillmentMode: FulfillmentMode = .delivery
    @Published public var orderingScope: OrderingScope = .singleRestaurant
    @Published public var participationMode: ParticipationMode = .individual
    @Published public var appliedLoyaltyReward: LoyaltyReward?
    @Published public var scheduledSlotLabel: String?
    @Published public var acceptedScheduledOffer: ScheduledOffer?
    @Published public var userPreferences: UserPreferences = UserPreferences()

    private init() {
        do {
            let schema = Schema([
                CartItem.self,
                MenuItem.self,
                MenuModifierOption.self,
                MenuItemOptionCategory.self,
                MenuItemOptions.self,
                Restaurant.self,
                FoodStreet.self,
                DeliveryAddress.self,
                WalletTransaction.self,
                WalletContact.self,
                MoneyRequest.self,
                PaymentRequestToken.self,
                LoyaltyCard.self,
                LoyaltyProgram.self,
                LoyaltyCategory.self,
                LoyaltyReward.self,
                LoyaltyTransaction.self,
                Redemption.self,
                Order.self,
                OrderItem.self,
                OrderPriceBreakdown.self,
                RestaurantOrderGroup.self,
                PickupStopInfo.self,
                ActiveOrder.self,
                GroupOrder.self,
                GroupCartItem.self,
                GroupParticipant.self,
                GroupInvitation.self,
                GroupPaymentAllocation.self,
                FriendPaymentRequest.self,
                GroupActivity.self,
                GroupCreationDraft.self,
                ScheduledOffer.self,
                ScheduledFulfillmentSlot.self,
                OffPeakWindow.self,
                KooiNotification.self,
                WalletContact.self,
                MoneyTransfer.self,
            ])

            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = ModelContext(modelContainer)

            // Load persisted data
            loadCartItems()
            loadUserPreferences()
            loadSelectedAddress()
        } catch {
            fatalError("Failed to initialize LocalCartStore: \(error)")
        }
    }

    // MARK: - Cart Items

    public func loadCartItems() {
        let descriptor = FetchDescriptor<CartItem>(sortBy: [SortDescriptor(\.id)])
        do {
            cartItems = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load cart items: \(error)")
            cartItems = []
        }
    }

    public func addCartItem(_ item: CartItem) {
        modelContext.insert(item)
        cartItems.append(item)
        save()
    }

    public func updateCartItem(_ item: CartItem) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems[index] = item
        }
        save()
    }

    public func removeCartItem(id: String) {
        cartItems.removeAll { $0.id == id }
        let descriptor = FetchDescriptor<CartItem>(predicate: #Predicate { $0.id == id })
        do {
            let items = try modelContext.fetch(descriptor)
            items.forEach { modelContext.delete($0) }
        } catch {
            print("Failed to remove cart item: \(error)")
        }
        save()
    }

    public func clearCart() {
        cartItems.forEach { modelContext.delete($0) }
        cartItems = []
        save()
    }

    public func quantityForMenuItem(_ menuItemId: String) -> Int {
        cartItems.filter { $0.menuItem.id == menuItemId }.reduce(0) { $0 + $1.quantity }
    }

    // MARK: - Computed Cart Properties

    public var totalCartCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    public var totalCartLyd: Int {
        cartItems.reduce(0) { $0 + $1.lineTotalLyd }
    }

    public var distinctCartStoreCount: Int {
        Set(cartItems.map { $0.menuItem.restaurantId }).count
    }

    public var singleCartStoreNameAr: String? {
        guard distinctCartStoreCount == 1,
              let firstItem = cartItems.first else { return nil }
        return firstItem.menuItem.restaurantNameAr
    }

    public var singleCartStoreNameEn: String? {
        guard distinctCartStoreCount == 1,
              let firstItem = cartItems.first else { return nil }
        return firstItem.menuItem.restaurantNameEn
    }

    public var effectiveScopeForCart: OrderingScope {
        if distinctCartStoreCount > 1 || orderingScope == .multiRestaurant {
            return .multiRestaurant
        }
        return .singleRestaurant
    }

    // MARK: - Selected Address

    public func loadSelectedAddress() {
        let descriptor = FetchDescriptor<DeliveryAddress>(predicate: #Predicate { $0.id == selectedAddress?.id ?? "" })
        do {
            if let address = try modelContext.fetch(descriptor).first {
                selectedAddress = address
            } else if let firstAddress = try modelContext.fetch(FetchDescriptor<DeliveryAddress>()).first {
                selectedAddress = firstAddress
            }
        } catch {
            print("Failed to load selected address: \(error)")
        }
    }

    public func setSelectedAddress(_ address: DeliveryAddress) {
        selectedAddress = address
        UserDefaults.standard.set(address.id, forKey: "selectedAddressId")
    }

    // MARK: - User Preferences

    public func loadUserPreferences() {
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            userPreferences = prefs
        }
    }

    public func saveUserPreferences() {
        if let data = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }

    public func updateLanguage(_ language: String) {
        userPreferences.language = language
        saveUserPreferences()
    }

    public func updateTheme(_ theme: String) {
        userPreferences.theme = theme
        saveUserPreferences()
    }

    // MARK: - Persistence

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    // MARK: - Restaurant Data Caching

    public func cacheRestaurants(_ restaurants: [Restaurant]) {
        restaurants.forEach { modelContext.insert($0) }
        save()
    }

    public func getCachedRestaurants() -> [Restaurant] {
        let descriptor = FetchDescriptor<Restaurant>()
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    public func cacheFoodStreets(_ foodStreets: [FoodStreet]) {
        foodStreets.forEach { modelContext.insert($0) }
        save()
    }

    public func getCachedFoodStreets() -> [FoodStreet] {
        let descriptor = FetchDescriptor<FoodStreet>()
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    // MARK: - Loyalty Cache

    public func cacheLoyaltyCards(_ cards: [LoyaltyCard]) {
        cards.forEach { modelContext.insert($0) }
        save()
    }

    public func getCachedLoyaltyCards() -> [LoyaltyCard] {
        let descriptor = FetchDescriptor<LoyaltyCard>()
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    // MARK: - Wallet Cache

    public func cacheWalletTransactions(_ transactions: [WalletTransaction]) {
        transactions.forEach { modelContext.insert($0) }
        save()
    }

    public func getCachedWalletTransactions() -> [WalletTransaction] {
        let descriptor = FetchDescriptor<WalletTransaction>(sortBy: [SortDescriptor(\.timeEn, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    public func cacheWalletContacts(_ contacts: [WalletContact]) {
        contacts.forEach { modelContext.insert($0) }
        save()
    }

    public func getCachedWalletContacts() -> [WalletContact] {
        let descriptor = FetchDescriptor<WalletContact>()
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    // MARK: - Orders Cache

    public func cacheOrders(_ orders: [Order]) {
        orders.forEach { modelContext.insert($0) }
        save()
    }

    public func getCachedOrders() -> [Order] {
        let descriptor = FetchDescriptor<Order>(sortBy: [SortDescriptor(\.createdAtEpochMs, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    // MARK: - Group Orders Cache

    public func cacheGroupOrder(_ groupOrder: GroupOrder) {
        modelContext.insert(groupOrder)
        save()
    }

    public func getCachedGroupOrders() -> [GroupOrder] {
        let descriptor = FetchDescriptor<GroupOrder>()
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    // MARK: - Notifications Cache

    public func cacheNotifications(_ notifications: [KooiNotification]) {
        notifications.forEach { modelContext.insert($0) }
        save()
    }

    public func getCachedNotifications() -> [KooiNotification] {
        let descriptor = FetchDescriptor<KooiNotification>(sortBy: [SortDescriptor(\.timeEn, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }
}

/// User preferences matching the Kotlin `UserPreferences`
public struct UserPreferences: Codable {
    public var notificationsEnabled: Bool = true
    public var language: String = "ar"
    public var theme: String = "system"
    public var currency: String = "LYD"
    public var distanceUnit: String = "km"
    public var autoAcceptGroupInvites: Bool = false
    public var showNearbyOnly: Bool = false

    public init() {}

    public static func fromJson(_ json: [String: Any]) -> UserPreferences {
        var prefs = UserPreferences()
        prefs.notificationsEnabled = json["notificationsEnabled"] as? Bool ?? true
        prefs.language = json["language"] as? String ?? "ar"
        prefs.theme = json["theme"] as? String ?? "system"
        prefs.currency = json["currency"] as? String ?? "LYD"
        prefs.distanceUnit = json["distanceUnit"] as? String ?? "km"
        prefs.autoAcceptGroupInvites = json["autoAcceptGroupInvites"] as? Bool ?? false
        prefs.showNearbyOnly = json["showNearbyOnly"] as? Bool ?? false
        return prefs
    }
}