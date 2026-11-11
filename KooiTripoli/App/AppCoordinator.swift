import SwiftUI
import Combine

/// App Coordinator handling navigation flow
/// Mirrors the Compose navigation with Coordinator pattern
public enum AppRoute: Hashable {
    case onboarding
    case home
    case restaurants(collection: RestaurantCollectionFilter? = nil, category: FoodCategory? = nil)
    case restaurantDetail(restaurantId: String)
    case itemDetail(menuItem: MenuItem, restaurant: Restaurant)
    case cart
    case checkout
    case orderTracking(orderNumber: String)
    case groupOrder(groupId: String?)
    case loyalty
    case wallet
    case addresses
    case profile
    case settings
    case notifications
    case support
    case foodStreets
    case foodStreetDetail(streetId: String)
}

@MainActor
public final class AppCoordinator: ObservableObject {
    @Published public var navigationPath = NavigationPath()
    @Published public var selectedTab: PrimaryTab = .home
    @Published public var presentedSheet: AppRoute?
    @Published public var presentedFullScreen: AppRoute?

    // Deep link handling
    public func handleDeepLink(_ url: URL) {
        guard url.scheme == "kooi" else { return }

        let components = url.pathComponents.filter { $0 != "/" }

        switch components.first {
        case "restaurant":
            if components.count > 1 {
                navigate(to: .restaurantDetail(restaurantId: components[1]))
            }
        case "item":
            if components.count > 1 {
                // Would need to fetch item details
            }
        case "group":
            if components.count > 1 {
                navigate(to: .groupOrder(groupId: components[1]))
            }
        case "order":
            if components.count > 1 {
                navigate(to: .orderTracking(orderNumber: components[1]))
            }
        case "onboarding":
            navigate(to: .onboarding)
        default:
            break
        }
    }

    // MARK: - Navigation Methods

    public func navigate(to route: AppRoute) {
        navigationPath.append(route)
    }

    public func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    public func navigateToRoot() {
        navigationPath = NavigationPath()
    }

    public func presentSheet(_ route: AppRoute) {
        presentedSheet = route
    }

    public func dismissSheet() {
        presentedSheet = nil
    }

    public func presentFullScreen(_ route: AppRoute) {
        presentedFullScreen = route
    }

    public func dismissFullScreen() {
        presentedFullScreen = nil
    }

    // MARK: - Tab Navigation

    public func selectTab(_ tab: PrimaryTab) {
        selectedTab = tab
        navigateToRoot()
    }

    // MARK: - Convenience Methods

    public func showRestaurantDetail(_ restaurantId: String) {
        navigate(to: .restaurantDetail(restaurantId: restaurantId))
    }

    public func showItemDetail(_ menuItem: MenuItem, restaurant: Restaurant) {
        navigate(to: .itemDetail(menuItem: menuItem, restaurant: restaurant))
    }

    public func showCart() {
        navigate(to: .cart)
    }

    public func showCheckout() {
        navigate(to: .checkout)
    }

    public func showGroupOrder(groupId: String? = nil) {
        navigate(to: .groupOrder(groupId: groupId))
    }

    public func showFoodStreet(_ streetId: String) {
        navigate(to: .foodStreetDetail(streetId: streetId))
    }

    public func showAllFoodStreets() {
        navigate(to: .foodStreets)
    }

    public func showLoyalty() {
        navigate(to: .loyalty)
    }

    public func showWallet() {
        navigate(to: .wallet)
    }

    public func showProfile() {
        navigate(to: .profile)
    }

    public func showSettings() {
        navigate(to: .settings)
    }
}

/// Main App View with Coordinator
struct AppCoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    @EnvironmentObject private var onboardingVM: OnboardingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var cartStore: LocalCartStore

    var body: some View {
        Group {
            if OnboardingViewModel.hasCompletedOnboarding() {
                MainTabView()
                    .environmentObject(coordinator)
            } else {
                OnboardingView()
                    .environmentObject(onboardingVM)
                    .onAppear {
                        onboardingVM.startOnboarding()
                    }
            }
        }
        .sheet(item: $coordinator.presentedSheet) { route in
            sheetView(for: route)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { route in
            fullScreenView(for: route)
        }
    }

    @ViewBuilder
    private func sheetView(for route: AppRoute) -> some View {
        switch route {
        case .itemDetail(let menuItem, let restaurant):
            ItemDetailView(menuItem: menuItem, restaurant: restaurant)
        case .cart:
            CartView()
        case .checkout:
            CheckoutView()
        case .groupOrder(let groupId):
            GroupOrderView(groupId: groupId)
        case .foodStreetDetail(let streetId):
            FoodStreetDetailView(streetId: streetId)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func fullScreenView(for route: AppRoute) -> some View {
        switch route {
        case .onboarding:
            OnboardingView()
                .environmentObject(onboardingVM)
        default:
            EmptyView()
        }
    }
}

/// Main Tab View
struct MainTabView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            // Home Tab
            NavigationStack(path: $coordinator.navigationPath) {
                HomeView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label(
                    themeManager.isRTL ? PrimaryTab.home.labelAr : PrimaryTab.home.labelEn,
                    systemImage: "house.fill"
                )
            }
            .tag(PrimaryTab.home)

            // Restaurants Tab
            NavigationStack(path: $coordinator.navigationPath) {
                RestaurantsView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label(
                    themeManager.isRTL ? PrimaryTab.restaurants.labelAr : PrimaryTab.restaurants.labelEn,
                    systemImage: "fork.knife"
                )
            }
            .tag(PrimaryTab.restaurants)

            // Food Streets Tab
            NavigationStack(path: $coordinator.navigationPath) {
                FoodStreetsView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label(
                    themeManager.isRTL ? PrimaryTab.foodStreets.labelAr : PrimaryTab.foodStreets.labelEn,
                    systemImage: "road.lanes"
                )
            }
            .tag(PrimaryTab.foodStreets)

            // Loyalty/Circle Tab
            NavigationStack(path: $coordinator.navigationPath) {
                LoyaltyView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label(
                    themeManager.isRTL ? PrimaryTab.circle.labelAr : PrimaryTab.circle.labelEn,
                    systemImage: "seal.fill"
                )
            }
            .tag(PrimaryTab.circle)
        }
        .overlay(alignment: .bottom) {
            if cartStore.totalCartCount > 0 {
                GroupCartBarView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: cartStore.totalCartCount)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView()
        case .restaurants(let collection, let category):
            RestaurantsView(initialCollection: collection, initialCategory: category)
        case .restaurantDetail(let restaurantId):
            RestaurantDetailView(restaurantId: restaurantId)
        case .itemDetail(let menuItem, let restaurant):
            ItemDetailView(menuItem: menuItem, restaurant: restaurant)
        case .cart:
            CartView()
        case .checkout:
            CheckoutView()
        case .orderTracking(let orderNumber):
            OrderTrackingView(orderNumber: orderNumber)
        case .groupOrder(let groupId):
            GroupOrderView(groupId: groupId)
        case .loyalty:
            LoyaltyView()
        case .wallet:
            WalletView()
        case .addresses:
            AddressesView()
        case .profile:
            ProfileView()
        case .settings:
            SettingsView()
        case .notifications:
            NotificationsView()
        case .support:
            SupportView()
        case .foodStreets:
            FoodStreetsView()
        case .foodStreetDetail(let streetId):
            FoodStreetDetailView(streetId: streetId)
        case .onboarding:
            OnboardingView()
        }
    }
}