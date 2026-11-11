import SwiftUI

/// Cart view with restaurant groups, item management, and checkout
struct CartView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showingClearConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                if cartStore.cartItems.isEmpty {
                    EmptyCartView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Restaurant groups
                            ForEach(cartVM.restaurantOrderGroups) { group in
                                RestaurantCartGroupView(group: group)
                            }

                            // Price breakdown summary
                            CartPriceBreakdownView()

                            // Bottom padding for checkout
                            Color.clear.frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle(themeManager.isRTL ? "السلة" : "Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !cartStore.cartItems.isEmpty {
                        Button(action: { showingClearConfirmation = true }) {
                            Text(themeManager.isRTL ? "مسح السلة" : "Clear Cart")
                                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.error)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if !cartStore.cartItems.isEmpty {
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .foregroundColor(themeManager.activePalette.primary)
                        }
                    }
                }
            }
            .alert(
                themeManager.isRTL ? "مسح السلة" : "Clear Cart",
                isPresented: $showingClearConfirmation
            ) {
                Button(themeManager.isRTL ? "إلغاء" : "Cancel", role: .cancel) {}
                Button(themeManager.isRTL ? "مسح" : "Clear", role: .destructive) {
                    cartVM.clearCart()
                }
            } message: {
                Text(themeManager.isRTL ? "هل تريد مسح جميع الأصناف من السلة؟" : "Are you sure you want to clear all items from your cart?")
            }
        }
        .rtlLayout(themeManager.isRTL)
    }
}

/// Empty cart state
struct EmptyCartView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "cart")
                .font(.system(size: 80, weight: .light))
                .foregroundColor(themeManager.activePalette.textTertiary)

            VStack(spacing: 8) {
                Text(themeManager.isRTL ? "سلتك فارغة" : "Your cart is empty")
                    .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Text(themeManager.isRTL ? "أضف بعض الوجبات اللذيذة لتبدأ طلبك" : "Add some delicious meals to start your order")
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(action: { coordinator.selectTab(.restaurants) }) {
                Text(themeManager.isRTL ? "استكشف المطاعم" : "Explore Restaurants")
                    .font(KooiTypography.buttonLarge.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .frame(width: 280)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Restaurant cart group with items
struct RestaurantCartGroupView: View {
    let group: RestaurantOrderGroup
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 0) {
            // Restaurant header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.restaurantNameAr.isEmpty ? group.restaurantNameEn : group.restaurantNameAr)
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    HStack(spacing: 8) {
                        if group.coordinationFeeLyd > 0 {
                            Text(themeManager.isRTL ? "رسوم تنسيق: \(ArabicNumeralFormatter.formatLYD(group.coordinationFeeLyd, isRTL: themeManager.isRTL))" : "Coordination: \(ArabicNumeralFormatter.formatLYD(group.coordinationFeeLyd, isRTL: themeManager.isRTL))")
                                .font(KooiTypography.labelSmall.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.warning)
                        }

                        Text("\(group.items.count) \(themeManager.isRTL ? "أصناف" : "items") · \(ArabicNumeralFormatter.formatLYD(group.subtotalLyd, isRTL: themeManager.isRTL))")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                    }
                }

                Spacer()

                if !group.isAvailable {
                    Text(themeManager.isRTL ? "غير متاح" : "Unavailable")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.error)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(themeManager.activePalette.error.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(themeManager.activePalette.surface)

            // Items
            ForEach(group.items) { item in
                CartItemRowView(item: item)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: themeManager.activePalette.overlayScrim,
            radius: 6,
            x: 0,
            y: 3
        )
    }
}

/// Cart item row with quantity controls
struct CartItemRowView: View {
    let item: CartItem
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            // Item image
            AsyncImage(url: URL(string: item.menuItem.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    ItemImagePlaceholder(artType: item.menuItem.artType)
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                case .failure:
                    ItemImagePlaceholder(artType: item.menuItem.artType)
                        .frame(width: 60, height: 60)
                @unknown default:
                    ItemImagePlaceholder(artType: item.menuItem.artType)
                        .frame(width: 60, height: 60)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Item info
            VStack(alignment: .leading, spacing: 4) {
                Text(themeManager.isRTL ? item.menuItem.nameAr : item.menuItem.nameEn)
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .lineLimit(1)

                if !item.note.isEmpty {
                    Text(item.note)
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                        .lineLimit(1)
                }

                // Modifiers summary
                if item.modifierExtraLyd > 0 {
                    Text("+\(ArabicNumeralFormatter.formatLYD(item.modifierExtraLyd, isRTL: themeManager.isRTL)) \(themeManager.isRTL ? "إضافات" : "extras")")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
                }

                // Price
                Text(ArabicNumeralFormatter.formatLYD(item.quotedUnitPriceLyd + item.modifierExtraLyd, isRTL: themeManager.isRTL))
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
            }

            Spacer()

            // Quantity stepper
            QuantityStepperInlineView(item: item)
        }
        .padding(12)
        .background(themeManager.activePalette.background)
        .overlay(
            Rectangle()
                .fill(themeManager.activePalette.borderSubtle)
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

struct QuantityStepperInlineView: View {
    let item: CartItem
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 0) {
            Button(action: { cartVM.decrementQuantity(for: item.id) }) {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.activePalette.primary)
                    .frame(width: 36, height: 36)
                    .background(themeManager.activePalette.primarySubtle)
            }
            .buttonStyle(.plain)
            .disabled(item.quantity <= 1)

            Text("\(item.quantity)")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)
                .frame(minWidth: 40)
                .contentTransition(.numericText())

            Button(action: { cartVM.incrementQuantity(for: item.id) }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.activePalette.primary)
                    .frame(width: 36, height: 36)
                    .background(themeManager.activePalette.primarySubtle)
            }
            .buttonStyle(.plain)

            // Line total
            Text(ArabicNumeralFormatter.formatLYD(item.lineTotalLyd, isRTL: themeManager.isRTL))
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.primary)
                .padding(.leading, 12)
        }
    }
}

/// Cart price breakdown
struct CartPriceBreakdownView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 12) {
            PriceRow(
                label: themeManager.isRTL ? "المجموع الفرعي" : "Subtotal",
                value: ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.foodSubtotalLyd + cartVM.orderPriceBreakdown.modifiersSubtotalLyd, isRTL: themeManager.isRTL),
                color: themeManager.activePalette.textPrimary
            )

            if cartVM.orderPriceBreakdown.baseDeliveryFeeLyd > 0 {
                PriceRow(
                    label: themeManager.isRTL ? "التوصيل" : "Delivery",
                    value: ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.baseDeliveryFeeLyd, isRTL: themeManager.isRTL),
                    color: themeManager.activePalette.primary
                )
            }

            if cartVM.orderPriceBreakdown.coordinationFeesLyd > 0 {
                PriceRow(
                    label: themeManager.isRTL ? "رسوم التنسيق" : "Coordination Fees",
                    value: ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.coordinationFeesLyd, isRTL: themeManager.isRTL),
                    color: themeManager.activePalette.warning
                )
            }

            if cartVM.orderPriceBreakdown.serviceFeeLyd > 0 {
                PriceRow(
                    label: themeManager.isRTL ? "رسوم الخدمة" : "Service Fee",
                    value: ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.serviceFeeLyd, isRTL: themeManager.isRTL),
                    color: themeManager.activePalette.textSecondary
                )
            }

            if cartVM.orderPriceBreakdown.totalDiscountsLyd > 0 {
                PriceRow(
                    label: themeManager.isRTL ? "الخصومات" : "Discounts",
                    value: "-\(ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.totalDiscountsLyd, isRTL: themeManager.isRTL))",
                    color: themeManager.activePalette.success
                )
            }

            Divider()
                .background(themeManager.activePalette.borderSubtle)

            PriceRow(
                label: themeManager.isRTL ? "الإجمالي" : "Total",
                value: ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.finalTotalLyd, isRTL: themeManager.isRTL),
                color: themeManager.activePalette.primary,
                isTotal: true
            )
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

struct PriceRow: View {
    let label: String
    let value: String
    let color: Color
    var isTotal: Bool = false
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? KooiTypography.headlineMedium.font(locale: Locale.current) : KooiTypography.bodyMedium.font(locale: Locale.current))
                .foregroundColor(isTotal ? themeManager.activePalette.textPrimary : themeManager.activePalette.textSecondary)

            Spacer()

            Text(value)
                .font(isTotal ? KooiTypography.headlineMedium.font(locale: Locale.current) : KooiTypography.bodyMedium.font(locale: Locale.current))
                .foregroundColor(color)
        }
    }
}