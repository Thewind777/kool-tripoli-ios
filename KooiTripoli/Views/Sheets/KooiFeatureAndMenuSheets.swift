import SwiftUI

// MARK: - Feature Sheets & Menu Sheets

/// Feature showcase sheets (MR Order, Group Cart, Book Order, Loyalty)
struct KooiFeatureSheetsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var restaurantsVM: RestaurantsViewModel

    let featureType: KooiFeatureType

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Hero banner
                        FeatureHeroBannerView(feature: featureType)
                            .padding(.horizontal, 16)

                        // Feature description
                        FeatureDescriptionView(feature: featureType)
                            .padding(.horizontal, 16)

                        // CTA button
                        FeatureCTAButtonView(feature: featureType)
                            .padding(.horizontal, 16)

                        // Feature-specific content
                        FeatureContentView(feature: featureType)
                            .padding(.horizontal, 16)

                        Color.clear.frame(height: 40)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle(featureTitle)
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

    private var featureTitle: String {
        switch featureType {
        case .mrOrder: return themeManager.isRTL ? "طلب شارع MR" : "MR Street Order"
        case .groupCart: return themeManager.isRTL ? "سلة جماعية" : "Group Cart"
        case .bookOrder: return themeManager.isRTL ? "حجز طلب" : "Book Order"
        case .loyalty: return themeManager.isRTL ? "ولاء كوي" : "KOOI Loyalty"
        }
    }
}

/// Hero banner for feature sheets
struct FeatureHeroBannerView: View {
    let feature: KooiFeatureType
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: heroIcon)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(themeManager.activePalette.textOnPrimary)
                .frame(width: 100, height: 100)
                .background(themeManager.activePalette.primary)
                .clipShape(Circle())
                .shadow(
                    color: themeManager.activePalette.primary.opacity(0.3),
                    radius: 16,
                    x: 0,
                    y: 8
                )

            // Title
            Text(themeManager.isRTL ? feature.heroHeadlineAr : feature.heroHeadlineEn)
                .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)
                .multilineTextAlignment(.center)

            // Subtitle
            Text(themeManager.isRTL ? feature.heroDescriptionAr : feature.heroDescriptionEn)
                .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            // Badge
            Text(themeManager.isRTL ? feature.heroBadgeAr : feature.heroBadgeEn)
                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textOnPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(themeManager.activePalette.accent)
                .clipShape(Capsule())
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
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

    private var heroIcon: String {
        switch feature {
        case .mrOrder: return "map.fill"
        case .groupCart: return "person.3.fill"
        case .bookOrder: return "calendar.badge.clock"
        case .loyalty: return "seal.fill"
        }
    }
}

/// Feature description
struct FeatureDescriptionView: View {
    let feature: KooiFeatureType
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 12) {
            Text(themeManager.isRTL ? feature.titleAr : feature.titleEn)
                .font(KooiTypography.titleLarge.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            Text(themeManager.isRTL ? feature.subtitleAr : feature.subtitleEn)
                .font(KooiTypography.bodyLarge.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
    }
}

/// Feature CTA button
struct FeatureCTAButtonView: View {
    let feature: KooiFeatureType
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        Button(action: handleCTA) {
            Text(themeManager.isRTL ? feature.heroCtaAr : feature.heroCtaEn)
                .font(KooiTypography.buttonLarge.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textOnPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
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
    }

    private func handleCTA() {
        switch feature {
        case .mrOrder:
            coordinator.showAllFoodStreets()
        case .groupCart:
            coordinator.showGroupOrder()
        case .bookOrder:
            coordinator.selectTab(.restaurants) // Would show scheduled offers
        case .loyalty:
            coordinator.showLoyalty()
        }
    }
}

/// Feature-specific content
struct FeatureContentView: View {
    let feature: KooiFeatureType
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 16) {
            ForEach(featureSteps, id: \.title) { step in
                FeatureStepRow(step: step)
            }
        }
    }

    private var featureSteps: [(title: String, description: String, icon: String)] {
        switch feature {
        case .mrOrder:
            return [
                (themeManager.isRTL ? "اختر الشارع" : "Pick Street", themeManager.isRTL ? "اختر من شوارع الطعام المتاحة في طرابلس" : "Choose from available food streets in Tripoli", "map.fill"),
                (themeManager.isRTL ? "اختر المطاعم" : "Select Restaurants", themeManager.isRTL ? "حد أقصى 3 مطاعم في نفس الشارع" : "Maximum 3 restaurants on same street", "building.2.fill"),
                (themeManager.isRTL ? "سلة موحدة" : "Unified Cart", themeManager.isRTL ? "أضف أصناف من مطاعم مختلفة في سلة واحدة" : "Add items from different restaurants in one cart", "cart.fill.badge.plus"),
                (themeManager.isRTL ? "توصيلة منسقة" : "Coordinated Delivery", themeManager.isRTL ? "ميعاد واحد، مندوب واحد، فاتورة واحدة" : "One delivery time, one courier, one bill", "bicycle.circle.fill")
            ]
        case .groupCart:
            return [
                (themeManager.isRTL ? "أنشئ المجموعة" : "Create Group", themeManager.isRTL ? "اختر المطاعم وادعُ الأصدقاء" : "Choose restaurants and invite friends", "person.badge.plus"),
                (themeManager.isRTL ? "كل شخص يضيف" : "Everyone Adds", themeManager.isRTL ? "كل مشارك يبني سلته الخاصة" : "Each participant builds their own basket", "cart.badge.plus"),
                (themeManager.isRTL ? "قسّم الدفع" : "Split Payment", themeManager.isRTL ? "المنظم يدفع أو كل شخص يدفع حصته" : "Organizer pays or everyone pays their share", "creditcard.fill"),
                (themeManager.isRTL ? "طلب واحد" : "One Order", themeManager.isRTL ? "إرسال موحد لجميع المطاعم" : "Single dispatch to all restaurants", "checkmark.circle.fill")
            ]
        case .bookOrder:
            return [
                (themeManager.isRTL ? "اختر الوقت" : "Pick Time", themeManager.isRTL ? "حدد موعد التوصيل المناسب" : "Choose convenient delivery time", "clock.fill"),
                (themeManager.isRTL ? "احصل على خصم" : "Get Discount", themeManager.isRTL ? "خصم خارج الذروة يصل إلى 20٪" : "Off-peak discount up to 20%", "percent"),
                (themeManager.isRTL ? "تأكيد الطلب" : "Confirm Order", themeManager.isRTL ? "المطاعم تجهز الطلب للموعد المحدد" : "Restaurants prepare for scheduled time", "calendar.badge.checkmark"),
                (themeManager.isRTL ? "تتبع التسليم" : "Track Delivery", themeManager.isRTL ? "اعرف متى سيصل طلبك بدقة" : "Know exactly when your order arrives", "location.circle.fill")
            ]
        case .loyalty:
            return [
                (themeManager.isRTL ? "عضوية كوي" : "KOOI Circle", themeManager.isRTL ? "اكسب نقاط على كل طلب" : "Earn points on every order", "seal.fill"),
                (themeManager.isRTL ? "بطاقات المطاعم" : "Restaurant Cards", themeManager.isRTL ? "اجمع أختام لكل مطعم على حدة" : "Collect stamps per restaurant separately", "square.grid.2x2.fill"),
                (themeManager.isRTL ? "استبدل المكافآت" : "Redeem Rewards", themeManager.isRTL ? "أطباق مجانية وخصومات حصرية" : "Free dishes and exclusive discounts", "gift.fill"),
                (themeManager.isRTL ? "لا تنتهي أبداً" : "Never Expires", themeManager.isRTL ? "نقاط العضوية لا تنتهي" : "Membership points never expire", "infinity")
            ]
        }
    }
}

struct FeatureStepRow: View {
    let step: (title: String, description: String, icon: String)
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: step.icon)
                .font(.system(size: 24, weight: .light))
                .foregroundColor(themeManager.activePalette.primary)
                .frame(width: 48, height: 48)
                .background(themeManager.activePalette.primarySubtle)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(KooiTypography.titleMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Text(step.description)
                    .font(KooiTypography.bodySmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(
            color: themeManager.activePalette.overlayScrim,
            radius: 4,
            x: 0,
            y: 2
        )
    }
}

/// Menu sheets (item detail, addons, quantity)
struct MenuSheetsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var itemDetailVM: ItemDetailViewModel
    @EnvironmentObject private var cartVM: CartViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                if let item = itemDetailVM.menuItem {
                    ItemDetailSheetView(item: item)
                }
            }
            .navigationTitle(themeManager.isRTL ? "تفاصيل الصنف" : "Item Details")
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

/// Item detail sheet (modal)
struct ItemDetailSheetView: View {
    let item: MenuItem
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var itemDetailVM: ItemDetailViewModel
    @EnvironmentObject private var cartVM: CartViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Item image
                    ItemImageView()
                        .frame(height: 280)

                    // Content
                    VStack(spacing: 20) {
                        ItemHeaderView()
                            .padding(.horizontal, 16)

                        if let description = themeManager.isRTL ? item.descriptionAr : item.descriptionEn,
                           !description.isEmpty {
                            ItemDescriptionView(description: description)
                                .padding(.horizontal, 16)
                        }

                        if itemDetailVM.isLoadingOptions {
                            ModifierSkeletonSection()
                                .padding(.horizontal, 16)
                        } else if let options = itemDetailVM.itemOptions, !options.categories.isEmpty {
                            ModifiersSectionView(options: options)
                                .padding(.horizontal, 16)
                        } else if !item.modifiers.isEmpty {
                            SimpleModifiersView(modifiers: item.modifiers)
                                .padding(.horizontal, 16)
                        }

                        QuantityStepperView()
                            .padding(.horizontal, 16)

                        NoteInputView()
                            .padding(.horizontal, 16)

                        PriceSummaryView()
                            .padding(.horizontal, 16)

                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, 16)
                }
            }

            // Add to Cart CTA
            AddToCartCTAView()
                .padding(.horizontal, 16)
                .padding(.bottom, 34)
        }
        .onAppear {
            itemDetailVM.setMenuItem(item)
        }
    }
}

/// Modifier skeleton
struct ModifierSkeletonSection: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView()
                .frame(width: 160, height: 22)

            ForEach(0..<3) { _ in
                SkeletonView()
                    .frame(height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

/// Checkout sheets
struct CheckoutSheetsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var cartVM: CartViewModel

    var body: some View {
        NavigationStack {
            CheckoutSheetView()
                .navigationTitle(themeManager.isRTL ? "إتمام الطلب" : "Checkout")
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

/// Checkout sheet (modal)
struct CheckoutSheetView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var cartStore: LocalCartStore
    @State private var selectedAddressIndex: Int = 0
    @State private var selectedPaymentIndex: Int = 0
    @State private var showingPaymentSheet = false

    private var addresses: [DeliveryAddress] {
        cartStore.addresses.isEmpty ? [DeliveryAddress.preview] : cartStore.addresses
    }

    private var paymentMethods: [PaymentMethod] {
        [.cashOnDelivery, .kooiWallet, .localCard]
    }

    var body: some View {
        ZStack {
            themeManager.activePalette.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Order summary
                    OrderSummaryView()

                    // Delivery address
                    DeliveryAddressSectionView(
                        addresses: addresses,
                        selectedIndex: $selectedAddressIndex
                    )

                    // Fulfillment mode
                    FulfillmentModeSectionView()

                    // Payment method
                    PaymentMethodSectionView(
                        methods: paymentMethods,
                        selectedIndex: $selectedPaymentIndex
                    )

                    // Scheduled offer
                    if let offer = cartVM.availablePeakCheckoutOffer {
                        ScheduledOfferSectionView(offer: offer)
                    }

                    // Loyalty reward
                    if let reward = cartVM.appliedLoyaltyReward {
                        AppliedLoyaltyRewardView(reward: reward)
                    }

                    // Notes
                    CheckoutNotesView()

                    // Place order button
                    PlaceOrderButtonView()

                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
    }
}

/// Scheduled offer section in checkout
struct ScheduledOfferSectionView: View {
    let offer: ScheduledOffer
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isAccepted: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.activePalette.success)

                VStack(alignment: .leading, spacing: 2) {
                    Text(themeManager.isRTL ? "عرض خارج الذروة متاح!" : "Off-Peak Offer Available!")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.success)

                    Text("\(offer.discountPercent)% \(themeManager.isRTL ? "خصم حتى" : "off up to") \(ArabicNumeralFormatter.formatLYD(offer.maxDiscountCapLyd, isRTL: themeManager.isRTL))")
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                }

                Spacer()
            }

            HStack {
                Text(themeManager.isRTL ? "الموعد: \(offer.slot.windowLabelAr)" : "Slot: \(offer.slot.windowLabelEn)")
                    .font(KooiTypography.bodySmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)

                Spacer()

                if isAccepted {
                    Text(themeManager.isRTL ? "مقبول ✓" : "Accepted ✓")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.success)
                } else {
                    Button(action: { isAccepted = true }) {
                        Text(themeManager.isRTL ? "قبول" : "Accept")
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textOnPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(themeManager.activePalette.success)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(themeManager.activePalette.successSubtle)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAccepted)
    }
}

/// Applied loyalty reward view in checkout
struct AppliedLoyaltyRewardView: View {
    let reward: LoyaltyReward
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "seal.fill")
                .font(.title2)
                .foregroundColor(themeManager.activePalette.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(themeManager.isRTL ? "مكافأة ولاء مطبقة" : "Loyalty Reward Applied")
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.accent)

                Text(themeManager.isRTL ? reward.titleAr : reward.titleEn)
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
            }

            Spacer()

            Text("-\(ArabicNumeralFormatter.formatLYD(reward.discountValueLyd, isRTL: themeManager.isRTL))")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.success)

            Button(action: { cartVM.removeLoyaltyReward() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.activePalette.textDisabled)
            }
        }
        .padding(16)
        .background(themeManager.activePalette.warningSubtle)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

/// Checkout notes
struct CheckoutNotesView: View {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var notes: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(themeManager.isRTL ? "ملاحظات للطلب" : "Order Notes")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            TextField(
                themeManager.isRTL ? "أي ملاحظات إضافية..." : "Any additional notes...",
                text: $notes,
                axis: .vertical
            )
            .font(KooiTypography.bodyMedium.font(locale: Locale.current))
            .padding(16)
            .background(themeManager.activePalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.activePalette.borderSubtle, lineWidth: 1)
            )
            .lineLimit(3...5)
        }
    }
}

/// Place order button
struct PlaceOrderButtonView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isPlacingOrder = false

    var body: some View {
        Button(action: placeOrder) {
            HStack(spacing: 12) {
                if isPlacingOrder {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.activePalette.textOnPrimary))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                }

                Text(isPlacingOrder
                     ? (themeManager.isRTL ? "جاري الإرسال..." : "Placing order...")
                     : (themeManager.isRTL ? "تأكيد الطلب" : "Place Order"))
                    .font(KooiTypography.buttonLarge.font(locale: Locale.current))
            }
            .foregroundColor(themeManager.activePalette.textOnPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(themeManager.activePalette.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: themeManager.activePalette.primary.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
        .disabled(isPlacingOrder || cartVM.cartStore.cartItems.isEmpty)
    }

    private func placeOrder() {
        isPlacingOrder = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isPlacingOrder = false
        }
    }
}