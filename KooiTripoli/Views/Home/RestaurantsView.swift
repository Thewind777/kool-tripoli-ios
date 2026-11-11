import SwiftUI

/// Home view with hero section, feature cards, and restaurant collections
struct HomeView: View {
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: themeManager.activePalette.spacing?.sectionGap ?? 20, pinnedViews: []) {
                        // Hero Section
                        HeroSectionView()

                        // Smart Features Carousel
                        SmartFeaturesCarouselView()

                        // Cuisine Categories
                        CuisineCategoriesView()

                        // Restaurant Collections
                        RestaurantCollectionSectionView(
                            title: themeManager.isRTL ? "أقرب إليك" : "Nearest to You",
                            filter: .nearby,
                            restaurants: restaurantsVM.filteredRestaurants().filter { $0.isNearby }
                        )

                        RestaurantCollectionSectionView(
                            title: themeManager.isRTL ? "العروض" : "Offers",
                            filter: .offers,
                            restaurants: restaurantsVM.filteredRestaurants().filter { $0.hasOffer }
                        )

                        RestaurantCollectionSectionView(
                            title: themeManager.isRTL ? "الأكثر شعبية" : "Most Popular",
                            filter: .popular,
                            restaurants: restaurantsVM.filteredRestaurants().filter { $0.isPopular }
                        )

                        RestaurantCollectionSectionView(
                            title: themeManager.isRTL ? "مقترحة لك" : "Recommended",
                            filter: .recommended,
                            restaurants: restaurantsVM.filteredRestaurants().filter { $0.isRecommended }
                        )

                        RestaurantCollectionSectionView(
                            title: themeManager.isRTL ? "جديد في كوي" : "New on KOOI",
                            filter: .new,
                            restaurants: restaurantsVM.filteredRestaurants().filter { $0.isNew }
                        )

                        // Bottom spacing for cart bar
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                }
                .refreshable {
                    restaurantsVM.refreshRestaurants()
                }
                .searchable(
                    text: $restaurantsVM.searchQuery,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: themeManager.isRTL ? "ابحث عن مطاعم، أطباق..." : "Search restaurants, dishes..."
                )
                .onSubmit(of: .search) {
                    // Search is handled by filteredRestaurants()
                }
            }
            .navigationTitle(themeManager.isRTL ? "كوي" : "KOOI")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { coordinator.showProfile() }) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }
            }
        }
    }
}

/// Hero section with promotional content
struct HeroSectionView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 12) {
            // Main hero card
            HeroCardView(
                title: themeManager.isRTL ? "أسرع توصيل في طرابلس" : "Fastest Delivery in Tripoli",
                subtitle: themeManager.isRTL ? "مطاعمك المفضلة تصل إليك في دقائق" : "Your favorite restaurants delivered in minutes",
                ctaTitle: themeManager.isRTL ? "استكشف المطاعم" : "Explore Restaurants",
                backgroundColor: themeManager.activePalette.primary,
                foregroundColor: themeManager.activePalette.textOnPrimary
            ) {
                coordinator.selectTab(.restaurants)
            }

            // Secondary hero cards (scrollable)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    HeroCardView(
                        title: themeManager.isRTL ? "طلب شارع MR" : "MR Street Order",
                        subtitle: themeManager.isRTL ? "عدة مطاعم، سلة واحدة" : "Multiple restaurants, one cart",
                        ctaTitle: themeManager.isRTL ? "جرب الآن" : "Try Now",
                        backgroundColor: themeManager.activePalette.accent,
                        foregroundColor: themeManager.activePalette.textOnPrimary,
                        icon: "map.fill"
                    ) {
                        coordinator.showAllFoodStreets()
                    }
                    .frame(width: 280)

                    HeroCardView(
                        title: themeManager.isRTL ? "سلة جماعية" : "Group Cart",
                        subtitle: themeManager.isRTL ? "اطلب مع الأصدقاء" : "Order with friends",
                        ctaTitle: themeManager.isRTL ? "ابدأ مجموعة" : "Start Group",
                        backgroundColor: themeManager.activePalette.success,
                        foregroundColor: themeManager.activePalette.textOnPrimary,
                        icon: "person.3.fill"
                    ) {
                        coordinator.showGroupOrder()
                    }
                    .frame(width: 280)
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct HeroCardView: View {
    let title: String
    let subtitle: String
    let ctaTitle: String
    let backgroundColor: Color
    let foregroundColor: Color
    var icon: String? = nil
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                            .foregroundColor(foregroundColor)
                            .multilineTextAlignment(.leading)

                        Text(subtitle)
                            .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                            .foregroundColor(foregroundColor.opacity(0.9))
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(foregroundColor.opacity(0.8))
                    }
                }

                Text(ctaTitle)
                    .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                    .foregroundColor(backgroundColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(foregroundColor)
                    .clipShape(Capsule())
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(
                color: backgroundColor.opacity(0.3),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
    }
}

/// Smart features carousel
struct SmartFeaturesCarouselView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    private let features = [
        (id: "mr_order", icon: "map.fill", titleAr: "طلب شارع MR", titleEn: "MR Street Order", subtitleAr: "عدة مطاعم، سلة واحدة", subtitleEn: "Multiple restaurants, one cart"),
        (id: "group_cart", icon: "person.3.fill", titleAr: "سلة جماعية", titleEn: "Group Cart", subtitleAr: "كل شخص يدفع حصته", subtitleEn: "Everyone pays their share"),
        (id: "book_order", icon: "calendar.badge.clock", titleAr: "حجز طلب", titleEn: "Book Order", subtitleAr: "خصم خارج الذروة", subtitleEn: "Off-peak discount"),
        (id: "loyalty", icon: "seal.fill", titleAr: "ولاء كوي", titleEn: "KOOI Loyalty", subtitleAr: "أختم واكسب وجبات مجانية", subtitleEn: "Collect stamps, earn free meals")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "خدمات كوي الذكية" : "KOOI Smart Features")
                .font(KooiTypography.titleLarge.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(features, id: \.id) { feature in
                        FeatureCardView(
                            icon: feature.icon,
                            title: themeManager.isRTL ? feature.titleAr : feature.titleEn,
                            subtitle: themeManager.isRTL ? feature.subtitleAr : feature.subtitleEn,
                            color: featureColor(for: feature.id)
                        ) {
                            handleFeatureTap(feature.id)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private func featureColor(for id: String) -> Color {
        switch id {
        case "mr_order": return Color(hex: 0xFF8B5CF6) // Purple
        case "group_cart": return Color(hex: 0xFFEC4899) // Pink
        case "book_order": return Color(hex: 0xFF06B6D4) // Cyan
        case "loyalty": return Color(hex: 0xFFF59E0B) // Amber
        default: return themeManager.activePalette.primary
        }
    }

    private func handleFeatureTap(_ id: String) {
        switch id {
        case "mr_order": coordinator.showAllFoodStreets()
        case "group_cart": coordinator.showGroupOrder()
        case "book_order": coordinator.selectTab(.restaurants) // Would show scheduled offers
        case "loyalty": coordinator.showLoyalty()
        default: break
        }
    }
}

struct FeatureCardView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 56, height: 56)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .frame(width: 160, alignment: .leading)
            .background(themeManager.activePalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: themeManager.activePalette.overlayScrim,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }
}

/// Cuisine categories horizontal scroll
struct CuisineCategoriesView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel

    private let categories = FoodCategory.allCases.filter { $0 != .all }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "المطابخ" : "Cuisines")
                .font(KooiTypography.titleLarge.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    CategoryChipView(
                        title: themeManager.isRTL ? "الكل" : "All",
                        icon: "square.grid.2x2",
                        isSelected: restaurantsVM.activeCategoryFilter == .all,
                        color: themeManager.activePalette.primary
                    ) {
                        restaurantsVM.selectCategoryFilter(.all)
                    }

                    ForEach(categories) { category in
                        CategoryChipView(
                            title: themeManager.isRTL ? category.labelAr : category.labelEn,
                            icon: categoryIcon(for: category),
                            isSelected: restaurantsVM.activeCategoryFilter == category,
                            color: categoryColor(for: category)
                        ) {
                            restaurantsVM.selectCategoryFilter(category)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private func categoryIcon(for category: FoodCategory) -> String {
        switch category {
        case .pizza: return "circle.lefthalf.filled"
        case .burger: return "hamburger"
        case .libyan: return "building.columns"
        case .grill: return "flame.fill"
        case .sushi: return "fish.fill"
        case .sweets: return "cup.and.saucer.fill"
        case .all: return "square.grid.2x2"
        }
    }

    private func categoryColor(for category: FoodCategory) -> Color {
        switch category {
        case .pizza: return Color(hex: 0xFFEF4444) // Red
        case .burger: return Color(hex: 0xFFF97316) // Orange
        case .libyan: return Color(hex: 0xFF84CC16) // Lime
        case .grill: return Color(hex: 0xFFDC2626) // Red
        case .sushi: return Color(hex: 0xFF06B6D4) // Cyan
        case .sweets: return Color(hex: 0xFFEC4899) // Pink
        case .all: return themeManager.activePalette.primary
        }
    }
}

struct CategoryChipView: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))

                Text(title)
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
            }
            .foregroundColor(isSelected ? themeManager.activePalette.textOnPrimary : themeManager.activePalette.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ? color : themeManager.activePalette.surface
            )
            .clipShape(Capsule())
            .shadow(
                color: isSelected ? color.opacity(0.3) : themeManager.activePalette.overlayScrim,
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// Restaurant collection section (e.g., "Nearby", "Popular", "Offers")
struct RestaurantCollectionSectionView: View {
    let title: String
    let filter: RestaurantCollectionFilter
    let restaurants: [Restaurant]
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        if !restaurants.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(KooiTypography.titleLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Spacer()

                    Button(action: {
                        coordinator.navigate(to: .restaurants(collection: filter, category: nil))
                    }) {
                        Text(themeManager.isRTL ? "عرض الكل" : "See All")
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(restaurants.prefix(10)) { restaurant in
                            RestaurantCardView(restaurant: restaurant)
                                .frame(width: 280)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

/// Skeleton loader for restaurant cards
struct RestaurantCardSkeletonView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image skeleton
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.activePalette.skeletonBase)
                .frame(width: 280, height: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.activePalette.skeletonHighlight)
                        .mask(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.5), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: -280)
                        .animation(
                            .linear(duration: 1.5).repeatForever(autoreverses: false),
                            value: UUID()
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

            // Content skeleton
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(themeManager.activePalette.skeletonBase)
                    .frame(width: 160, height: 20)

                RoundedRectangle(cornerRadius: 4)
                    .fill(themeManager.activePalette.skeletonBase)
                    .frame(width: 100, height: 14)

                HStack(spacing: 8) {
                    Circle()
                        .fill(themeManager.activePalette.skeletonBase)
                        .frame(width: 24, height: 24)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeManager.activePalette.skeletonBase)
                        .frame(width: 60, height: 14)
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(themeManager.activePalette.skeletonBase)
                            .frame(width: 12, height: 12)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(themeManager.activePalette.skeletonBase)
                            .frame(width: 40, height: 12)
                    }

                    HStack(spacing: 4) {
                        Circle()
                            .fill(themeManager.activePalette.skeletonBase)
                            .frame(width: 12, height: 12)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(themeManager.activePalette.skeletonBase)
                            .frame(width: 50, height: 12)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: themeManager.activePalette.overlayScrim,
            radius: 6,
            x: 0,
            y: 3
        )
        .frame(width: 280)
        .redacted(reason: .placeholder)
    }
}