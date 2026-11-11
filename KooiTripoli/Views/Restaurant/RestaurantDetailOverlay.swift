import SwiftUI

// MARK: - Restaurant Detail Overlay

/// Restaurant detail overlay (bottom sheet style)
struct RestaurantDetailOverlayView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var cartVM: CartViewModel

    let restaurantId: String

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
                            // Hero image
                            RestaurantHeroImageView(restaurant: restaurant)

                            // Info section
                            RestaurantInfoSectionView(restaurant: restaurant)

                            // Category tabs
                            CategoryTabsView(selectedCategory: .constant(.all))
                                .padding(.horizontal, 16)

                            // Menu items
                            MenuItemsView(
                                restaurant: restaurant,
                                category: .all,
                                searchQuery: ""
                            )
                        }
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(restaurant?.nameEn ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { coordinator.dismissSheet() }) {
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

/// Hero image for restaurant overlay
struct RestaurantHeroImageView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: restaurant.coverImageUrl ?? restaurant.imageUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    RestaurantImagePlaceholder(artType: restaurant.heroArt)
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
    }
}

/// Restaurant info section
struct RestaurantInfoSectionView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
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

            // Loyalty card preview
            if restaurant.loyaltyTarget > 0 {
                LoyaltyCardPreviewView(restaurant: restaurant)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(themeManager.activePalette.background)
    }
}

/// Menu items view for restaurant detail
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

/// Empty menu state
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
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .empty:
                        ItemImagePlaceholder(artType: item.artType)
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