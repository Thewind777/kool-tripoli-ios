import SwiftUI

/// Restaurant detail view with menu, categories, and info
struct RestaurantDetailView: View {
    let restaurantId: String
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedCategory: FoodCategory = .all
    @State private var searchQuery: String = ""
    @State private var isLoadingMenu: Bool = false

    private var restaurant: Restaurant? {
        restaurantsVM.restaurants.first { $0.id == restaurantId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                if let restaurant = restaurant {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Restaurant header
                            RestaurantHeaderView(restaurant: restaurant)

                            // Category tabs
                            CategoryTabsView(selectedCategory: $selectedCategory)

                            // Menu items
                            MenuItemsView(
                                restaurant: restaurant,
                                category: selectedCategory,
                                searchQuery: searchQuery
                            )
                        }
                    }
                    .searchable(
                        text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: themeManager.isRTL ? "ابحث في القائمة..." : "Search menu..."
                    )
                } else {
                    // Loading state
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(restaurant?.nameEn ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { coordinator.navigateBack() }) {
                        Image(systemName: themeManager.isRTL ? "chevron.right" : "chevron.left")
                            .font(.title2)
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }
            }
        }
        .rtlLayout(themeManager.isRTL)
    }
}

/// Restaurant header with image, info, and actions
struct RestaurantHeaderView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 0) {
            // Hero image
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: restaurant.coverImageUrl ?? restaurant.imageUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(themeManager.activePalette.surfaceSubtle)
                            .overlay {
                                Image(systemName: restaurant.heroArt.artSystemImage)
                                    .font(.system(size: 60, weight: .light))
                                    .foregroundColor(themeManager.activePalette.primary.opacity(0.3))
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(themeManager.activePalette.surfaceSubtle)
                            .overlay {
                                Image(systemName: restaurant.heroArt.artSystemImage)
                                    .font(.system(size: 60, weight: .light))
                                    .foregroundColor(themeManager.activePalette.primary.opacity(0.3))
                            }
                    @unknown default:
                        Rectangle()
                            .fill(themeManager.activePalette.surfaceSubtle)
                    }
                }
                .frame(height: 240)
                .clipped()

                // Gradient overlay
                LinearGradient(
                    colors: [
                        themeManager.activePalette.background.opacity(0),
                        themeManager.activePalette.background.opacity(0.8)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 120)
            }
            .frame(height: 240)

            // Info section
            VStack(alignment: .leading, spacing: 16) {
                // Name, rating, badges
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(themeManager.isRTL ? restaurant.nameAr : restaurant.nameEn)
                            .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textPrimary)

                        HStack(spacing: 12) {
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.activePalette.accent)

                                Text(String(format: "%.1f", restaurant.rating))
                                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                    .foregroundColor(themeManager.activePalette.textSecondary)
                            }

                            // Delivery time
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.activePalette.textTertiary)

                                Text("\(restaurant.deliveryMinutes) \(themeManager.isRTL ? "د" : "min")")
                                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                    .foregroundColor(themeManager.activePalette.textSecondary)
                            }

                            // Distance
                            HStack(spacing: 4) {
                                Image(systemName: "location.circle.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.activePalette.textTertiary)

                                Text(ArabicNumeralFormatter.formatDistanceKm(restaurant.distanceKm, isRTL: themeManager.isRTL))
                                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                    .foregroundColor(themeManager.activePalette.textSecondary)
                            }
                        }

                        // Cuisine & District
                        Text("\(themeManager.isRTL ? restaurant.cuisineAr : restaurant.cuisineEn) · \(themeManager.isRTL ? restaurant.districtAr : restaurant.districtEn)")
                            .font(KooiTypography.bodySmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                    }

                    Spacer()

                    // Favorite button
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .font(.title2)
                            .foregroundColor(themeManager.activePalette.primary)
                            .padding(12)
                            .background(themeManager.activePalette.surface)
                            .clipShape(Circle())
                            .shadow(
                                color: themeManager.activePalette.overlayScrim,
                                radius: 6,
                                x: 0,
                                y: 3
                            )
                    }
                }

                // Action buttons
                HStack(spacing: 12) {
                    // Delivery/Pickup toggle
                    Menu {
                        Button(action: {}) {
                            Label(themeManager.isRTL ? "توصيل" : "Delivery", systemImage: "bicycle.circle")
                        }
                        if restaurant.supportsPickup {
                            Button(action: {}) {
                                Label(themeManager.isRTL ? "استلام" : "Pickup", systemImage: "takeoutbag.and.cup.and.straw.fill")
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bicycle.circle.fill")
                            Text(themeManager.isRTL ? "توصيل" : "Delivery")
                        }
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(themeManager.activePalette.primarySubtle)
                        .clipShape(Capsule())
                    }

                    // Delivery fee
                    Text(ArabicNumeralFormatter.formatLYD(restaurant.deliveryFeeLyd, isRTL: themeManager.isRTL))
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)

                    Spacer()

                    // Share
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(themeManager.activePalette.textSecondary)
                            .padding(12)
                            .background(themeManager.activePalette.surface)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(themeManager.activePalette.background)

            // Loyalty card preview
            if restaurant.loyaltyTarget > 0 {
                LoyaltyCardPreviewView(restaurant: restaurant)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
    }
}

/// Loyalty card preview in restaurant header
struct LoyaltyCardPreviewView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager

    private var progress: Double {
        guard restaurant.loyaltyTarget > 0 else { return 0 }
        return min(Double(restaurant.loyaltyCompleted) / Double(restaurant.loyaltyTarget), 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "seal.fill")
                    .font(.title3)
                    .foregroundColor(themeManager.activePalette.accent)

                Text(themeManager.isRTL ? "بطاقة ولاء \(restaurant.nameAr)" : "\(restaurant.nameEn) Loyalty Card")
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Spacer()

                if restaurant.loyaltyCompleted >= restaurant.loyaltyTarget {
                    Text(themeManager.isRTL ? "جاهزة للاستبدال!" : "Ready to redeem!")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.success)
                } else {
                    Text("\(restaurant.loyaltyCompleted)/\(restaurant.loyaltyTarget)")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
                }
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: themeManager.activePalette.primary))
                .scaleEffect(y: 2)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// Category tabs for menu filtering
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
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(themeManager.activePalette.background)
    }
}

struct CategoryTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                .foregroundColor(isSelected ? themeManager.activePalette.textOnPrimary : themeManager.activePalette.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
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

/// Menu items list
struct MenuItemsView: View {
    let restaurant: Restaurant
    let category: FoodCategory
    let searchQuery: String
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private var filteredItems: [MenuItem] {
        let items = restaurant.menu.filter { $0.isAvailable }
        let categoryFiltered = category == .all ? items : items.filter { item in
            // Map item category to food category
            FoodCategory.fromLiveCuisine(item.categoryAr) == category
        }
        if searchQuery.isEmpty {
            return categoryFiltered
        }
        let query = searchQuery.lowercased()
        return categoryFiltered.filter { item in
            item.nameAr.lowercased().contains(query) ||
            item.nameEn.lowercased().contains(query) ||
            item.descriptionAr.lowercased().contains(query) ||
            item.descriptionEn.lowercased().contains(query)
        }
    }

    var body: some View {
        if filteredItems.isEmpty {
            EmptyMenuView(category: category)
                .padding(.top, 60)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(filteredItems) { item in
                    MenuItemRowView(item: item, restaurant: restaurant)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

struct EmptyMenuView: View {
    let category: FoodCategory
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "menucard")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(themeManager.activePalette.textTertiary)

            Text(category == .all
                 ? (themeManager.isRTL ? "لا توجد أصناف متاحة" : "No items available")
                 : (themeManager.isRTL ? "لا توجد أصناف في \(category.labelAr)" : "No items in \(category.labelEn)"))
                .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Menu item row for restaurant detail
struct MenuItemRowView: View {
    let item: MenuItem
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        Button(action: {
            coordinator.showItemDetail(item, restaurant: restaurant)
        }) {
            HStack(spacing: 12) {
                // Item image
                AsyncImage(url: URL(string: item.imageUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ItemImagePlaceholder(artType: item.artType)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        ItemImagePlaceholder(artType: item.artType)
                    @unknown default:
                        ItemImagePlaceholder(artType: item.artType)
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Item info
                VStack(alignment: .leading, spacing: 6) {
                    Text(themeManager.isRTL ? item.nameAr : item.nameEn)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)
                        .lineLimit(1)

                    if let description = themeManager.isRTL ? item.descriptionAr : item.descriptionEn {
                        Text(description)
                            .font(KooiTypography.bodySmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                            .lineLimit(2)
                    }

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

struct ItemImagePlaceholder: View {
    let artType: DishArtType
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack {
            themeManager.activePalette.surfaceSubtle

            Image(systemName: artSystemImage)
                .font(.system(size: 30, weight: .light))
                .foregroundColor(themeManager.activePalette.primary.opacity(0.3))
        }
    }

    private var artSystemImage: String {
        switch artType {
        case .burgerCombo, .burgerStudio: return "hamburger"
        case .woodfiredPizza: return "circle.lefthalf.filled"
        case .sushiPlatter: return "fish.fill"
        case .tripoliMbatten: return "building.columns"
        case .seafoodCouscous: return "fish.fill"
        case .pistachioKunafa: return "cup.and.saucer.fill"
        case .lambKoftaGrill: return "flame.fill"
        }
    }
}