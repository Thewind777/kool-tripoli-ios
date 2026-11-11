import SwiftUI

// MARK: - Multi-Restaurant (Food Street) Screens

/// Multi-restaurant combined menu view
struct MultiRestaurantMenuView: View {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = MultiRestaurantMenuViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with street info and restaurant filter
                    MultiRestaurantHeaderView()

                    // Restaurant filter chips
                    if !viewModel.filteredRestaurants.isEmpty {
                        RestaurantFilterChipsView()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }

                    // Category tabs
                    CategoryTabsView(selectedCategory: $viewModel.selectedCategory)
                        .padding(.horizontal, 16)

                    // Special filter chips
                    SpecialFilterChipsView()
                        .padding(.horizontal, 16)

                    // Menu items
                    if viewModel.isLoading {
                        MenuSkeletonSection()
                    } else if viewModel.filteredItems.isEmpty {
                        EmptyMenuView(category: viewModel.selectedCategory)
                            .padding(.top, 60)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredItems) { item in
                                    MultiRestaurantMenuItemRow(item: item)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                        .refreshable {
                            viewModel.loadMenu()
                        }
                        .searchable(
                            text: $viewModel.searchQuery,
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: themeManager.isRTL ? "ابحث في القائمة الموحدة..." : "Search combined menu..."
                        )
                    }
                }
            }
            .navigationTitle(themeManager.isRTL ? "القائمة الموحدة" : "Combined Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { coordinator.dismissSheet() }) {
                        Image(systemName: themeManager.isRTL ? "chevron.right" : "chevron.left")
                            .font(.title2)
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.toggleCart() }) {
                        ZStack {
                            Image(systemName: "cart.fill")
                                .font(.title2)
                                .foregroundColor(themeManager.activePalette.primary)

                            if cartStore.totalCartCount > 0 {
                                Text("\(cartStore.totalCartCount)")
                                    .font(KooiTypography.labelSmall.font(locale: Locale.current))
                                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                                    .frame(minWidth: 18, minHeight: 18)
                                    .background(themeManager.activePalette.error)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
            }
        }
        .rtlLayout(themeManager.isRTL)
    }
}

/// Header for multi-restaurant menu
struct MultiRestaurantHeaderView: View {
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 12) {
            // Street name and info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(themeManager.isRTL ? restaurantsVM.activeMrStreet.nameAr : restaurantsVM.activeMrStreet.nameEn)
                        .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text(themeManager.isRTL ? restaurantsVM.activeMrStreet.vibeAr : restaurantsVM.activeMrStreet.vibeEn)
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                        .lineLimit(2)
                }

                Spacer()

                // Quote summary
                VStack(alignment: .trailing, spacing: 2) {
                    Text(ArabicNumeralFormatter.formatLYD(restaurantsVM.currentMrQuote.totalExpectedLogisticsLyd, isRTL: themeManager.isRTL))
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)

                    Text(themeManager.isRTL ? "رسوم التوصيل والتنسيق" : "Delivery & Coordination Fees")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                }
            }

            // Selected restaurants
            HStack(spacing: 8) {
                ForEach(restaurantsVM.mrSelectedRestaurantIds.prefix(3).compactMap { id in
                    restaurantsVM.restaurants.first { $0.id == id }
                }) { restaurant in
                    MiniRestaurantBadge(restaurant: restaurant)
                }

                if restaurantsVM.mrSelectedRestaurantIds.count > 3 {
                    MiniCountBadge(count: restaurantsVM.mrSelectedRestaurantIds.count - 3)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(themeManager.activePalette.surface)
    }
}

struct MiniRestaurantBadge: View {
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 6) {
            AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    RestaurantImagePlaceholder(artType: restaurant.heroArt)
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())

            Text(restaurant.nameEn.prefix(12))
                .font(KooiTypography.labelSmall.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(themeManager.activePalette.primarySubtle)
        .clipShape(Capsule())
    }
}

struct MiniCountBadge: View {
    let count: Int
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Text("+\(count)")
            .font(KooiTypography.labelMedium.font(locale: Locale.current))
            .foregroundColor(themeManager.activePalette.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(themeManager.activePalette.primarySubtle)
            .clipShape(Capsule())
    }
}

/// Restaurant filter chips
struct RestaurantFilterChipsView: View {
    @EnvironmentObject private var viewModel: MultiRestaurantMenuViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: themeManager.isRTL ? "الكل" : "All",
                    isSelected: viewModel.restaurantFilterId == nil
                ) {
                    viewModel.setRestaurantFilter(nil)
                }

                ForEach(viewModel.filteredRestaurants) { restaurant in
                    FilterChip(
                        title: themeManager.isRTL ? restaurant.nameAr : restaurant.nameEn,
                        isSelected: viewModel.restaurantFilterId == restaurant.id
                    ) {
                        viewModel.setRestaurantFilter(restaurant.id)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                .foregroundColor(isSelected ? themeManager.activePalette.textOnPrimary : themeManager.activePalette.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected ? themeManager.activePalette.primary : themeManager.activePalette.surface
                )
                .clipShape(Capsule())
                .shadow(
                    color: isSelected ? themeManager.activePalette.primary.opacity(0.3) : themeManager.activePalette.overlayScrim,
                    radius: isSelected ? 8 : 4,
                    x: 0,
                    y: isSelected ? 4 : 2
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// Category tabs
struct CategoryTabsView: View {
    @Binding var selectedCategory: FoodCategory
    @EnvironmentObject private var themeManager: ThemeManager

    private let categories = FoodCategory.allCases

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    CategoryTabButton(
                        title: themeManager.isRTL ? category.labelAr : category.labelEn,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

/// Special filter chips (offers, bestsellers)
struct SpecialFilterChipsView: View {
    @EnvironmentObject private var viewModel: MultiRestaurantMenuViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    private let specialFilters = [
        (id: "offers", labelAr: "العروض", labelEn: "Offers"),
        (id: "bestsellers", labelAr: "الأكثر مبيعاً", labelEn: "Bestsellers")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(specialFilters, id: \.id) { filter in
                SpecialFilterChip(
                    title: themeManager.isRTL ? filter.labelAr : filter.labelEn,
                    isSelected: viewModel.mrSpecialFilter == filter.id
                ) {
                    viewModel.setSpecialFilter(filter.id)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

struct SpecialFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                .foregroundColor(isSelected ? themeManager.activePalette.textOnPrimary : themeManager.activePalette.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? themeManager.activePalette.accent : themeManager.activePalette.surface
                )
                .clipShape(Capsule())
                .shadow(
                    color: isSelected ? themeManager.activePalette.accent.opacity(0.3) : themeManager.activePalette.overlayScrim,
                    radius: isSelected ? 6 : 3,
                    x: 0,
                    y: isSelected ? 3 : 1
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// Menu item row for multi-restaurant
struct MultiRestaurantMenuItemRow: View {
    let item: MenuItem
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var cartStore: LocalCartStore

    var body: some View {
        Button(action: {
            coordinator.showItemDetail(item, restaurant: cartStore.restaurants.first { $0.id == item.restaurantId } ?? Restaurant.mock)
        }) {
            HStack(spacing: 12) {
                // Item image
                AsyncImage(url: URL(string: item.imageUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        ItemImagePlaceholder(artType: item.artType)
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Item info
                VStack(alignment: .leading, spacing: 6) {
                    // Restaurant badge
                    if let restaurant = cartStore.restaurants.first(where: { $0.id == item.restaurantId }) {
                        Text(themeManager.isRTL ? restaurant.nameAr : restaurant.nameEn)
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(themeManager.activePalette.primarySubtle)
                            .clipShape(Capsule())
                    }

                    Text(themeManager.isRTL ? item.nameAr : item.nameEn)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)
                        .lineLimit(1)

                    // Tags
                    HStack(spacing: 6) {
                        if item.isPopular {
                            TagView(text: themeManager.isRTL ? "شائع" : "Popular", color: themeManager.activePalette.warning)
                        }
                        if item.isCombo {
                            TagView(text: themeManager.isRTL ? "كومبو" : "Combo", color: themeManager.activePalette.success)
                        }
                        if let offerBadge = themeManager.isRTL ? item.offerBadgeAr : item.offerBadgeEn {
                            TagView(text: offerBadge, color: themeManager.activePalette.error)
                        }
                    }

                    // Price
                    HStack(spacing: 8) {
                        if let originalPrice = item.originalPriceLyd, originalPrice > item.priceLyd {
                            Text(ArabicNumeralFormatter.formatLYD(originalPrice, isRTL: themeManager.isRTL))
                                .font(KooiTypography.labelSmall.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.textDisabled)
                                .strikethrough()
                        }

                        Text(ArabicNumeralFormatter.formatLYD(item.priceLyd, isRTL: themeManager.isRTL))
                            .font(KooiTypography.titleMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: themeManager.isRTL ? "chevron.left" : "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.activePalette.textTertiary)
            }
            .padding(12)
            .background(themeManager.activePalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(
                color: themeManager.activePalette.overlayScrim,
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
    }
}

/// ViewModel for multi-restaurant menu
@MainActor
public final class MultiRestaurantMenuViewModel: ObservableObject {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel

    @Published public var isLoading: Bool = false
    @Published public var restaurantFilterId: String? = nil
    @Published public var selectedCategory: FoodCategory = .all
    @Published public var mrSpecialFilter: String? = nil
    @Published public var searchQuery: String = ""

    public var filteredRestaurants: [Restaurant] {
        restaurantsVM.mrSelectedRestaurantIds.compactMap { id in
            cartStore.restaurants.first { $0.id == id && $0.isAvailableForOrdering }
        }
    }

    public var filteredItems: [MenuItem] {
        let selectedStores = restaurantsVM.mrSelectedRestaurantIds.compactMap { id in
            cartStore.restaurants.first { $0.id == id }
        }

        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return selectedStores.flatMap { store in
            if let filterId = restaurantFilterId, store.id != filterId {
                return []
            }

            return store.menu.filter { item in
                let catMatch = selectedCategory == .all || store.category == selectedCategory
                let specialMatch = mrSpecialFilter == nil || {
                    switch mrSpecialFilter {
                    case "offers": return item.originalPriceLyd != nil || item.isCombo || item.offerBadgeAr != nil
                    case "bestsellers": return item.isPopular
                    default: return true
                    }
                }()
                let queryMatch = q.isEmpty ||
                    item.nameAr.lowercased().contains(q) ||
                    item.nameEn.lowercased().contains(q) ||
                    item.descriptionAr.lowercased().contains(q) ||
                    item.descriptionEn.lowercased().contains(q) ||
                    store.nameAr.lowercased().contains(q) ||
                    store.nameEn.lowercased().contains(q)

                return catMatch && specialMatch && queryMatch && item.isAvailable
            }
        }
    }

    public var isLoading: Bool = false

    public func loadMenu() { /* Load from API if needed */ }

    public func setRestaurantFilter(_ id: String?) {
        restaurantFilterId = id
    }

    public func setSpecialFilter(_ filter: String?) {
        mrSpecialFilter = mrSpecialFilter == filter ? nil : filter
    }

    public func toggleCart() { /* Show cart sheet */ }
}