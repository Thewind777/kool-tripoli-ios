import SwiftUI

// MARK: - Food Streets Views

/// Food streets listing view
struct FoodStreetsView: View {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showAllStreets: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Header
                        HStack {
                            Text(themeManager.isRTL ? "شوارع الطعام" : "Food Streets")
                                .font(KooiTypography.displayMedium.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.textPrimary)

                            Spacer()

                            Button(action: { showAllStreets.toggle() }) {
                                Text(showAllStreets
                                     ? (themeManager.isRTL ? "إظهار أقل" : "Show Less")
                                     : (themeManager.isRTL ? "استكشف الكل" : "Explore All"))
                                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                    .foregroundColor(themeManager.activePalette.primary)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Featured street
                        if let featuredStreet = cartStore.getCachedFoodStreets().first {
                            FoodStreetCardView(street: featuredStreet, isFeatured: true)
                                .padding(.horizontal, 16)
                        }

                        // Other streets
                        ForEach(cartStore.getCachedFoodStreets().dropFirst()) { street in
                            FoodStreetCardView(street: street, isFeatured: false)
                                .padding(.horizontal, 16)
                        }

                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle(themeManager.isRTL ? "شوارع الطعام" : "Food Streets")
            .navigationBarTitleDisplayMode(.inline)
        }
        .rtlLayout(themeManager.isRTL)
    }
}

struct FoodStreetCardView: View {
    let street: FoodStreet
    let isFeatured: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        Button(action: { coordinator.showFoodStreet(street.id) }) {
            VStack(alignment: .leading, spacing: 0) {
                // Street image
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: "")) { phase in
                        switch phase {
                        case .empty:
                            StreetImagePlaceholder(artType: street.featuredArt)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            StreetImagePlaceholder(artType: street.featuredArt)
                        @unknown default:
                            StreetImagePlaceholder(artType: street.featuredArt)
                        }
                    }
                    .frame(height: isFeatured ? 200 : 160)
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
                    .frame(height: 80)
                }
                .frame(height: isFeatured ? 200 : 160)

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(themeManager.isRTL ? street.nameAr : street.nameEn)
                            .font(isFeatured ? KooiTypography.headlineLarge.font(locale: Locale.current) : KooiTypography.titleMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        // Vibe badge
                        Text("\(street.activeVendors) \(themeManager.isRTL ? "مطعم" : "Restaurants")")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(themeManager.activePalette.primarySubtle)
                            .clipShape(Capsule())
                    }

                    Text(themeManager.isRTL ? street.vibeAr : street.vibeEn)
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                        .lineLimit(2)

                    HStack(spacing: 16) {
                        Label("\(street.avgEtaMinutes) \(themeManager.isRTL ? "د" : "min")", systemImage: "clock.fill")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)

                        Label(ArabicNumeralFormatter.formatLYD(street.baseStreetDeliveryFeeLyd, isRTL: themeManager.isRTL), systemImage: "bicycle.circle.fill")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }
                .padding(16)
            }
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

struct StreetImagePlaceholder: View {
    let artType: DishArtType
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack {
            themeManager.activePalette.surfaceSubtle

            Image(systemName: artSystemImage)
                .font(.system(size: 80, weight: .light))
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

/// Food street detail with restaurant selection
struct FoodStreetDetailView: View {
    let streetId: String
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedRestaurants: Set<String> = []

    private var street: FoodStreet? {
        cartStore.getCachedFoodStreets().first { $0.id == streetId }
    }

    private var availableRestaurants: [Restaurant] {
        street?.restaurantIds.compactMap { id in
            restaurantsVM.restaurants.first { $0.id == id && $0.isAvailableForOrdering }
        } ?? []
    }

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                if let street = street {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Street header
                            FoodStreetHeaderView(street: street)

                            // Restaurant selection
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(themeManager.isRTL ? "اختر المطاعم (حد أقصى \(street.maxSelectableRestaurants))" : "Select Restaurants (Max \(street.maxSelectableRestaurants))")
                                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                                        .foregroundColor(themeManager.activePalette.textPrimary)

                                    Spacer()

                                    Text("\(selectedRestaurants.count)/\(street.maxSelectableRestaurants)")
                                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                        .foregroundColor(selectedRestaurants.count >= street.maxSelectableRestaurants ? themeManager.activePalette.error : themeManager.activePalette.primary)
                                }
                                .padding(.horizontal, 16)

                                ForEach(availableRestaurants) { restaurant in
                                    RestaurantSelectionRow(
                                        restaurant: restaurant,
                                        isSelected: selectedRestaurants.contains(restaurant.id),
                                        maxSelection: street.maxSelectableRestaurants,
                                        currentSelectionCount: selectedRestaurants.count
                                    ) { isSelected in
                                        if isSelected {
                                            selectedRestaurants.insert(restaurant.id)
                                        } else {
                                            selectedRestaurants.remove(restaurant.id)
                                        }
                                    }
                                }
                            }

                            // Open combined menu button
                            if selectedRestaurants.count >= 2 {
                                Button(action: {
                                    // Open combined MR menu
                                }) {
                                    HStack {
                                        Image(systemName: "cart.fill.badge.plus")
                                        Text(themeManager.isRTL ? "فتح القائمة الموحدة" : "Open Combined Menu")
                                    }
                                    .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(themeManager.activePalette.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(
                                        color: themeManager.activePalette.primary.opacity(0.3),
                                        radius: 12,
                                        x: 0,
                                        y: 6
                                    )
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                            }

                            Color.clear.frame(height: 40)
                        }
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle(street?.nameEn ?? "")
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

struct FoodStreetHeaderView: View {
    let street: FoodStreet
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            ZStack(alignment: .bottomLeading) {
                StreetImagePlaceholder(artType: street.featuredArt)
                    .frame(height: 180)

                LinearGradient(
                    colors: [
                        themeManager.activePalette.background.opacity(0),
                        themeManager.activePalette.background.opacity(0.8)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 80)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: themeManager.activePalette.overlayScrim,
                radius: 8,
                x: 0,
                y: 4
            )

            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(themeManager.isRTL ? street.nameAr : street.nameEn)
                    .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Text(themeManager.isRTL ? street.vibeAr : street.vibeEn)
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)

                HStack(spacing: 16) {
                    Label("\(street.activeVendors) \(themeManager.isRTL ? "مطاعم" : "Restaurants")", systemImage: "building.2.fill")
                    Label("\(street.avgEtaMinutes) \(themeManager.isRTL ? "د" : "min")", systemImage: "clock.fill")
                    Label(ArabicNumeralFormatter.formatLYD(street.baseStreetDeliveryFeeLyd, isRTL: themeManager.isRTL), systemImage: "bicycle.circle.fill")
                }
                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textTertiary)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct RestaurantSelectionRow: View {
    let restaurant: Restaurant
    let isSelected: Bool
    let maxSelection: Int
    let currentSelectionCount: Int
    let onToggle: (Bool) -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: {
            if isSelected || currentSelectionCount < maxSelection {
                onToggle(!isSelected)
            }
        }) {
            HStack(spacing: 12) {
                // Selection indicator
                Circle()
                    .stroke(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.border, lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(themeManager.activePalette.primary)
                            .frame(width: 14, height: 14)
                            .opacity(isSelected ? 1 : 0)
                    )

                // Restaurant image
                AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        RestaurantImagePlaceholder(artType: restaurant.heroArt)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        RestaurantImagePlaceholder(artType: restaurant.heroArt)
                    @unknown default:
                        RestaurantImagePlaceholder(artType: restaurant.heroArt)
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(themeManager.isRTL ? restaurant.nameAr : restaurant.nameEn)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(themeManager.activePalette.accent)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(KooiTypography.labelSmall.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.textSecondary)
                        }

                        Text("·")
                            .foregroundColor(themeManager.activePalette.textTertiary)

                        Text("\(restaurant.deliveryMinutes) \(themeManager.isRTL ? "د" : "min")")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                    }
                }

                Spacer()

                if !isSelected && currentSelectionCount >= maxSelection {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(themeManager.activePalette.textDisabled)
                }
            }
            .padding(12)
            .background(
                isSelected ? themeManager.activePalette.primarySubtle : themeManager.activePalette.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.borderSubtle, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isSelected && currentSelectionCount >= maxSelection)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Placeholder Views for Other Tabs

struct LoyaltyView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(themeManager.activePalette.accent)

                    VStack(spacing: 8) {
                        Text(themeManager.isRTL ? "ولاء كوي" : "KOOI Loyalty")
                            .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textPrimary)

                        Text(themeManager.isRTL ? "اجمع الأختام واكسب وجبات مجانية" : "Collect stamps, earn free meals")
                            .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: {}) {
                        Text(themeManager.isRTL ? "عرض بطاقات الولاء" : "View Loyalty Cards")
                            .font(KooiTypography.buttonLarge.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textOnPrimary)
                            .frame(width: 280)
                            .padding(.vertical, 16)
                            .background(themeManager.activePalette.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(themeManager.isRTL ? "الولاء" : "Loyalty")
        }
        .rtlLayout(themeManager.isRTL)
    }
}

struct WalletView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(themeManager.activePalette.primary)

                    VStack(spacing: 8) {
                        Text(themeManager.isRTL ? "محفظة كوي" : "KOOI Wallet")
                            .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textPrimary)

                        Text(themeManager.isRTL ? "رصيدك: 0 د.ل" : "Balance: 0 LYD")
                            .font(KooiTypography.displayMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.primary)
                    }

                    HStack(spacing: 16) {
                        Button(action: {}) {
                            VStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                Text(themeManager.isRTL ? "شحن" : "Top Up")
                            }
                            .foregroundColor(themeManager.activePalette.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(themeManager.activePalette.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button(action: {}) {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title)
                                Text(themeManager.isRTL ? "إرسال" : "Send")
                            }
                            .foregroundColor(themeManager.activePalette.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(themeManager.activePalette.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .frame(width: 280)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(themeManager.isRTL ? "المحفظة" : "Wallet")
        }
        .rtlLayout(themeManager.isRTL)
    }
}

struct AddressesView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(themeManager.activePalette.primary)

                    Text(themeManager.isRTL ? "عناوين التوصيل" : "Delivery Addresses")
                        .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Button(action: {}) {
                        Text(themeManager.isRTL ? "إضافة عنوان جديد" : "Add New Address")
                            .font(KooiTypography.buttonLarge.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textOnPrimary)
                            .frame(width: 280)
                            .padding(.vertical, 16)
                            .background(themeManager.activePalette.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(themeManager.isRTL ? "العناوين" : "Addresses")
        }
        .rtlLayout(themeManager.isRTL)
    }
}

struct ProfileView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100, weight: .light))
                        .foregroundColor(themeManager.activePalette.primary)

                    Text(themeManager.isRTL ? "فراس أبوزخار" : "Feras Abuzkhar")
                        .font(KooiTypography.displayMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text("+218 91-482-3910")
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(themeManager.isRTL ? "الملف الشخصي" : "Profile")
        }
        .rtlLayout(themeManager.isRTL)
    }
}

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            List {
                Section(themeManager.isRTL ? "المظهر" : "Appearance") {
                    Toggle(themeManager.isRTL ? "الوضع الداكن" : "Dark Mode", isOn: .constant(false))
                    Toggle(themeManager.isRTL ? "تقليل الحركة" : "Reduced Motion", isOn: Binding(
                        get: { themeManager.reducedMotion },
                        set: { themeManager.setReducedMotion($0) }
                    ))
                }

                Section(themeManager.isRTL ? "اللغة" : "Language") {
                    Picker(themeManager.isRTL ? "اللغة" : "Language", selection: Binding(
                        get: { Locale.current.language.languageCode?.identifier == "ar" ? "ar" : "en" },
                        set: { _ in }
                    )) {
                        Text("العربية").tag("ar")
                        Text("English").tag("en")
                    }
                }

                Section(themeManager.isRTL ? "الإشعارات" : "Notifications") {
                    Toggle(themeManager.isRTL ? "تمكين الإشعارات" : "Enable Notifications", isOn: .constant(true))
                }
            }
            .navigationTitle(themeManager.isRTL ? "الإعدادات" : "Settings")
        }
        .rtlLayout(themeManager.isRTL)
    }
}

struct NotificationsView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(themeManager.activePalette.warning)

                    Text(themeManager.isRTL ? "الإشعارات" : "Notifications")
                        .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text(themeManager.isRTL ? "لا توجد إشعارات جديدة" : "No new notifications")
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(themeManager.isRTL ? "الإشعارات" : "Notifications")
        }
        .rtlLayout(themeManager.isRTL)
    }
}

struct SupportView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "headphones.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(themeManager.activePalette.info)

                    Text(themeManager.isRTL ? "المساعدة والدعم" : "Help & Support")
                        .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Button(action: {}) {
                        Text(themeManager.isRTL ? "تواصل معنا" : "Contact Us")
                            .font(KooiTypography.buttonLarge.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textOnPrimary)
                            .frame(width: 280)
                            .padding(.vertical, 16)
                            .background(themeManager.activePalette.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(themeManager.isRTL ? "الدعم" : "Support")
        }
        .rtlLayout(themeManager.isRTL)
    }
}

struct OrderTrackingView: View {
    let orderNumber: String
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(themeManager.activePalette.primary)

                    Text("\(themeManager.isRTL ? "طلب #" : "Order #")\(orderNumber)")
                        .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text(themeManager.isRTL ? "قيد التحضير" : "Preparing")
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(themeManager.activePalette.primarySubtle)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(themeManager.isRTL ? "تتبع الطلب" : "Order Tracking")
        }
        .rtlLayout(themeManager.isRTL)
    }
}

struct GroupOrderView: View {
    let groupId: String?
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(themeManager.activePalette.accent)

                    Text(themeManager.isRTL ? "سلة جماعية" : "Group Cart")
                        .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text(groupId != nil ? "Group: \(groupId!)" : (themeManager.isRTL ? "إنشاء مجموعة جديدة" : "Create New Group"))
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(themeManager.isRTL ? "طلب جماعي" : "Group Order")
        }
        .rtlLayout(themeManager.isRTL)
    }
}

// MARK: - Preview Helpers

extension DeliveryAddress {
    static let preview = DeliveryAddress(
        id: "preview",
        titleAr: "المنزل",
        titleEn: "Home",
        districtAr: "قرقارش",
        districtEn: "Gargaresh",
        detailsAr: "شارع قرقارش الرئيسي، بناية ١٤",
        detailsEn: "Main Gargaresh St, Bldg 14",
        microZoneId: "zone_gargaresh"
    )
}