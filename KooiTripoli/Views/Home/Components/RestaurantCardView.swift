import SwiftUI

/// Restaurant card view for home screen and collections
struct RestaurantCardView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var cartStore: LocalCartStore

    var body: some View {
        Button(action: {
            coordinator.showRestaurantDetail(restaurant.id)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Restaurant image with overlay badges
                ZStack(alignment: .topLeading) {
                    // Main image
                    AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { phase in
                        switch phase {
                        case .empty:
                            RestaurantImageSkeleton()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 280, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        case .failure:
                            RestaurantImagePlaceholder(artType: restaurant.heroArt)
                        @unknown default:
                            RestaurantImagePlaceholder(artType: restaurant.heroArt)
                        }
                    }

                    // Operational status badge
                    if restaurant.operationalStatus != .open {
                        StatusBadgeView(status: restaurant.operationalStatus)
                            .padding(8)
                    }

                    // Promo tag
                    if let promoTag = restaurant.promoTagAr ?? restaurant.promoTagEn {
                        PromoBadgeView(text: themeManager.isRTL ? (restaurant.promoTagAr ?? promoTag) : (restaurant.promoTagEn ?? promoTag))
                            .padding(8)
                            .alignmentGuide(.top) { d in d[.top] + 40 }
                    }

                    // New badge
                    if restaurant.isNew {
                        NewBadgeView()
                            .padding(8)
                            .alignmentGuide(.top) { d in d[.top] + 40 }
                            .alignmentGuide(.trailing) { d in d[.trailing] - 8 }
                    }
                }
                .frame(width: 280, height: 160)

                // Restaurant info
                VStack(alignment: .leading, spacing: 6) {
                    // Name
                    Text(themeManager.isRTL ? restaurant.nameAr : restaurant.nameEn)
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)
                        .lineLimit(1)

                    // Cuisine & District
                    HStack(spacing: 8) {
                        // Cuisine icon
                        Image(systemName: cuisineIcon)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.activePalette.textTertiary)

                        Text(themeManager.isRTL ? restaurant.cuisineAr : restaurant.cuisineEn)
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                            .lineLimit(1)

                        // Divider
                        Circle()
                            .fill(themeManager.activePalette.borderSubtle)
                            .frame(width: 3, height: 3)

                        // District
                        Image(systemName: "location.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.activePalette.textTertiary)

                        Text(themeManager.isRTL ? restaurant.districtAr : restaurant.districtEn)
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                            .lineLimit(1)
                    }

                    // Rating, Delivery time, Distance
                    HStack(spacing: 12) {
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.activePalette.accent)

                            Text(String(format: "%.1f", restaurant.rating))
                                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.textSecondary)
                        }

                        // Divider
                        Circle()
                            .fill(themeManager.activePalette.borderSubtle)
                            .frame(width: 3, height: 3)

                        // Delivery time
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.activePalette.textTertiary)

                            Text("\(restaurant.deliveryMinutes) \(themeManager.isRTL ? "د" : "min")")
                                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.textSecondary)
                        }

                        // Divider
                        Circle()
                            .fill(themeManager.activePalette.borderSubtle)
                            .frame(width: 3, height: 3)

                        // Distance
                        HStack(spacing: 4) {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.activePalette.textTertiary)

                            Text(ArabicNumeralFormatter.formatDistanceKm(restaurant.distanceKm, isRTL: themeManager.isRTL))
                                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.textSecondary)
                        }
                    }

                    // Loyalty progress
                    if restaurant.loyaltyTarget > 0 {
                        LoyaltyProgressView(
                            completed: restaurant.loyaltyCompleted,
                            target: restaurant.loyaltyTarget
                        )
                    }

                    // Delivery fee & Min order
                    HStack(spacing: 12) {
                        Label(
                            ArabicNumeralFormatter.formatLYD(restaurant.deliveryFeeLyd, isRTL: themeManager.isRTL),
                            systemImage: "bicycle.circle.fill"
                        )
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)

                        if restaurant.minDeliveryOrderLyd > 0 {
                            Label(
                                themeManager.isRTL ? "حد أدنى \(ArabicNumeralFormatter.formatLYD(restaurant.minDeliveryOrderLyd, isRTL: themeManager.isRTL))" : "Min \(ArabicNumeralFormatter.formatLYD(restaurant.minDeliveryOrderLyd, isRTL: themeManager.isRTL))",
                                systemImage: "cart.circle.fill"
                            )
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
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
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: {
                coordinator.showRestaurantDetail(restaurant.id)
            }) {
                Label(themeManager.isRTL ? "عرض القائمة" : "View Menu", systemImage: "menucard")
            }

            if restaurant.supportsPickup {
                Button(action: {
                    // Switch to pickup for this restaurant
                }) {
                    Label(themeManager.isRTL ? "استلام من المطعم" : "Pickup", systemImage: "takeoutbag.and.cup.and.straw.fill")
                }
            }
        }
    }

    private var cuisineIcon: String {
        switch restaurant.category {
        case .pizza: return "circle.lefthalf.filled"
        case .burger: return "hamburger"
        case .libyan: return "building.columns"
        case .grill: return "flame.fill"
        case .sushi: return "fish.fill"
        case .sweets: return "cup.and.saucer.fill"
        case .all: return "square.grid.2x2"
        }
    }
}

/// Restaurant image skeleton
struct RestaurantImageSkeleton: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
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
    }
}

/// Restaurant image placeholder with dish art
struct RestaurantImagePlaceholder: View {
    let artType: DishArtType
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.activePalette.surfaceSubtle)
                .frame(width: 280, height: 160)

            Image(systemName: artSystemImage)
                .font(.system(size: 60, weight: .light))
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

/// Status badge for operational status
struct StatusBadgeView: View {
    let status: RestaurantOperationalStatus
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Text(themeManager.isRTL ? status.labelAr : status.labelEn)
            .font(KooiTypography.labelSmall.font(locale: Locale.current))
            .foregroundColor(themeManager.activePalette.textOnPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor)
            .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch status {
        case .open: return themeManager.activePalette.success
        case .closingSoon: return themeManager.activePalette.warning
        case .capacityLimited: return themeManager.activePalette.warning
        case .temporarilyUnavailable: return themeManager.activePalette.textDisabled
        case .closed: return themeManager.activePalette.error
        }
    }
}

/// Promo badge
struct PromoBadgeView: View {
    let text: String
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Text(text)
            .font(KooiTypography.labelSmall.font(locale: Locale.current))
            .foregroundColor(themeManager.activePalette.textOnPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(themeManager.activePalette.accent)
            .clipShape(Capsule())
    }
}

/// New badge
struct NewBadgeView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Text(themeManager.isRTL ? "جديد" : "New")
            .font(KooiTypography.labelSmall.font(locale: Locale.current))
            .foregroundColor(themeManager.activePalette.textOnPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(themeManager.activePalette.success)
            .clipShape(Capsule())
    }
}

/// Loyalty progress indicator
struct LoyaltyProgressView: View {
    let completed: Int
    let target: Int
    @EnvironmentObject private var themeManager: ThemeManager

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(completed) / Double(target), 1.0)
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(themeManager.isRTL ? "بطاقة الولاء" : "Loyalty Card")
                    .font(KooiTypography.labelSmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)

                Spacer()

                Text("\(completed)/\(target)")
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: themeManager.activePalette.primary))
                .scaleEffect(y: 1.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
        }
    }
}