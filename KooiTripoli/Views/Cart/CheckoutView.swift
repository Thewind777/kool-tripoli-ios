import SwiftUI

/// Checkout view with address, payment, and order confirmation
struct CheckoutView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedAddressIndex: Int = 0
    @State private var selectedPaymentIndex: Int = 0
    @State private var showingPaymentSheet = false
    @State private var isPlacingOrder = false
    @State private var showingConfirmation = false

    private var addresses: [DeliveryAddress] {
        cartStore.addresses.isEmpty ? [DeliveryAddress.preview] : cartStore.addresses
    }

    private var paymentMethods: [PaymentMethod] {
        [.cashOnDelivery, .kooiWallet, .localCard]
    }

    var body: some View {
        NavigationStack {
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

                        // Scheduled offer (if available)
                        if let offer = cartVM.availablePeakCheckoutOffer {
                            ScheduledOfferSectionView(offer: offer)
                        }

                        // Loyalty reward (if applied)
                        if let reward = cartVM.appliedLoyaltyReward {
                            AppliedLoyaltyRewardView(reward: reward)
                        }

                        // Notes
                        CheckoutNotesView()

                        // Place order button
                        PlaceOrderButtonView()

                        // Bottom padding
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(themeManager.isRTL ? "إتمام الطلب" : "Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPaymentSheet) {
                PaymentDetailView(method: paymentMethods[selectedPaymentIndex])
            }
            .alert(
                themeManager.isRTL ? "تم تأكيد الطلب" : "Order Confirmed",
                isPresented: $showingConfirmation
            ) {
                Button(themeManager.isRTL ? "متابعة" : "Continue") {
                    coordinator.navigateToRoot()
                }
            } message: {
                Text(themeManager.isRTL ? "تم إرسال طلبك بنجاح!" : "Your order has been placed successfully!")
            }
        }
        .rtlLayout(themeManager.isRTL)
    }
}

/// Order summary at top of checkout
struct OrderSummaryView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(themeManager.isRTL ? "ملخص الطلب" : "Order Summary")
                    .font(KooiTypography.titleMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Spacer()

                Text("\(cartVM.totalCartCount) \(themeManager.isRTL ? "أصناف" : "items")")
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)
            }

            // Restaurant groups
            ForEach(cartVM.restaurantOrderGroups) { group in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(group.restaurantNameAr.isEmpty ? group.restaurantNameEn : group.restaurantNameAr)
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textSecondary)

                        Spacer()

                        Text(ArabicNumeralFormatter.formatLYD(group.subtotalLyd, isRTL: themeManager.isRTL))
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textPrimary)
                    }

                    if group.coordinationFeeLyd > 0 {
                        HStack {
                            Text(themeManager.isRTL ? "  رسوم تنسيق" : "  Coordination Fee")
                                .font(KooiTypography.labelSmall.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.warning)

                            Spacer()

                            Text(ArabicNumeralFormatter.formatLYD(group.coordinationFeeLyd, isRTL: themeManager.isRTL))
                                .font(KooiTypography.labelSmall.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.warning)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Divider()
                .background(themeManager.activePalette.borderSubtle)

            // Total
            HStack {
                Text(themeManager.isRTL ? "الإجمالي" : "Total")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Spacer()

                Text(ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.finalTotalLyd, isRTL: themeManager.isRTL))
                    .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
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
}

/// Delivery address selection
struct DeliveryAddressSectionView: View {
    let addresses: [DeliveryAddress]
    @Binding var selectedIndex: Int
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(themeManager.isRTL ? "عنوان التوصيل" : "Delivery Address")
                    .font(KooiTypography.titleMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Spacer()

                Button(action: { coordinator.showSettings() }) { // Would navigate to addresses
                    Text(themeManager.isRTL ? "إدارة" : "Manage")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
                }
            }

            ForEach(Array(addresses.enumerated()), id: \.element.id) { index, address in
                AddressSelectionRow(
                    address: address,
                    isSelected: selectedIndex == index
                ) {
                    selectedIndex = index
                }
            }
        }
    }
}

struct AddressSelectionRow: View {
    let address: DeliveryAddress
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Selection indicator
                Circle()
                    .stroke(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.border, lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(themeManager.activePalette.primary)
                            .frame(width: 12, height: 12)
                            .opacity(isSelected ? 1 : 0)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(address.titleAr.isEmpty ? address.titleEn : address.titleAr)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text("\(address.districtAr.isEmpty ? address.districtEn : address.districtAr) · \(address.detailsAr.isEmpty ? address.detailsEn : address.detailsAr)")
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(16)
            .background(
                isSelected ? themeManager.activePalette.primarySubtle : themeManager.activePalette.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.borderSubtle, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// Fulfillment mode selection
struct FulfillmentModeSectionView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "طريقة الاستلام" : "Fulfillment Mode")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            HStack(spacing: 12) {
                FulfillmentModeButton(
                    mode: .delivery,
                    isSelected: cartStore.fulfillmentMode == .delivery,
                    icon: "bicycle.circle.fill",
                    label: themeManager.isRTL ? "توصيل" : "Delivery",
                    subtitle: themeManager.isRTL ? "توصيل إلى بابك" : "Delivered to your door"
                ) {
                    cartVM.setFulfillmentMode(.delivery)
                }

                if cartVM.restaurantOrderGroups.allSatisfy({ group in
                    // Check if all restaurants support pickup
                    true // Would check actual restaurant data
                }) {
                    FulfillmentModeButton(
                        mode: .pickup,
                        isSelected: cartStore.fulfillmentMode == .pickup,
                        icon: "takeoutbag.and.cup.and.straw.fill",
                        label: themeManager.isRTL ? "استلام" : "Pickup",
                        subtitle: themeManager.isRTL ? "استلام من المطعم" : "Collect from restaurant"
                    ) {
                        cartVM.setFulfillmentMode(.pickup)
                    }
                }
            }
        }
    }
}

struct FulfillmentModeButton: View {
    let mode: FulfillmentMode
    let isSelected: Bool
    let icon: String
    let label: String
    let subtitle: String
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.textTertiary)

                VStack(spacing: 2) {
                    Text(label)
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.textPrimary)

                    Text(subtitle)
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                isSelected ? themeManager.activePalette.primarySubtle : themeManager.activePalette.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.borderSubtle, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// Payment method selection
struct PaymentMethodSectionView: View {
    let methods: [PaymentMethod]
    @Binding var selectedIndex: Int
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var cartStore: LocalCartStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "طريقة الدفع" : "Payment Method")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            ForEach(Array(methods.enumerated()), id: \.element) { index, method in
                PaymentMethodRow(
                    method: method,
                    isSelected: selectedIndex == index
                ) {
                    selectedIndex = index
                    cartStore.selectedPaymentMethod = method
                }
            }
        }
    }
}

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
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

                // Method icon
                Image(systemName: paymentIcon)
                    .font(.title3)
                    .foregroundColor(themeManager.activePalette.primary)
                    .frame(width: 40, height: 40)
                    .background(themeManager.activePalette.primarySubtle)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(themeManager.isRTL ? method.labelAr : method.labelEn)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text(themeManager.isRTL ? method.subtitleAr : method.subtitleEn)
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                }

                Spacer()
            }
            .padding(16)
            .background(
                isSelected ? themeManager.activePalette.primarySubtle : themeManager.activePalette.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.borderSubtle, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    private var paymentIcon: String {
        switch method {
        case .cashOnDelivery: return "banknote.fill"
        case .kooiWallet: return "wallet.pass.fill"
        case .localCard: return "creditcard.fill"
        case .askFriendToPay: return "person.2.fill"
        }
    }
}

/// Scheduled offer section
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

/// Applied loyalty reward view
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
        // Simulate order placement
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isPlacingOrder = false
            // Would show confirmation
        }
    }
}

/// Payment detail sheet
struct PaymentDetailView: View {
    let method: PaymentMethod
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: paymentIcon)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(themeManager.activePalette.primary)

                VStack(spacing: 8) {
                    Text(themeManager.isRTL ? method.labelAr : method.labelEn)
                        .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text(themeManager.isRTL ? method.subtitleAr : method.subtitleEn)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Payment details would go here

                Spacer()

                Button(action: { dismiss() }) {
                    Text(themeManager.isRTL ? "تم" : "Done")
                        .font(KooiTypography.buttonLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeManager.activePalette.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
            }
            .padding()
            .navigationTitle(themeManager.isRTL ? "تفاصيل الدفع" : "Payment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: themeManager.isRTL ? "chevron.right" : "chevron.left")
                            .font(.title2)
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }
            }
        }
        .rtlLayout(themeManager.isRTL)
    }

    private var paymentIcon: String {
        switch method {
        case .cashOnDelivery: return "banknote.fill"
        case .kooiWallet: return "wallet.pass.fill"
        case .localCard: return "creditcard.fill"
        case .askFriendToPay: return "person.2.fill"
        }
    }
}