import SwiftUI

/// Persistent floating bottom bar showing live item counts and restaurant totals
struct GroupCartBarView: View {
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 0) {
            // Main bar
            HStack(spacing: 16) {
                // Cart icon with count
                Button(action: { coordinator.showCart() }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(themeManager.activePalette.primary)

                        if cartStore.totalCartCount > 0 {
                            Text("\(cartStore.totalCartCount)")
                                .font(KooiTypography.labelSmall.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.textOnPrimary)
                                .frame(minWidth: 18, minHeight: 18)
                                .background(themeManager.activePalette.error)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: cartStore.totalCartCount)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Restaurant summary
                VStack(alignment: .leading, spacing: 2) {
                    if let storeName = cartStore.singleCartStoreNameAr ?? cartStore.singleCartStoreNameEn {
                        Text(storeName)
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textPrimary)
                            .lineLimit(1)
                    } else if cartStore.distinctCartStoreCount > 1 {
                        Text(themeManager.isRTL
                             ? "\(cartStore.distinctCartStoreCount) مطاعم"
                             : "\(cartStore.distinctCartStoreCount) Restaurants")
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textPrimary)
                    }

                    Text(themeManager.isRTL
                         ? "\(cartStore.totalCartCount) أصناف · \(ArabicNumeralFormatter.formatLYD(cartStore.totalCartLyd, isRTL: themeManager.isRTL))"
                         : "\(cartStore.totalCartCount) items · \(ArabicNumeralFormatter.formatLYD(cartStore.totalCartLyd, isRTL: themeManager.isRTL))")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                }

                Spacer()

                // View cart / Checkout button
                Button(action: { coordinator.showCart() }) {
                    HStack(spacing: 6) {
                        Text(themeManager.isRTL ? "عرض السلة" : "View Cart")
                            .font(KooiTypography.buttonMedium.font(locale: Locale.current))

                        Image(systemName: themeManager.isRTL ? "chevron.left" : "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(themeManager.activePalette.primary)
                    .clipShape(Capsule())
                    .shadow(
                        color: themeManager.activePalette.primary.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            // Restaurant breakdown (expandable)
            if cartStore.distinctCartStoreCount > 1 {
                Divider()
                    .background(themeManager.activePalette.borderSubtle)

                RestaurantBreakdownView()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
        }
        .background(
            themeManager.activePalette.surface
                .shadow(
                    color: themeManager.activePalette.overlayScrim,
                    radius: 14,
                    x: 0,
                    y: -4
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: cartStore.totalCartCount)
    }
}

/// Expandable restaurant breakdown
struct RestaurantBreakdownView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 8) {
            ForEach(cartVM.restaurantOrderGroups) { group in
                RestaurantBreakdownRow(group: group)
            }

            Divider()
                .background(themeManager.activePalette.borderSubtle)

            // Totals
            HStack {
                Text(themeManager.isRTL ? "المجموع الفرعي" : "Subtotal")
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)

                Spacer()

                Text(ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.foodSubtotalLyd + cartVM.orderPriceBreakdown.modifiersSubtotalLyd, isRTL: themeManager.isRTL))
                    .font(KooiTypography.titleMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
            }

            if cartVM.orderPriceBreakdown.baseDeliveryFeeLyd > 0 {
                HStack {
                    Text(themeManager.isRTL ? "التوصيل" : "Delivery")
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)

                    Spacer()

                    Text(ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.baseDeliveryFeeLyd, isRTL: themeManager.isRTL))
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
                }
            }

            if cartVM.orderPriceBreakdown.coordinationFeesLyd > 0 {
                HStack {
                    Text(themeManager.isRTL ? "رسوم التنسيق" : "Coordination Fees")
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)

                    Spacer()

                    Text(ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.coordinationFeesLyd, isRTL: themeManager.isRTL))
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.warning)
                }
            }

            if cartVM.orderPriceBreakdown.serviceFeeLyd > 0 {
                HStack {
                    Text(themeManager.isRTL ? "رسوم الخدمة" : "Service Fee")
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)

                    Spacer()

                    Text(ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.serviceFeeLyd, isRTL: themeManager.isRTL))
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                }
            }

            if cartVM.orderPriceBreakdown.totalDiscountsLyd > 0 {
                HStack {
                    Text(themeManager.isRTL ? "الخصومات" : "Discounts")
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.success)

                    Spacer()

                    Text("-\(ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.totalDiscountsLyd, isRTL: themeManager.isRTL))")
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.success)
                }
            }

            Divider()
                .background(themeManager.activePalette.borderSubtle)

            HStack {
                Text(themeManager.isRTL ? "الإجمالي" : "Total")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Spacer()

                Text(ArabicNumeralFormatter.formatLYD(cartVM.orderPriceBreakdown.finalTotalLyd, isRTL: themeManager.isRTL))
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
            }
        }
    }
}

struct RestaurantBreakdownRow: View {
    let group: RestaurantOrderGroup
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Restaurant name & status
            HStack {
                Text(group.restaurantNameAr.isEmpty ? group.restaurantNameEn : group.restaurantNameAr)
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                if !group.isAvailable {
                    Text(themeManager.isRTL ? "غير متاح" : "Unavailable")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.error)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeManager.activePalette.error.opacity(0.1))
                        .clipShape(Capsule())
                }

                Spacer()

                Text(ArabicNumeralFormatter.formatLYD(group.subtotalLyd, isRTL: themeManager.isRTL))
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
            }

            // Items
            ForEach(group.items) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(themeManager.activePalette.borderSubtle)
                        .frame(width: 4, height: 4)

                    Text("\(item.quantity)x \(themeManager.isRTL ? item.menuItem.nameAr : item.menuItem.nameEn)")
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                        .lineLimit(1)

                    Spacer()

                    Text(ArabicNumeralFormatter.formatLYD(item.lineTotalLyd, isRTL: themeManager.isRTL))
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)
                }
            }

            // Coordination fee
            if group.coordinationFeeLyd > 0 {
                HStack {
                    Text(themeManager.isRTL ? "رسوم التنسيق" : "Coordination Fee")
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.warning)

                    Spacer()

                    Text(ArabicNumeralFormatter.formatLYD(group.coordinationFeeLyd, isRTL: themeManager.isRTL))
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.warning)
                }
                .padding(.leading, 12)
            }
        }
        .padding(.vertical, 4)
    }
}