import SwiftUI

// MARK: - Restaurants & Tabs Screens

/// Restaurants tab with search, filters, and collections
struct RestaurantsTabView: View {
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16, pinnedViews: []) {
                        // Search bar
                        SearchBarView()
                            .padding(.horizontal, 16)

                        // Collection filters
                        CollectionFiltersView()

                        // Category filter
                        CategoryFilterView()

                        // Restaurant list
                        RestaurantListView()

                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, 16)
                }
                .refreshable {
                    restaurantsVM.refreshRestaurants()
                }
                .searchable(
                    text: $restaurantsVM.searchQuery,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: themeManager.isRTL ? "ابحث عن مطاعم، أطباق..." : "Search restaurants, dishes..."
                )
            }
            .navigationTitle(themeManager.isRTL ? "المطاعم" : "Restaurants")
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
        .rtlLayout(themeManager.isRTL)
    }
}

/// Search bar
struct SearchBarView: View {
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.activePalette.textTertiary)

            TextField(
                themeManager.isRTL ? "ابحث عن مطاعم، أطباق..." : "Search restaurants, dishes...",
                text: $restaurantsVM.searchQuery
            )
            .font(KooiTypography.bodyMedium.font(locale: Locale.current))
            .foregroundColor(themeManager.activePalette.textPrimary)

            if !restaurantsVM.searchQuery.isEmpty {
                Button(action: { restaurantsVM.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.activePalette.textTertiary)
                }
            }
        }
        .padding(12)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(
            color: themeManager.activePalette.overlayScrim,
            radius: 4,
            x: 0,
            y: 2
        )
    }
}

/// Collection filters (All, Offers, Recommended, Popular, New, Nearby)
struct CollectionFiltersView: View {
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(RestaurantCollectionFilter.allCases) { filter in
                        CollectionFilterChip(
                            filter: filter,
                            isSelected: restaurantsVM.activeCollectionFilter == filter
                        ) {
                            restaurantsVM.selectCollectionFilter(filter)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct CollectionFilterChip: View {
    let filter: RestaurantCollectionFilter
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(themeManager.isRTL ? filter.labelAr : filter.labelEn)
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(isSelected ? themeManager.activePalette.textOnPrimary : themeManager.activePalette.textPrimary)

                Text(themeManager.isRTL ? filter.subtitleAr : filter.subtitleEn)
                    .font(KooiTypography.labelSmall.font(locale: Locale.current))
                    .foregroundColor(isSelected ? themeManager.activePalette.textOnPrimary.opacity(0.8) : themeManager.activePalette.textTertiary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ? themeManager.activePalette.primary : themeManager.activePalette.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
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

/// Category filter (Pizza, Burger, Libyan, etc.)
struct CategoryFilterView: View {
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    private let categories = FoodCategory.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
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
        .padding(.horizontal, 16)
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
        case .pizza: return Color(hex: 0xFFEF4444)
        case .burger: return Color(hex: 0xFFF97316)
        case .libyan: return Color(hex: 0xFF84CC16)
        case .grill: return Color(hex: 0xFFDC2626)
        case .sushi: return Color(hex: 0xFF06B6D4)
        case .sweets: return Color(hex: 0xFFEC4899)
        case .all: return Color(hex: 0xFFD14A17)
        }
    }
}

/// Restaurant list with pagination
struct RestaurantListView: View {
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var cartStore: LocalCartStore

    var body: some View {
        VStack(spacing: 12) {
            if restaurantsVM.isLoadingRestaurants && restaurantsVM.restaurants.isEmpty {
                // Loading skeletons
                ForEach(0..<5) { _ in
                    RestaurantCardSkeleton()
                        .padding(.horizontal, 16)
                }
            } else if restaurantsVM.filteredRestaurants().isEmpty {
                EmptyRestaurantsView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(restaurantsVM.filteredRestaurants()) { restaurant in
                        RestaurantCardView(restaurant: restaurant)
                    }

                    // Load more trigger
                    if restaurantsVM.hasMoreRestaurantPages && !restaurantsVM.isLoadingMoreRestaurants {
                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                restaurantsVM.loadMoreRestaurants()
                            }
                    }

                    // Loading more indicator
                    if restaurantsVM.isLoadingMoreRestaurants {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct EmptyRestaurantsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(themeManager.activePalette.textTertiary)

            VStack(spacing: 8) {
                Text(themeManager.isRTL ? "لا توجد مطاعم" : "No Restaurants Found")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)

                Text(themeManager.isRTL ? "جرب تغيير الفلاتر أو البحث" : "Try changing filters or search")
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)
                    .multilineTextAlignment(.center)
            }

            Button(action: { restaurantsVM.clearAllFilters() }) {
                Text(themeManager.isRTL ? "مسح الفلاتر" : "Clear Filters")
                    .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .frame(width: 200)
                    .padding(.vertical, 14)
                    .background(themeManager.activePalette.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

/// Restaurant card skeleton
struct RestaurantCardSkeleton: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView()
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 8) {
                SkeletonView()
                    .frame(width: 160, height: 20)

                SkeletonView()
                    .frame(width: 100, height: 14)

                HStack(spacing: 8) {
                    SkeletonView()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())

                    SkeletonView()
                        .frame(width: 60, height: 14)
                }

                HStack(spacing: 12) {
                    SkeletonView()
                        .frame(width: 80, height: 14)

                    SkeletonView()
                        .frame(width: 80, height: 14)

                    SkeletonView()
                        .frame(width: 80, height: 14)
                }

                SkeletonView()
                    .frame(width: 120, height: 6)
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
    }
}