import SwiftUI

/// Item detail view with modifier/addon selection, quantity stepper, and add to cart
struct ItemDetailView: View {
    let menuItem: MenuItem
    let restaurant: Restaurant
    @EnvironmentObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                themeManager.activePalette.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Item image
                        ItemImageView()

                        // Content
                        VStack(spacing: 20) {
                            // Header
                            ItemHeaderView()

                            // Description
                            if let description = themeManager.isRTL ? menuItem.descriptionAr : menuItem.descriptionEn,
                               !description.isEmpty {
                                ItemDescriptionView(description: description)
                            }

                            // Modifiers/Addons
                            if viewModel.isLoadingOptions {
                                ModifierSkeletonSection()
                            } else if let options = viewModel.itemOptions, !options.categories.isEmpty {
                                ModifiersSectionView(options: options)
                            } else if !menuItem.modifiers.isEmpty {
                                SimpleModifiersView(modifiers: menuItem.modifiers)
                            }

                            // Quantity stepper
                            QuantityStepperView()

                            // Note
                            NoteInputView()

                            // Price summary
                            PriceSummaryView()

                            // Bottom padding for CTA
                            Color.clear.frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }

                // Add to Cart CTA
                AddToCartCTAView()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 34)
            }
            .navigationTitle(themeManager.isRTL ? (menuItem.nameAr) : (menuItem.nameEn))
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
        .onAppear {
            viewModel.setMenuItem(menuItem)
        }
        .rtlLayout(themeManager.isRTL)
    }
}

/// Item image with gallery support
struct ItemImageView: View {
    @EnvironmentObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        let menuItem = viewModel.menuItem

        ZStack(alignment: .topTrailing) {
            AsyncImage(url: URL(string: menuItem?.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    ImagePlaceholder(artType: menuItem?.artType ?? .burgerCombo)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    ImagePlaceholder(artType: menuItem?.artType ?? .burgerCombo)
                @unknown default:
                    ImagePlaceholder(artType: menuItem?.artType ?? .burgerCombo)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .clipped()

            // Favorite button
            Button(action: {}) {
                Image(systemName: "heart")
                    .font(.title3)
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .padding(12)
                    .background(themeManager.activePalette.overlayScrim)
                    .clipShape(Circle())
            }
            .padding(16)
        }
    }
}

struct ImagePlaceholder: View {
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

/// Item header with name, category, ratings
struct ItemHeaderView: View {
    @EnvironmentObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        let menuItem = viewModel.menuItem

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(themeManager.isRTL ? (menuItem?.nameAr ?? "") : (menuItem?.nameEn ?? ""))
                        .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    HStack(spacing: 8) {
                        // Category
                        Text(themeManager.isRTL ? (menuItem?.categoryAr ?? "") : (menuItem?.categoryEn ?? ""))
                            .font(KooiTypography.labelMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(themeManager.activePalette.primarySubtle)
                            .clipShape(Capsule())

                        // Restaurant name
                        Text(themeManager.isRTL ? (menuItem?.restaurantNameAr ?? "") : (menuItem?.restaurantNameEn ?? ""))
                            .font(KooiTypography.bodySmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textTertiary)
                    }
                }

                Spacer()

                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.activePalette.accent)

                    Text(String(format: "%.1f", menuItem?.calories ?? 0))
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textSecondary)
                }
            }

            // Tags
            if let menuItem = menuItem {
                HStack(spacing: 8) {
                    if menuItem.isPopular {
                        TagView(text: themeManager.isRTL ? "شائع" : "Popular", color: themeManager.activePalette.warning)
                    }
                    if menuItem.isCombo {
                        TagView(text: themeManager.isRTL ? "كومبو" : "Combo", color: themeManager.activePalette.success)
                    }
                    if menuItem.isNewAddition {
                        TagView(text: themeManager.isRTL ? "جديد" : "New", color: themeManager.activePalette.success)
                    }
                    if let offerBadge = themeManager.isRTL ? menuItem.offerBadgeAr : menuItem.offerBadgeEn {
                        TagView(text: offerBadge, color: themeManager.activePalette.error)
                    }
                }
            }
        }
    }
}

struct TagView: View {
    let text: String
    let color: Color
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Text(text)
            .font(KooiTypography.labelSmall.font(locale: Locale.current))
            .foregroundColor(themeManager.activePalette.textOnPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color)
            .clipShape(Capsule())
    }
}

/// Item description
struct ItemDescriptionView: View {
    let description: String
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(themeManager.isRTL ? "الوصف" : "Description")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            Text(description)
                .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Simple modifiers (from menu item)
struct SimpleModifiersView: View {
    let modifiers: [MenuModifierOption]
    @EnvironmentObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "خيارات التحضير" : "Preparation Options")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            ForEach(modifiers) { modifier in
                ModifierRowView(
                    modifier: modifier,
                    isSelected: viewModel.isModifierSelected(modifier.id)
                ) {
                    viewModel.toggleModifier(modifier.id)
                }
            }
        }
    }
}

/// Full modifiers section from GetItemOptionAddonDetails
struct ModifiersSectionView: View {
    let options: MenuItemOptions
    @EnvironmentObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(options.categories) { category in
                ModifierCategoryView(
                    category: category,
                    selectedOptionId: viewModel.selectedOptions[category.id]
                ) { optionId in
                    viewModel.selectOption(categoryId: category.id, optionId: optionId)
                }
            }
        }
    }
}

struct ModifierCategoryView: View {
    let category: MenuItemOptionCategory
    let selectedOptionId: String?
    let onSelect: (String) -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    private var title: String {
        category.categoryType == "Addon" ? category.addonTitleAr : category.optionTitleAr
    }

    private var titleEn: String {
        category.categoryType == "Addon" ? category.addonTitleEn : category.optionTitleEn
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(themeManager.isRTL ? title : titleEn)
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            ForEach(category.options) { option in
                let isSelected = selectedOptionId == option.id
                let isAddon = category.categoryType == "Addon"

                if isAddon {
                    AddonRowView(
                        option: option,
                        isSelected: isSelected
                    ) {
                        onSelect(option.id)
                    }
                } else {
                    OptionRowView(
                        option: option,
                        isSelected: isSelected
                    ) {
                        onSelect(option.id)
                    }
                }
            }
        }
    }
}

struct AddonRowView: View {
    let option: MenuModifierOption
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.border)

                VStack(alignment: .leading, spacing: 2) {
                    Text(themeManager.isRTL ? option.labelAr : option.labelEn)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    if !option.isAvailable {
                        Text(themeManager.isRTL ? "غير متاح" : "Unavailable")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textDisabled)
                    }
                }

                Spacer()

                // Price
                if option.extraPriceLyd > 0 {
                    Text("+\(ArabicNumeralFormatter.formatLYD(option.extraPriceLyd, isRTL: themeManager.isRTL))")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
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
        .disabled(!option.isAvailable)
    }
}

struct OptionRowView: View {
    let option: MenuModifierOption
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Radio button
                Circle()
                    .stroke(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.border, lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(themeManager.activePalette.primary)
                            .frame(width: 12, height: 12)
                            .opacity(isSelected ? 1 : 0)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(themeManager.isRTL ? option.labelAr : option.labelEn)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    if !option.isAvailable {
                        Text(themeManager.isRTL ? "غير متاح" : "Unavailable")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textDisabled)
                    }
                }

                Spacer()

                // Price
                if option.extraPriceLyd > 0 {
                    Text("+\(ArabicNumeralFormatter.formatLYD(option.extraPriceLyd, isRTL: themeManager.isRTL))")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
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
        .disabled(!option.isAvailable)
    }
}

/// Modifier row for simple modifiers
struct ModifierRowView: View {
    let modifier: MenuModifierOption
    let isSelected: Bool
    let onToggle: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? themeManager.activePalette.primary : themeManager.activePalette.border)

                VStack(alignment: .leading, spacing: 2) {
                    Text(themeManager.isRTL ? modifier.labelAr : modifier.labelEn)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textPrimary)

                    if !modifier.isAvailable {
                        Text(themeManager.isRTL ? "غير متاح" : "Unavailable")
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textDisabled)
                    }
                }

                Spacer()

                if modifier.extraPriceLyd > 0 {
                    Text("+\(ArabicNumeralFormatter.formatLYD(modifier.extraPriceLyd, isRTL: themeManager.isRTL))")
                        .font(KooiTypography.labelMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.primary)
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
        .disabled(!modifier.isAvailable)
    }
}

/// Skeleton for modifiers section
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

/// Quantity stepper
struct QuantityStepperView: View {
    @EnvironmentObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(themeManager.isRTL ? "الكمية" : "Quantity")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            HStack {
                Button(action: { viewModel.decrementQuantity() }) {
                    Image(systemName: "minus")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(themeManager.activePalette.primary)
                        .frame(width: 48, height: 48)
                        .background(themeManager.activePalette.primarySubtle)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(viewModel.selectedQuantity <= 1)

                Text("\(viewModel.selectedQuantity)")
                    .font(KooiTypography.displayMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .frame(minWidth: 60)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedQuantity)

                Button(action: { viewModel.incrementQuantity() }) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(themeManager.activePalette.primary)
                        .frame(width: 48, height: 48)
                        .background(themeManager.activePalette.primarySubtle)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
    }
}

/// Note input
struct NoteInputView: View {
    @EnvironmentObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(themeManager.isRTL ? "ملاحظات خاصة" : "Special Instructions")
                .font(KooiTypography.titleMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textPrimary)

            TextField(
                themeManager.isRTL ? "أضف ملاحظة (اختياري)..." : "Add a note (optional)...",
                text: $viewModel.customizationNote,
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

/// Price summary
struct PriceSummaryView: View {
    @EnvironmentObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    private var unitPrice: Int {
        (viewModel.menuItem?.priceLyd ?? 0) + viewModel.modifierExtraLyd
    }

    private var totalPrice: Int {
        unitPrice * viewModel.selectedQuantity
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(themeManager.isRTL ? "سعر الوحدة" : "Unit Price")
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)

                Spacer()

                Text(ArabicNumeralFormatter.formatLYD(unitPrice, isRTL: themeManager.isRTL))
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
            }

            Divider()
                .background(themeManager.activePalette.borderSubtle)

            HStack {
                Text(themeManager.isRTL ? "الإجمالي" : "Total")
                    .font(KooiTypography.titleMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)

                Spacer()

                Text(ArabicNumeralFormatter.formatLYD(totalPrice, isRTL: themeManager.isRTL))
                    .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
            }
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// Add to cart CTA
struct AddToCartCTAView: View {
    @EnvironmentObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: {
            viewModel.addToCart()
            dismiss()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "cart.badge.plus")
                    .font(.title2)

                Text(viewModel.isValidSelection
                     ? (themeManager.isRTL ? "أضف إلى السلة" : "Add to Cart")
                     : (themeManager.isRTL ? "أكمل الاختيارات المطلوبة" : "Complete required selections"))
                    .font(KooiTypography.buttonLarge.font(locale: Locale.current))
            }
            .foregroundColor(themeManager.activePalette.textOnPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(viewModel.isValidSelection ? themeManager.activePalette.primary : themeManager.activePalette.textDisabled)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: viewModel.isValidSelection ? themeManager.activePalette.primary.opacity(0.4) : .clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.isValidSelection)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isValidSelection)
    }
}