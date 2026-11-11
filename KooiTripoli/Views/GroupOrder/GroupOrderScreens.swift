import SwiftUI

// MARK: - Group Order Screens

/// Group order creation wizard with 6 steps
struct GroupOrderCreationView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = GroupOrderCreationViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress indicator
                    GroupOrderProgressIndicator(currentStep: viewModel.draft.stepIndex)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    // Step content
                    ScrollView {
                        GroupOrderStepContentView(draft: viewModel.draft)
                            .environmentObject(viewModel)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle(themeManager.isRTL ? "إنشاء طلب جماعي" : "Create Group Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { coordinator.dismissSheet() }) {
                        Image(systemName: themeManager.isRTL ? "chevron.right" : "chevron.left")
                            .font(.title2)
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.draft.stepIndex < 5 {
                        Button(action: { viewModel.nextStep() }) {
                            Text(themeManager.isRTL ? "التالي" : "Next")
                                .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.primary)
                        }
                        .disabled(!viewModel.canProceed)
                    } else {
                        Button(action: { viewModel.createGroup() }) {
                            Text(themeManager.isRTL ? "إنشاء المجموعة" : "Create Group")
                                .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.textOnPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(themeManager.activePalette.primary)
                                .clipShape(Capsule())
                        }
                        .disabled(!viewModel.canProceed)
                    }
                }
            }
        }
        .rtlLayout(themeManager.isRTL)
    }
}

/// Progress indicator for group order creation
struct GroupOrderProgressIndicator: View {
    let currentStep: Int
    @EnvironmentObject private var themeManager: ThemeManager

    private let steps = [
        (id: 0, titleAr: "النطاق", titleEn: "Scope"),
        (id: 1, titleAr: "المطاعم", titleEn: "Restaurants"),
        (id: 2, titleAr: "الاستلام", titleEn: "Fulfillment"),
        (id: 3, titleAr: "الدفع", titleEn: "Payment"),
        (id: 3, titleAr: "التفاصيل", titleEn: "Details"),
        (id: 5, titleAr: "مراجعة", titleEn: "Review")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                let isActive = index <= currentStep
                let isCompleted = index < currentStep

                HStack(spacing: 8) {
                    // Step circle
                    ZStack {
                        Circle()
                            .stroke(isActive ? themeManager.activePalette.primary : themeManager.activePalette.border, lineWidth: 2)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(isCompleted ? themeManager.activePalette.primary : (isActive ? themeManager.activePalette.primarySubtle : themeManager.activePalette.background))
                            )

                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(themeManager.activePalette.textOnPrimary)
                        } else {
                            Text("\(index + 1)")
                                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                                .foregroundColor(isActive ? themeManager.activePalette.primary : themeManager.activePalette.textTertiary)
                        }
                    }

                    // Step label (only on non-last)
                    if index < steps.count - 1 {
                        Text(themeManager.isRTL ? step.titleAr : step.titleEn)
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(isActive ? themeManager.activePalette.textPrimary : themeManager.activePalette.textTertiary)
                            .frame(maxWidth: .infinity)
                    }

                    // Connecting line
                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(isCompleted ? themeManager.activePalette.primary : themeManager.activePalette.borderSubtle)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
    }
}

/// Step content view
struct GroupOrderStepContentView: View {
    let draft: GroupCreationDraft
    @EnvironmentObject private var viewModel: GroupOrderCreationViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Group {
            switch draft.stepIndex {
            case 0:
                ScopeSelectionView()
            case 1:
                RestaurantSelectionView()
            case 2:
                FulfillmentModeSelectionView()
            case 3:
                PaymentModeSelectionView()
            case 4:
                GroupDetailsView()
            case 5:
                ReviewView()
            default:
                EmptyView()
            }
        }
    }
}

/// Step 0: Select ordering scope (single vs multi-restaurant)
struct ScopeSelectionView: View {
    @EnvironmentObject private var viewModel: GroupOrderCreationViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(themeManager.isRTL ? "ما نوع الطلب الجماعي؟" : "What type of group order?")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .multilineTextAlignment(.center)

                Text(themeManager.isRTL ? "اختر نطاق الطلب لتحديد خيارات المطاعم" : "Select order scope to determine restaurant options")
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)

            VStack(spacing: 16) {
                ScopeOptionCard(
                    icon: "fork.knife",
                    title: themeManager.isRTL ? "مطعم واحد" : "Single Restaurant",
                    subtitle: themeManager.isRTL ? "جميع المشاركين يطلبون من نفس المطعم" : "All participants order from the same restaurant",
                    isSelected: viewModel.draft.orderingScope == .singleRestaurant
                ) {
                    viewModel.updateDraftScope(.singleRestaurant)
                }

                ScopeOptionCard(
                    icon: "building.2.fill",
                    title: themeManager.isRTL ? "عدة مطاعم (شارع طعام)" : "Multi-Restaurant (Food Street)",
                    subtitle: themeManager.isRTL ? "اختر حتى 3 مطاعم في نفس الشارع بقائمة موحدة" : "Select up to 3 restaurants on one street with unified menu",
                    isSelected: viewModel.draft.orderingScope == .multiRestaurant
                ) {
                    viewModel.updateDraftScope(.multiRestaurant)
                }
            }

            if viewModel.draft.orderingScope == .singleRestaurant {
                RestaurantPickerView()
            } else {
                FoodStreetPickerView()
            }

            Spacer()
        }
    }
}

struct ScopeOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(isSelected ? themeManager.activePalette.textOnPrimary : themeManager.activePalette.primary)
                    .frame(width: 56, height: 56)
                    .background(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.primarySubtle)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text(subtitle)
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.border)
            }
            .padding(16)
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

/// Restaurant picker for single restaurant scope
struct RestaurantPickerView: View {
    @EnvironmentObject private var viewModel: GroupOrderCreationViewModel
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager

    private var suggestedRestaurants: [Restaurant] {
        if let firstItem = cartStore.cartItems.first {
            return cartStore.restaurants.filter { $0.id != firstItem.menuItem.restaurantId }
        }
        return cartStore.restaurants
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "اختر المطعم" : "Select Restaurant")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            ForEach(suggestedRestaurants) { restaurant in
                RestaurantSelectionRow(
                    restaurant: restaurant,
                    isSelected: viewModel.draft.singleRestaurantId == restaurant.id
                ) {
                    viewModel.updateDraftSingleRestaurant(restaurant.id)
                }
            }
        }
    }
}

/// Food street picker for multi-restaurant scope
struct FoodStreetPickerView: View {
    @EnvironmentObject private var viewModel: GroupOrderCreationViewModel
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "اختر شارع الطعام" : "Select Food Street")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            ForEach(cartStore.getCachedFoodStreets()) { street in
                FoodStreetSelectionRow(
                    street: street,
                    isSelected: viewModel.draft.mrStreetId == street.id
                ) {
                    viewModel.selectDraftMrStreet(street.id)
                }
            }
        }
    }
}

/// Step 1: Restaurant selection for multi-restaurant
struct RestaurantSelectionView: View {
    @EnvironmentObject private var viewModel: GroupOrderCreationViewModel
    @EnvironmentObject private var cartStore: LocalCartStore
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    private var availableRestaurants: [Restaurant] {
        guard let street = cartStore.getCachedFoodStreets().first(where: { $0.id == viewModel.draft.mrStreetId }) else {
            return []
        }
        return street.restaurantIds.compactMap { id in
            cartStore.getCachedRestaurants().first { $0.id == id && $0.isAvailableForOrdering }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text(themeManager.isRTL ? "اختر المطاعم (الحد الأقصى \(cartStore.getCachedFoodStreets().first(where: { $0.id == viewModel.draft.mrStreetId })?.maxSelectableRestaurants ?? 3))" : "Select Restaurants (Max \(cartStore.getCachedFoodStreets().first(where: { $0.id == viewModel.draft.mrStreetId })?.maxSelectableRestaurants ?? 3))")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .multilineTextAlignment(.center)

                Text("\(viewModel.draft.mrRestaurantIds.count)/\(cartStore.getCachedFoodStreets().first(where: { $0.id == viewModel.draft.mrStreetId })?.maxSelectableRestaurants ?? 3)")
                    .font(KooiTypography.titleMedium.font(locale: Locale.current))
                    .foregroundColor(viewModel.draft.mrRestaurantIds.count >= (cartStore.getCachedFoodStreets().first(where: { $0.id == viewModel.draft.mrStreetId })?.maxSelectableRestaurants ?? 3) ? themeManager.activePalette.error : themeManager.activePalette.primary)
            }
            .padding(.top, 24)

            ForEach(cartStore.getCachedFoodStreets().first(where: { $0.id == viewModel.draft.mrStreetId })?.restaurantIds.compactMap { id in
                cartStore.getCachedRestaurants().first { $0.id == id && $0.isAvailableForOrdering }
            } ?? []) { restaurant in
                RestaurantSelectionRow(
                    restaurant: restaurant,
                    isSelected: viewModel.draft.mrRestaurantIds.contains(restaurant.id),
                    maxSelection: cartStore.getCachedFoodStreets().first(where: { $0.id == viewModel.draft.mrStreetId })?.maxSelectableRestaurants ?? 3,
                    currentSelectionCount: viewModel.draft.mrRestaurantIds.count
                ) { isSelected in
                    viewModel.toggleDraftMrRestaurant(restaurant.id)
                }
            }

            Spacer()
        }
    }
}

/// Step 2: Fulfillment mode selection
struct FulfillmentModeSelectionView: View {
    @EnvironmentObject private var viewModel: GroupOrderCreationViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(themeManager.isRTL ? "طريقة الاستلام" : "Fulfillment Mode")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Text(themeManager.isRTL ? "اختر كيف سيستلم المشاركون طلباتهم" : "Choose how participants receive their orders")
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)

            VStack(spacing: 16) {
                FulfillmentModeCard(
                    mode: .delivery,
                    isSelected: viewModel.draft.fulfillmentMode == .delivery,
                    icon: "bicycle.circle.fill",
                    label: themeManager.isRTL ? "توصيل" : "Delivery",
                    subtitle: themeManager.isRTL ? "توصيل إلى عنوان المجموعة" : "Delivered to group address"
                ) {
                    viewModel.updateDraftFulfillment(.delivery)
                }

                FulfillmentModeCard(
                    mode: .pickup,
                    isSelected: viewModel.draft.fulfillmentMode == .pickup,
                    icon: "takeoutbag.and.cup.and.straw.fill",
                    label: themeManager.isRTL ? "استلام" : "Pickup",
                    subtitle: themeManager.isRTL ? "استلام من المطعم(مطاعم)" : "Collect from restaurant(s)"
                ) {
                    viewModel.updateDraftFulfillment(.pickup)
                }
            }

            Spacer()
        }
    }
}

struct FulfillmentModeCard: View {
    let mode: FulfillmentMode
    let isSelected: Bool
    let icon: String
    let label: String
    let subtitle: String
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(isSelected ? themeManager.activePalette.textOnPrimary : themeManager.activePalette.primary)

                VStack(spacing: 4) {
                    Text(label)
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text(subtitle)
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(
                isSelected ? themeManager.activePalette.primary : themeManager.activePalette.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.borderSubtle, lineWidth: isSelected ? 2 : 1)
            )
            .shadow(
                color: isSelected ? themeManager.activePalette.primary.opacity(0.3) : themeManager.activePalette.overlayScrim,
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 6 : 3
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// Step 3: Payment mode selection
struct PaymentModeSelectionView: View {
    @EnvironmentObject private var viewModel: GroupOrderCreationViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(themeManager.isRTL ? "كيف سيتم الدفع؟" : "How will payment work?")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Text(themeManager.isRTL ? "اختر طريقة تقسيم التكلفة بين المشاركين" : "Choose how costs are split among participants")
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)

            VStack(spacing: 16) {
                PaymentModeCard(
                    mode: .organizerPays,
                    isSelected: viewModel.draft.paymentMode == .organizerPays,
                    onTap: { viewModel.updateDraftPaymentMode(.organizerPays) }
                )

                PaymentModeCard(
                    mode: .everyonePaysOwnShare,
                    isSelected: viewModel.draft.paymentMode == .everyonePaysOwnShare,
                    onTap: { viewModel.updateDraftPaymentMode(.everyonePaysOwnShare) }
                )
            }

            if viewModel.draft.paymentMode == .everyonePaysOwnShare {
                FeeAllocationSelectionView()
            }

            Spacer()
        }
    }
}

struct PaymentModeCard: View {
    let mode: GroupPaymentMode
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(themeManager.isRTL ? mode.labelAr : mode.labelEn)
                            .font(KooiTypography.titleMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textPrimary)

                        Text(themeManager.isRTL ? mode.explanationAr : mode.explanationEn)
                            .font(KooiTypography.bodySmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                            .lineLimit(3)
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.border)
                }

                if isSelected && mode == .everyonePaysOwnShare {
                    Text(themeManager.isRTL ? "سيختار كل مشارك وسيلة دفع تدعم التقسيم" : "Each participant will choose a split-compatible payment method")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
                }
            }
            .padding(16)
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

/// Fee allocation selection for split payments
struct FeeAllocationSelectionView: View {
    @EnvironmentObject private var viewModel: GroupOrderCreationViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "طريقة توزيع الرسوم" : "Fee Allocation Method")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            ForEach(SharedFeeAllocationMode.allCases) { mode in
                FeeAllocationRow(
                    mode: mode,
                    isSelected: viewModel.draft.feeAllocationMode == mode
                ) {
                    viewModel.updateDraftFeeAllocation(mode)
                }
            }
        }
        .padding()
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.draft.paymentMode)
    }
}

struct FeeAllocationRow: View {
    let mode: SharedFeeAllocationMode
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(themeManager.isRTL ? mode.labelAr : mode.labelEn)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.border)
            }
            .padding(16)
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
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// Step 4: Group details (name, limit, deadline, messages)
struct GroupDetailsView: View {
    @EnvironmentObject private var viewModel: GroupOrderCreationViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var groupName: String = ""
    @State private var participantLimit: String = "6"
    @State private var deadlineMinutes: String = "25"
    @State private var welcomeMessage: String = ""
    @State private var deliveryInstructions: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(themeManager.isRTL ? "تفاصيل المجموعة" : "Group Details")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .padding(.top, 24)

                // Group name
                VStack(alignment: .leading, spacing: 8) {
                    Text(themeManager.isRTL ? "اسم المجموعة" : "Group Name")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)

                    TextField(themeManager.isRTL ? "مثال: غداء فريق طرابلس" : "e.g., Tripoli Squad Lunch", text: $groupName)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .padding(16)
                        .background(themeManager.activePalette.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.activePalette.borderSubtle, lineWidth: 1)
                        )
                }

                // Participant limit
                VStack(alignment: .leading, spacing: 8) {
                    Text(themeManager.isRTL ? "الحد الأقصى للمشاركين" : "Participant Limit")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)

                    HStack {
                        TextField("6", text: $participantLimit)
                            .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 60)
                            .padding(16)
                            .background(themeManager.activePalette.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.activePalette.borderSubtle, lineWidth: 1)
                            )

                        Text(themeManager.isRTL ? "مشاركين" : "participants")
                            .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textSecondary)

                        Spacer()
                    }
                }

                // Deadline
                VStack(alignment: .leading, spacing: 8) {
                    Text(themeManager.isRTL ? "مهلة الانضمام (دقائق)" : "Join Deadline (minutes)")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)

                    HStack {
                        TextField("25", text: $deadlineMinutes)
                            .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 60)
                            .padding(16)
                            .background(themeManager.activePalette.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.activePalette.borderSubtle, lineWidth: 1)
                            )

                        Text(themeManager.isRTL ? "دقيقة" : "min")
                            .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textSecondary)

                        Spacer()
                    }
                }

                // Welcome message
                VStack(alignment: .leading, spacing: 8) {
                    Text(themeManager.isRTL ? "رسالة ترحيب (اختياري)" : "Welcome Message (optional)")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)

                    TextField(themeManager.isRTL ? "أهلاً بالجميع! اختاروا ما تحبون..." : "Welcome everyone! Pick what you like...", text: $welcomeMessage, axis: .vertical)
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

                // Delivery instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text(themeManager.isRTL ? "تعليمات التوصيل (اختياري)" : "Delivery Instructions (optional)")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)

                    TextField(themeManager.isRTL ? "اتركوا الطلب عند الباب..." : "Leave order at the door...", text: $deliveryInstructions, axis: .vertical)
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

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            groupName = viewModel.draft.groupName
            participantLimit = "\(viewModel.draft.participantLimit ?? 6)"
            deadlineMinutes = "\(viewModel.draft.deadlineMinutes)"
            welcomeMessage = viewModel.draft.welcomeMessage
            deliveryInstructions = viewModel.draft.deliveryInstructions
        }
        .onChange(of: groupName) { viewModel.updateDraftConfig(groupName: $0) }
        .onChange(of: participantLimit) { viewModel.updateDraftConfig(participantLimit: Int($0) ?? 6) }
        .onChange(of: deadlineMinutes) { viewModel.updateDraftConfig(deadlineMinutes: Int($0) ?? 25) }
        .onChange(of: welcomeMessage) { viewModel.updateDraftConfig(welcomeMessage: $0) }
        .onChange(of: deliveryInstructions) { viewModel.updateDraftConfig(deliveryInstructions: $0) }
    }
}

/// Step 5: Review and create
struct ReviewView: View {
    @EnvironmentObject private var viewModel: GroupOrderCreationViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(themeManager.isRTL ? "مراجعة وإنشاء" : "Review & Create")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .padding(.top, 24)

                // Scope
                ReviewSection(title: themeManager.isRTL ? "النطاق" : "Scope") {
                    HStack {
                        Image(systemName: viewModel.draft.orderingScope == .singleRestaurant ? "fork.knife" : "building.2.fill")
                            .foregroundColor(themeManager.activePalette.primary)
                        Text(viewModel.draft.orderingScope == .singleRestaurant ? (themeManager.isRTL ? "مطعم واحد" : "Single Restaurant") : (themeManager.isRTL ? "عدة مطاعم" : "Multi-Restaurant"))
                            .foregroundColor(themeManager.activePalette.textPrimary)
                        Spacer()
                    }
                }

                // Restaurants
                ReviewSection(title: themeManager.isRTL ? "المطاعم" : "Restaurants") {
                    if viewModel.draft.orderingScope == .singleRestaurant {
                        if let restaurantId = viewModel.draft.singleRestaurantId,
                           let restaurant = cartStore.restaurants.first(where: { $0.id == restaurantId }) {
                            Text(restaurant.nameEn)
                                .foregroundColor(themeManager.activePalette.textPrimary)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(viewModel.draft.mrRestaurantIds.compactMap { id in
                                cartStore.restaurants.first { $0.id == id }
                            }) { restaurant in
                                Text("• \(restaurant.nameEn)")
                                    .foregroundColor(themeManager.activePalette.textSecondary)
                            }
                        }
                    }
                }

                // Fulfillment
                ReviewSection(title: themeManager.isRTL ? "الاستلام" : "Fulfillment") {
                    HStack {
                        Image(systemName: viewModel.draft.fulfillmentMode == .delivery ? "bicycle.circle.fill" : "takeoutbag.and.cup.and.straw.fill")
                            .foregroundColor(themeManager.activePalette.primary)
                        Text(viewModel.draft.fulfillmentMode == .delivery ? (themeManager.isRTL ? "توصيل" : "Delivery") : (themeManager.isRTL ? "استلام" : "Pickup"))
                            .foregroundColor(themeManager.activePalette.textPrimary)
                        Spacer()
                    }
                }

                // Payment
                ReviewSection(title: themeManager.isRTL ? "الدفع" : "Payment") {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: viewModel.draft.paymentMode == .organizerPays ? "person.fill" : "person.3.fill")
                                .foregroundColor(themeManager.activePalette.primary)
                            Text(viewModel.draft.paymentMode == .organizerPays ? (themeManager.isRTL ? "المنظم يدفع" : "Organizer Pays") : (themeManager.isRTL ? "كل شخص يدفع حصته" : "Everyone Pays Own Share"))
                                .foregroundColor(themeManager.activePalette.textPrimary)
                            Spacer()
                        }

                        if viewModel.draft.paymentMode == .everyonePaysOwnShare {
                            Text(themeManager.isRTL ? "توزيع الرسوم: \(viewModel.draft.feeAllocationMode == .proportionalBySubtotal ? (themeManager.isRTL ? "نسبية" : "Proportional") : (themeManager.isRTL ? "المنظم يتحمل" : "Organizer Pays Fees"))" : "Fee split: \(viewModel.draft.feeAllocationMode == .proportionalBySubtotal ? "Proportional" : "Organizer Pays Fees")")
                                .font(KooiTypography.bodySmall.font(locale: Locale.current))
                                .foregroundColor(themeManager.activePalette.textTertiary)
                        }
                    }
                }

                // Details
                ReviewSection(title: themeManager.isRTL ? "التفاصيل" : "Details") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.draft.groupName.isEmpty ? (themeManager.isRTL ? "بدون اسم" : "Unnamed") : viewModel.draft.groupName)
                            .foregroundColor(themeManager.activePalette.textPrimary)
                        Text("\(themeManager.isRTL ? "المشاركون: " : "Participants: ")\(viewModel.draft.participantLimit ?? 6)")
                            .font(KooiTypography.bodySmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                        Text("\(themeManager.isRTL ? "المهلة: " : "Deadline: ")\(viewModel.draft.deadlineMinutes) \(themeManager.isRTL ? "دقيقة" : "min")")
                            .font(KooiTypography.bodySmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer(minLength: 100)
        }
    }
}

struct ReviewSection<Content: View>: View {
    let title: String
    let content: Content
    @EnvironmentObject private var themeManager: ThemeManager

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textTertiary)

            content
                .font(KooiTypography.bodyMedium.font(locale: Locale.current))
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Group order room (active group)
struct GroupOrderRoomView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = GroupOrderRoomViewModel()

    let groupId: String?

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                if let group = cartVM.activeGroupOrder {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Group header
                            GroupRoomHeaderView(group: group)

                            // Participants
                            ParticipantsListView(group: group)

                            // Combined cart summary
                            if !group.combinedItems.isEmpty {
                                GroupCombinedCartView(group: group)
                            }

                            // Actions
                            GroupActionsView(group: group)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle(group?.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { coordinator.dismissSheet() }) {
                        Image(systemName: themeManager.isRTL ? "chevron.right" : "chevron.left")
                            .font(.title2)
                            .foregroundColor(themeManager.activePalette.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.shareInvite() }) {
                            Label(themeManager.isRTL ? "مشاركة الدعوة" : "Share Invite", systemImage: "square.and.arrow.up")
                        }
                        Button(action: { viewModel.copyInviteLink() }) {
                            Label(themeManager.isRTL ? "نسخ الرابط" : "Copy Link", systemImage: "link")
                        }
                        Button(action: { viewModel.showQR() }) {
                            Label(themeManager.isRTL ? "عرض QR" : "Show QR", systemImage: "qrcode")
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

struct GroupRoomHeaderView: View {
    let group: GroupOrder
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    Text(themeManager.isRTL ? "\(group.participants.filter { $0.isActiveInOrder }.count)/\(group.participantLimit ?? 6) \(group.status.labelAr)" : "\(group.participants.filter { $0.isActiveInOrder }.count)/\(group.participantLimit ?? 6) \(group.status.labelEn)")
                        .font(KooiTypography.bodySmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                }

                Spacer()

                // Status badge
                Text(group.status.labelAr)
                    .font(KooiTypography.labelSmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .clipShape(Capsule())
            }

            // Progress bar for payment status
            if group.status == .awaitingPayment || group.status == .readyToPlace {
                VStack(spacing: 6) {
                    HStack {
                        Text(themeManager.isRTL ? "المدفوعات" : "Payments")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textSecondary)
                        Spacer()
                        Text("\(group.participants.filter { $0.status == .paid && $0.isActiveInOrder }.count)/\(group.participants.filter { $0.isActiveInOrder }.count)")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.primary)
                    }

                    ProgressView(value: paymentProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: themeManager.activePalette.primary))
                        .scaleEffect(y: 2)
                }
            }
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statusColor: Color {
        @EnvironmentObject var themeManager: ThemeManager
        switch group.status {
        case .open: return themeManager.activePalette.success
        case .locked: return themeManager.activePalette.warning
        case .awaitingPayment: return themeManager.activePalette.accent
        case .readyToPlace: return themeManager.activePalette.primary
        case .placed: return themeManager.activePalette.info
        default: return themeManager.activePalette.textTertiary
        }
    }

    private var paymentProgress: Double {
        let active = group.participants.filter { $0.isActiveInOrder }
        guard !active.isEmpty else { return 0 }
        let paid = active.filter { $0.status == .paid }.count
        return Double(paid) / Double(active.count)
    }
}

struct ParticipantsListView: View {
    let group: GroupOrder
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "المشاركون" : "Participants")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            ForEach(group.participants.filter { $0.isActiveInOrder }) { participant in
                ParticipantRowView(participant: participant, group: group)
            }
        }
    }
}

struct ParticipantRowView: View {
    let participant: GroupParticipant
    let group: GroupOrder
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(themeManager.activePalette.primarySubtle)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(participant.nameEn.prefix(1)).uppercased())
                        .font(KooiTypography.titleMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(participant.nameEn)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    if participant.isOrganizer {
                        Text(themeManager.isRTL ? "المنظم" : "Organizer")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(themeManager.activePalette.primarySubtle)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    // Status badge
                    Text(participant.status.labelEn)
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor)
                        .clipShape(Capsule())
                }

                Text("\(participant.items.count) items · \(participant.itemsSubtotalLyd) LYD")
                    .font(KooiTypography.bodySmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)
            }

            // Switch to participant (if organizer)
            if group.organizerId == "user_self" && participant.id != "user_self" {
                Button(action: { /* switchViewingParticipant */ }) {
                    Image(systemName: "eye")
                        .font(.title3)
                        .foregroundColor(themeManager.activePalette.primary)
                }
            }
        }
        .padding(12)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusColor: Color {
        @EnvironmentObject var themeManager: ThemeManager
        switch participant.status {
        case .paid: return themeManager.activePalette.success
        case .submitted: return themeManager.activePalette.primary
        case .paymentPending: return themeManager.activePalette.accent
        case .editing: return themeManager.activePalette.warning
        default: return themeManager.activePalette.textTertiary
        }
    }
}

struct GroupCombinedCartView: View {
    let group: GroupOrder
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "السلة المجمعة" : "Combined Cart")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            ForEach(group.combinedItems) { item in
                GroupCartItemRow(item: item)
            }

            // Total
            HStack {
                Text(themeManager.isRTL ? "الإجمالي" : "Total")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Spacer()

                Text("\(group.combinedItems.reduce(0) { $0 + $1.lineTotalLyd }) LYD")
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct GroupCartItemRow: View {
    let item: CartItem
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(themeManager.activePalette.borderSubtle)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.menuItem.nameEn)
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .lineLimit(1)

                Text("\(item.quantity)x · \(item.lineTotalLyd) LYD")
                    .font(KooiTypography.bodySmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)

                Text(item.participantName.isEmpty ? "" : "by \(item.participantName)")
                    .font(KooiTypography.labelSmall.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
            }

            Spacer()
        }
        .padding(12)
        .background(themeManager.activePalette.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct GroupActionsView: View {
    let group: GroupOrder
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = GroupOrderRoomViewModel()

    var body: some View {
        VStack(spacing: 12) {
            if group.status == .open && group.organizerId == "user_self" {
                Button(action: { viewModel.lockGroup() }) {
                    HStack {
                        Image(systemName: "lock.fill")
                        Text(themeManager.isRTL ? "قفل السلة للمراجعة" : "Lock Basket for Review")
                    }
                    .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.activePalette.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            if group.status == .locked && group.organizerId == "user_self" {
                Button(action: { viewModel.reopenGroup() }) {
                    HStack {
                        Image(systemName: "lock.open.fill")
                        Text(themeManager.isRTL ? "إعادة فتح السلة" : "Reopen Basket")
                    }
                    .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.activePalette.primarySubtle)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.activePalette.primary, lineWidth: 1)
                    )
                }
            }

            if group.status == .readyToPlace && group.organizerId == "user_self" {
                Button(action: { viewModel.placeGroupOrder() }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(themeManager.isRTL ? "إرسال الطلب الجماعي" : "Place Group Order")
                    }
                    .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.activePalette.success)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            if group.status == .awaitingPayment && group.organizerId == "user_self" {
                Button(action: { viewModel.payOwnShare() }) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text(themeManager.isRTL ? "دفع حصتي" : "Pay My Share")
                    }
                    .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.activePalette.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
}

/// ViewModels for group order screens
@MainActor
public final class GroupOrderCreationViewModel: ObservableObject {
    @Published public var draft: GroupCreationDraft = GroupCreationDraft()

    private let cartStore = LocalCartStore.shared

    public var canProceed: Bool {
        switch draft.stepIndex {
        case 0:
            return draft.orderingScope == .multiRestaurant ? draft.mrRestaurantIds.count >= 2 : draft.singleRestaurantId != nil
        case 1:
            return draft.mrRestaurantIds.count >= 2
        case 2:
            return true
        case 3:
            return true
        case 4:
            return !draft.groupName.trimmingCharacters(in: .whitespaces).isEmpty
        case 5:
            return true
        default:
            return false
        }
    }

    public func nextStep() {
        if draft.stepIndex < 5 {
            draft.stepIndex += 1
        }
    }

    public func updateDraftScope(_ scope: OrderingScope) {
        draft.orderingScope = scope
        if scope == .singleRestaurant {
            draft.mrRestaurantIds = []
        } else {
            draft.singleRestaurantId = nil
        }
    }

    public func updateDraftSingleRestaurant(_ id: String) {
        draft.singleRestaurantId = id
    }

    public func selectDraftMrStreet(_ streetId: String) {
        draft.mrStreetId = streetId
        let street = cartStore.getCachedFoodStreets().first { $0.id == streetId }
        let initialIds = street?.restaurantIds.filter { id in
            cartStore.getCachedRestaurants().first { $0.id == id }?.isAvailableForOrdering == true
        }.prefix(2).map { $0 } ?? []
        draft.mrRestaurantIds = Array(initialIds)
    }

    public func toggleDraftMrRestaurant(_ restaurantId: String) {
        if draft.mrRestaurantIds.contains(restaurantId) {
            draft.mrRestaurantIds.removeAll { $0 == restaurantId }
        } else if draft.mrRestaurantIds.count < (cartStore.getCachedFoodStreets().first { $0.id == draft.mrStreetId }?.maxSelectableRestaurants ?? 3) {
            draft.mrRestaurantIds.append(restaurantId)
        }
    }

    public func updateDraftFulfillment(_ mode: FulfillmentMode) {
        draft.fulfillmentMode = mode
    }

    public func updateDraftPaymentMode(_ mode: GroupPaymentMode) {
        draft.paymentMode = mode
    }

    public func updateDraftFeeAllocation(_ mode: SharedFeeAllocationMode) {
        draft.feeAllocationMode = mode
    }

    public func updateDraftConfig(
        groupName: String? = nil,
        participantLimit: Int? = nil,
        deadlineMinutes: Int? = nil,
        welcomeMessage: String? = nil,
        deliveryInstructions: String? = nil
    ) {
        if let groupName { draft.groupName = groupName }
        if let participantLimit { draft.participantLimit = participantLimit }
        if let deadlineMinutes { draft.deadlineMinutes = deadlineMinutes }
        if let welcomeMessage { draft.welcomeMessage = welcomeMessage }
        if let deliveryInstructions { draft.deliveryInstructions = deliveryInstructions }
    }

    public func createGroup() {
        // Implementation would create GroupOrder via CartViewModel
    }
}

@MainActor
public final class GroupOrderRoomViewModel: ObservableObject {
    public func lockGroup() { /* Implementation */ }
    public func reopenGroup() { /* Implementation */ }
    public func placeGroupOrder() { /* Implementation */ }
    public func payOwnShare() { /* Implementation */ }
    public func shareInvite() { /* Implementation */ }
    public func copyInviteLink() { /* Implementation */ }
    public func showQR() { /* Implementation */ }
}