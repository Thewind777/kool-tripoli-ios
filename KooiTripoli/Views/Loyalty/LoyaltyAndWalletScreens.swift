import SwiftUI

// MARK: - Loyalty & Wallet Screens

/// Loyalty wallet main screen with KOOI Circle and restaurant stamp cards
struct LoyaltyView: View {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = LoyaltyViewModel()
    @State private var selectedFilter: LoyaltyFilter = .all
    @State private var selectedCategoryId: String = "cat_all"

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        // KOOI Circle Membership (top)
                        if let membershipCard = viewModel.kooiMembershipCard {
                            KOOICircleMembershipCard(card: membershipCard)
                                .padding(.horizontal, 16)
                        }

                        // Filter tabs
                        FilterTabsView(
                            filters: LoyaltyFilter.allCases,
                            selectedFilter: $selectedFilter
                        )
                        .padding(.horizontal, 16)

                        // Category chips
                        CategoryChipsView(
                            categories: viewModel.loyaltyCategories,
                            selectedCategoryId: $selectedCategoryId
                        )
                        .padding(.horizontal, 16)

                        // Loyalty cards grid
                        LoyaltyCardsGridView(
                            cards: viewModel.filteredCards(filter: selectedFilter, categoryId: selectedCategoryId),
                            membershipCard: viewModel.kooiMembershipCard
                        )
                        .padding(.horizontal, 16)

                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle(themeManager.isRTL ? "ولاء كوي" : "KOOI Loyalty")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showTransactions() }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }
            }
        }
        .rtlLayout(themeManager.isRTL)
    }
}

/// KOOI Circle membership card (spend-based points)
struct KOOICircleMembershipCard: View {
    let card: LoyaltyCard
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    private var progress: Double {
        guard card.program.targetUnits > 0 else { return 0 }
        return min(Double(card.currentUnits) / Double(card.program.targetUnits), 1.0)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(themeManager.isRTL ? "دائرة كوي" : "KOOI Circle")
                        .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary)

                    Text(themeManager.isRTL ? "عضوية تعتمد على الإنفاق" : "Spend-based Membership")
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary.opacity(0.9))
                }

                Spacer()

                // Points balance
                VStack(alignment: .trailing, spacing: 2) {
                    Text(ArabicNumeralFormatter.formatInt(card.currentUnits, useArabicNumerals: themeManager.isRTL))
                        .font(KooiTypography.displayMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary)

                    Text(themeManager.isRTL ? "نقطة" : "Points")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary.opacity(0.8))
                }
            }

            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text(themeManager.isRTL ? "نحو المكافأة التالية" : "Towards Next Reward")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary.opacity(0.9))

                    Spacer()

                    Text("\(card.currentUnits)/\(card.program.targetUnits)")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary)
                }

                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: themeManager.activePalette.textOnPrimary))
                    .scaleEffect(y: 2.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }

            // Reward preview
            if card.isReadyToRedeem {
                Button(action: { /* redeem */ }) {
                    HStack {
                        Image(systemName: "seal.fill")
                            .foregroundColor(themeManager.activePalette.primary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(themeManager.isRTL ? "مكافأة جاهزة للاستبدال!" : "Reward Ready to Redeem!")
                                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.primary)

                            Text(card.program.rewardTitleEn)
                                .font(KooiTypography.bodySmall.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.textOnPrimary.opacity(0.9))
                        }

                        Spacer()

                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                    .padding(12)
                    .background(themeManager.activePalette.primarySubtle)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if card.isAlmostComplete {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(themeManager.activePalette.warning)

                        Text(themeManager.isRTL ? "متبقي \(card.remainingUnits) \(themeManager.isRTL ? "نقطة" : "points") للمكافأة" : "\(card.remainingUnits) points to next reward")
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.warning)

                        Spacer()
                    }
                    .padding(12)
                    .background(themeManager.activePalette.warningSubtle)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if card.isExpiringSoon {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(themeManager.activePalette.error)

                        Text(themeManager.isRTL ? "تنتهي خلال \(card.program.expiryDaysRemaining ?? 0) أيام" : "Expires in \(card.program.expiryDaysRemaining ?? 0) days")
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.error)

                        Spacer()
                    }
                    .padding(12)
                    .background(themeManager.activePalette.errorSubtle)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [
                        themeManager.activePalette.primary,
                        themeManager.activePalette.primary.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(
                color: themeManager.activePalette.primary.opacity(0.3),
                radius: 16,
                x: 0,
                y: 8
            )
        }
    }
}

/// Filter tabs for loyalty cards
struct FilterTabsView: View {
    let filters: [LoyaltyFilter]
    @Binding var selectedFilter: LoyaltyFilter
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters) { filter in
                    FilterTabButton(
                        title: themeManager.isRTL ? filter.labelAr : filter.labelEn,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct FilterTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                .foregroundColor(isSelected ? themeManager.activePalette.textOnPrimary : themeManager.activePalette.textPrimary)
                .padding(.horizontal, 16)
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

/// Category chips for loyalty
struct CategoryChipsView: View {
    let categories: [LoyaltyCategory]
    @Binding var selectedCategoryId: String
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    CategoryChipButton(
                        title: themeManager.isRTL ? category.labelAr : category.labelEn,
                        icon: categoryIcon(for: category.placeholderArt),
                        isSelected: selectedCategoryId == category.id
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategoryId = category.id
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func categoryIcon(for artType: DishArtType) -> String {
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

struct CategoryChipButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
            }
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

/// Loyalty cards grid
struct LoyaltyCardsGridView: View {
    let cards: [LoyaltyCard]
    let membershipCard: LoyaltyCard?
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        if cards.isEmpty {
            EmptyLoyaltyView()
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(cards) { card in
                    LoyaltyCardView(card: card)
                }
            }
        }
    }
}

struct EmptyLoyaltyView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "seal")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(themeManager.activePalette.textTertiary)

            Text(themeManager.isRTL ? "لا توجد بطاقات ولاء" : "No Loyalty Cards")
                .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textSecondary)

            Text(themeManager.isRTL ? "ابدأ بالطلب من المطاعم لجمع الأختام" : "Start ordering from restaurants to collect stamps")
                .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

/// Individual loyalty card view
struct LoyaltyCardView: View {
    let card: LoyaltyCard
    @EnvironmentObject private var themeManager: ThemeManager

    private var progress: Double {
        guard card.program.targetUnits > 0 else { return 0 }
        return min(Double(card.currentUnits) / Double(card.program.targetUnits), 1.0)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header with category icon
            HStack {
                Image(systemName: categoryIcon(for: card.program.category?.placeholderArt ?? .burgerCombo))
                    .font(.title2)
                    .foregroundColor(themeManager.activePalette.primary)

                Spacer()

                // Status badge
                if card.isReadyToRedeem {
                    Text(themeManager.isRTL ? "جاهز" : "Ready")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.success)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(themeManager.activePalette.successSubtle)
                        .clipShape(Capsule())
                } else if card.isAlmostComplete {
                    Text(themeManager.isRTL ? "قريب" : "Almost")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.warning)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(themeManager.activePalette.warningSubtle)
                        .clipShape(Capsule())
                } else if card.isExpiringSoon {
                    Text(themeManager.isRTL ? "تنتهي" : "Expiring")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.error)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(themeManager.activePalette.errorSubtle)
                        .clipShape(Capsule())
                }
            }

            // Restaurant name
            HStack {
                Text(card.program.titleEn)
                    .font(KooiTypography.titleMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .lineLimit(1)

                Spacer()
            }

            // Progress
            VStack(spacing: 6) {
                HStack {
                    Text("\(card.currentUnits)/\(card.program.targetUnits)")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Spacer()

                    if let expiry = card.program.expiryDaysRemaining, expiry <= 7 {
                        Text(themeManager.isRTL ? "\(expiry) يوم" : "\(expiry) days left")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(expiry <= 3 ? themeManager.activePalette.error : themeManager.activePalette.warning)
                    }
                }

                ProgressView(value: min(Double(card.currentUnits) / Double(card.program.targetUnits), 1.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .scaleEffect(y: 2)
            }

            // Reward preview
            VStack(alignment: .leading, spacing: 4) {
                Text(themeManager.isRTL ? "المكافأة:" : "Reward:")
                    .font(KooiTypography.labelSmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)

                Text(card.program.rewardTitleEn)
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
                    .lineLimit(1)

                if card.isReadyToRedeem {
                    Button(action: { /* redeem */ }) {
                        Text(themeManager.isRTL ? "استبدل الآن" : "Redeem Now")
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(themeManager.activePalette.success)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
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

    private var progressColor: Color {
        if card.isReadyToRedeem { return themeManager.activePalette.success }
        if card.isAlmostComplete { return themeManager.activePalette.warning }
        if card.isExpiringSoon { return themeManager.activePalette.error }
        return themeManager.activePalette.primary
    }

    private func categoryIcon(for artType: DishArtType) -> String {
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

/// Wallet main view
struct WalletView: View {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = WalletViewModel()
    @State private var selectedTab: WalletTab = .overview

    enum WalletTab: String, CaseIterable {
        case overview = "overview"
        case send = "send"
        case request = "request"

        var label: String {
            switch self {
            case .overview: return "Overview"
            case .send: return "Send"
            case .request: return "Request"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Balance card
                    WalletBalanceCard()
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    // Tab selector
                    WalletTabSelector(selectedTab: $selectedTab)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                    // Tab content
                    ScrollView {
                        switch selectedTab {
                        case .overview:
                            WalletOverviewTab()
                        case .send:
                            WalletSendTab()
                        case .request:
                            WalletRequestTab()
                        }
                    }
                }
            }
            .navigationTitle(themeManager.isRTL ? "محفظة كوي" : "KOOI Wallet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.showTopUp() }) {
                            Label(themeManager.isRTL ? "شحن المحفظة" : "Top Up", systemImage: "plus.circle")
                        }
                        Button(action: { viewModel.showContacts() }) {
                            Label(themeManager.isRTL ? "جهات الاتصال" : "Contacts", systemImage: "person.2")
                        }
                        Button(action: { viewModel.showSettings() }) {
                            Label(themeManager.isRTL ? "الإعدادات" : "Settings", systemImage: "gear")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }
            }
        }
        .rtlLayout(themeManager.isRTL)
    }
}

struct WalletBalanceCard: View {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 16) {
            Text(themeManager.isRTL ? "رصيد المحفظة" : "Wallet Balance")
                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textOnPrimary.opacity(0.8))

            Text(ArabicNumeralFormatter.formatLYD(cartStore.walletBalanceLyd, isRTL: themeManager.isRTL))
                .font(KooiTypography.displayLarge.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textOnPrimary)

            HStack(spacing: 16) {
                Button(action: { /* top up */ }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(themeManager.isRTL ? "شحن" : "Top Up")
                    }
                    .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(themeManager.activePalette.primarySubtle)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: { /* send */ }) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text(themeManager.isRTL ? "إرسال" : "Send")
                    }
                    .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(themeManager.activePalette.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Circle points
            HStack {
                Image(systemName: "seal.fill")
                    .foregroundColor(themeManager.activePalette.accent)

                Text(themeManager.isRTL ? "نقاط دائرة كوي: \(cartStore.circlePoints)" : "KOOI Circle Points: \(cartStore.circlePoints)")
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary.opacity(0.9))

                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    themeManager.activePalette.primary,
                    themeManager.activePalette.primary.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            color: themeManager.activePalette.primary.opacity(0.3),
            radius: 16,
            x: 0,
            y: 8
        )
    }
}

struct WalletTabSelector: View {
    @Binding var selectedTab: WalletView.WalletTab
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 0) {
            ForEach(WalletView.WalletTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    Text(themeManager.isRTL ? tab.label : tab.label)
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(selectedTab == tab ? themeManager.activePalette.textOnPrimary : themeManager.activePalette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedTab == tab ? themeManager.activePalette.primary : Color.clear
                        )
                }
            }
        }
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct WalletOverviewTab: View {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 20) {
            // Recent transactions
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(themeManager.isRTL ? "آخر المعاملات" : "Recent Transactions")
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Spacer()

                    Button(action: { /* view all */ }) {
                        Text(themeManager.isRTL ? "عرض الكل" : "View All")
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }
                .padding(.horizontal, 16)

                if cartStore.getCachedWalletTransactions().isEmpty {
                    EmptyStateView(
                        icon: "creditcard",
                        title: themeManager.isRTL ? "لا توجد معاملات" : "No Transactions",
                        subtitle: themeManager.isRTL ? "ستظهر معاملاتك هنا" : "Your transactions will appear here"
                    )
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(cartStore.getCachedWalletTransactions().prefix(5)) { tx in
                            WalletTransactionRow(transaction: tx)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Pending requests
                if !cartStore.getCachedWalletRequests().filter({ $0.status == .pending }).isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(themeManager.isRTL ? "طلبات مالية قيد الانتظار" : "Pending Money Requests")
                            .font(KooiTypography.titleMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textPrimary)
                            .padding(.horizontal, 16)

                        ForEach(cartStore.getCachedWalletRequests().filter { $0.status == .pending }.prefix(3)) { request in
                            PendingRequestRow(request: request)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
}

struct WalletTransactionRow: View {
    let transaction: WalletTransaction
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(transaction.isCredit ? themeManager.activePalette.successSubtle : transaction.amountLyd > 50 ? themeManager.activePalette.errorSubtle : themeManager.activePalette.warningSubtle)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: transaction.isCredit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(transaction.isCredit ? themeManager.activePalette.success : themeManager.activePalette.error)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(themeManager.isRTL ? transaction.titleAr : transaction.titleEn)
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .lineLimit(1)

                Text(transaction.timeEn)
                    .font(KooiTypography.labelSmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.isCredit ? "+" : "-")\(ArabicNumeralFormatter.formatLYD(transaction.amountLyd, isRTL: themeManager.isRTL))")
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(transaction.isCredit ? themeManager.activePalette.success : themeManager.activePalette.textPrimary)

                Text(transaction.referenceCode)
                    .font(KooiTypography.labelSmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)
            }
        }
        .padding(12)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PendingRequestRow: View {
    let request: MoneyRequest
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(themeManager.activePalette.warningSubtle)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: request.isIncomingToCurrentUser ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(themeManager.activePalette.warning)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(themeManager.isRTL ? request.titleAr : request.titleEn)
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Text(request.note)
                    .font(KooiTypography.bodySmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(ArabicNumeralFormatter.formatLYD(request.amountLyd, isRTL: themeManager.isRTL))
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)

                if request.isIncomingToCurrentUser {
                    Button(action: { /* pay */ }) {
                        Text(themeManager.isRTL ? "سداد" : "Pay")
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textOnPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(themeManager.activePalette.primary)
                            .clipShape(Capsule())
                    }
                } else {
                    Text(themeManager.isRTL ? "قيد الانتظار" : "Pending")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.warning)
                }
            }
        }
        .padding(12)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct WalletSendTab: View {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedContact: WalletContact?
    @State private var amount: String = ""
    @State private var note: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(themeManager.isRTL ? "إرسال أموال" : "Send Money")
                .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)
                .padding(.top, 24)

            // Contact selection
            VStack(alignment: .leading, spacing: 12) {
                Text(themeManager.isRTL ? "اختر جهة الاتصال" : "Select Contact")
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)
                    .padding(.horizontal, 16)

                if cartStore.getCachedWalletContacts().isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: themeManager.isRTL ? "لا توجد جهات اتصال" : "No Contacts",
                        subtitle: themeManager.isRTL ? "أضف جهات اتصال للإرسال إليهم" : "Add contacts to send money"
                    )
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(cartStore.getCachedWalletContacts()) { contact in
                                ContactSelectionCard(
                                    contact: contact,
                                    isSelected: selectedContact?.id == contact.id
                                ) {
                                    selectedContact = contact
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // Amount
                VStack(alignment: .leading, spacing: 8) {
                    Text(themeManager.isRTL ? "المبلغ (د.ل)" : "Amount (LYD)")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                        .padding(.horizontal, 16)

                    TextField(themeManager.isRTL ? "أدخل المبلغ" : "Enter amount", text: $amount)
                        .font(KooiTypography.displayMedium.font(locale: Locale.current))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .padding(16)
                        .background(themeManager.activePalette.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.activePalette.borderSubtle, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                }

                // Note
                VStack(alignment: .leading, spacing: 8) {
                    Text(themeManager.isRTL ? "ملاحظة (اختياري)" : "Note (optional)")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                        .padding(.horizontal, 16)

                    TextField(themeManager.isRTL ? "أضف ملاحظة..." : "Add a note...", text: $note, axis: .vertical)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .padding(16)
                        .background(themeManager.activePalette.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.activePalette.borderSubtle, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .lineLimit(3...5)
                }

                // Send button
                Button(action: { /* send */ }) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text(themeManager.isRTL ? "إرسال" : "Send")
                    }
                    .font(KooiTypography.buttonLarge.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(selectedContact != nil && !amount.isEmpty ? themeManager.activePalette.primary : themeManager.activePalette.textDisabled)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(selectedContact == nil || amount.isEmpty)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}

struct ContactSelectionCard: View {
    let contact: WalletContact
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.surfaceSubtle)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(String(contact.nameEn.prefix(1)).uppercased())
                            .font(KooiTypography.titleMedium.font(locale: Locale.current))
                            .foregroundColor(isSelected ? themeManager.activePalette.textOnPrimary : themeManager.activePalette.primary)
                    )
                    .overlay(
                        Circle()
                            .stroke(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.borderSubtle, lineWidth: isSelected ? 3 : 1)
                    )

                VStack(spacing: 2) {
                    Text(contact.nameEn)
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)
                        .lineLimit(1)

                    Text("@\(contact.handle)")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                        .lineLimit(1)
                }
            }
            .frame(width: 90)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct WalletRequestTab: View {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedContact: WalletContact?
    @State private var amount: String = ""
    @State private var note: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(themeManager.isRTL ? "طلب أموال" : "Request Money")
                .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)
                .padding(.top, 24)

            // Incoming requests
            if !cartStore.getCachedWalletRequests().filter({ $0.isIncomingToCurrentUser && $0.status == .pending }).isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(themeManager.isRTL ? "طلبات واردة" : "Incoming Requests")
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)
                        .padding(.horizontal, 16)

                    ForEach(cartStore.getCachedWalletRequests().filter { $0.isIncomingToCurrentUser && $0.status == .pending }) { request in
                        IncomingRequestRow(request: request)
                    }
                }
            }

            Divider()
                .background(themeManager.activePalette.borderSubtle)
                .padding(.horizontal, 16)

            // Create new request
            VStack(alignment: .leading, spacing: 12) {
                Text(themeManager.isRTL ? "إنشاء طلب جديد" : "Create New Request")
                    .font(KooiTypography.titleMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text(themeManager.isRTL ? "من" : "From")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                        .padding(.horizontal, 16)

                    if cartStore.getCachedWalletContacts().isEmpty {
                        Text(themeManager.isRTL ? "أضف جهات اتصال أولاً" : "Add contacts first")
                            .font(KooiTypography.bodySmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                            .padding(.horizontal, 16)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(cartStore.getCachedWalletContacts()) { contact in
                                    ContactSelectionCard(
                                        contact: contact,
                                        isSelected: selectedContact?.id == contact.id
                                    ) {
                                        selectedContact = contact
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(themeManager.isRTL ? "المبلغ (د.ل)" : "Amount (LYD)")
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textSecondary)
                            .padding(.horizontal, 16)

                        TextField(themeManager.isRTL ? "أدخل المبلغ" : "Enter amount", text: $amount)
                            .font(KooiTypography.displayMedium.font(locale: Locale.current))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .padding(16)
                            .background(themeManager.activePalette.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.activePalette.borderSubtle, lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(themeManager.isRTL ? "ملاحظة (اختياري)" : "Note (optional)")
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textSecondary)
                            .padding(.horizontal, 16)

                        TextField(themeManager.isRTL ? "أضف ملاحظة..." : "Add a note...", text: $note, axis: .vertical)
                            .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                            .padding(16)
                            .background(themeManager.activePalette.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.activePalette.borderSubtle, lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                            .lineLimit(3...5)
                    }

                    Button(action: { /* create request */ }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text(themeManager.isRTL ? "إنشاء الطلب" : "Create Request")
                        }
                        .font(KooiTypography.buttonLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(selectedContact != nil && !amount.isEmpty ? themeManager.activePalette.accent : themeManager.activePalette.textDisabled)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(selectedContact == nil || amount.isEmpty)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
            }

            Spacer()
        }
        .padding(.top, 24)
    }
}

struct IncomingRequestRow: View {
    let request: MoneyRequest
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(themeManager.activePalette.warningSubtle)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title)
                        .foregroundColor(themeManager.activePalette.warning)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(request.requesterNameEn)
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Text(request.note)
                    .font(KooiTypography.bodySmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(ArabicNumeralFormatter.formatLYD(request.amountLyd, isRTL: themeManager.isRTL))
                    .font(KooiTypography.titleMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)

                Button(action: { /* pay */ }) {
                    Text(themeManager.isRTL ? "سداد" : "Pay")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(themeManager.activePalette.primary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
    }
}

// ViewModels
@MainActor
public final class LoyaltyViewModel: ObservableObject {
    @Published public var loyaltyCards: [LoyaltyCard] = []
    @Published public var loyaltyCategories: [LoyaltyCategory] = []
    @Published public var kooiMembershipCard: LoyaltyCard?

    private let cartStore = LocalCartStore.shared

    public init() {
        loadData()
    }

    public func loadData() {
        loyaltyCards = cartStore.getCachedLoyaltyCards()
        loyaltyCategories = cartStore.loyaltyCategories
        kooiMembershipCard = loyaltyCards.first { $0.program.isKooiWideMembership }
    }

    public func filteredCards(filter: LoyaltyFilter, categoryId: String) -> [LoyaltyCard] {
        return LoyaltyDomainService.filterCards(
            cards: loyaltyCards.filter { !$0.program.isKooiWideMembership },
            filter: filter,
            selectedCategoryId: categoryId
        )
    }

    public func showTransactions() { /* navigate to transactions */ }
}

@MainActor
public final class WalletViewModel: ObservableObject {
    public func showTopUp() { /* present top up sheet */ }
    public func showContacts() { /* navigate to contacts */ }
    public func showSettings() { /* navigate to settings */ }
}