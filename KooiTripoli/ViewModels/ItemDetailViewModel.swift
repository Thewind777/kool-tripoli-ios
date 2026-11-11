import Foundation
import Combine
import SwiftUI

/// ViewModel for item detail screen with addon/option handling
/// Mirrors the Kotlin `GetItemOptionAddonDetails` dynamic state handling
@MainActor
public final class ItemDetailViewModel: ObservableObject {
    // MARK: - Published State

    @Published public var menuItem: MenuItem?
    @Published public var itemOptions: MenuItemOptions?
    @Published public var isLoadingOptions: Bool = false
    @Published public var optionsErrorAr: String?
    @Published public var optionsErrorEn: String?
    @Published public var selectedQuantity: Int = 1
    @Published public var selectedModifiers: Set<String> = [] // Modifier option IDs
    @Published public var selectedOptions: [String: String] = [:] // Category ID -> Selected Option ID
    @Published public var customizationNote: String = ""
    @Published public var modifierExtraLyd: Int = 0

    // Dependencies
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {}

    /// Loads full options/addons for a menu item
    public func loadItemOptions(storeId: String, menuItemId: String) {
        isLoadingOptions = true
        optionsErrorAr = nil
        optionsErrorEn = nil

        Task {
            do {
                let json = try await apiClient.getItemOptionAddonDetails(
                    storeId: storeId,
                    userId: apiClient.userId.isEmpty ? nil : apiClient.userId,
                    system: "DeliverAll",
                    menuItemId: menuItemId
                )

                // Parse the response
                if let message = json["message"] as? [String: Any],
                   let categoriesData = message["categories"] as? [[String: Any]] {
                    let categories = categoriesData.compactMap { MenuItemOptionCategory.from(json: $0) }
                    let options = MenuItemOptions(categories: categories)

                    await MainActor.run {
                        self.itemOptions = options
                        self.isLoadingOptions = false
                        self.optionsErrorAr = nil
                        self.optionsErrorEn = nil
                    }
                } else {
                    await MainActor.run {
                        self.itemOptions = nil
                        self.isLoadingOptions = false
                    }
                }
            } catch let error as KooiAPIError {
                await MainActor.run {
                    self.isLoadingOptions = false
                    self.optionsErrorAr = "تعذّر تحميل خيارات الصنف"
                    self.optionsErrorEn = error.messageEn
                }
            } catch {
                await MainActor.run {
                    self.isLoadingOptions = false
                    self.optionsErrorAr = "تعذّر تحميل خيارات الصنف"
                    self.optionsErrorEn = error.localizedDescription
                }
            }
        }
    }

    /// Sets the menu item and loads its options if needed
    public func setMenuItem(_ item: MenuItem) {
        self.menuItem = item
        // Reset selections
        selectedQuantity = 1
        selectedModifiers = []
        selectedOptions = [:]
        customizationNote = ""
        modifierExtraLyd = 0

        // Load full options if not already loaded
        if item.options == nil {
            loadItemOptions(storeId: item.restaurantId, menuItemId: item.id)
        } else {
            self.itemOptions = item.options
        }
    }

    // MARK: - Selection Helpers

    public func toggleModifier(_ modifierId: String) {
        if selectedModifiers.contains(modifierId) {
            selectedModifiers.remove(modifierId)
        } else {
            selectedModifiers.insert(modifierId)
        }
        updateModifierExtraPrice()
    }

    public func selectOption(categoryId: String, optionId: String) {
        selectedOptions[categoryId] = optionId
        updateModifierExtraPrice()
    }

    public func isModifierSelected(_ modifierId: String) -> Bool {
        selectedModifiers.contains(modifierId)
    }

    public func isOptionSelected(categoryId: String, optionId: String) -> Bool {
        selectedOptions[categoryId] == optionId
    }

    public func incrementQuantity() {
        selectedQuantity += 1
    }

    public func decrementQuantity() {
        if selectedQuantity > 1 {
            selectedQuantity -= 1
        }
    }

    private func updateModifierExtraPrice() {
        var totalExtra = 0

        // Add modifier prices
        for modifierId in selectedModifiers {
            if let modifier = menuItem?.modifiers.first(where: { $0.id == modifierId }) {
                totalExtra += modifier.extraPriceLyd
            }
            // Also check in options categories
            for category in itemOptions?.categories ?? [] {
                if let modifier = category.options.first(where: { $0.id == modifierId && category.categoryType == "Addon" }) {
                    totalExtra += modifier.extraPriceLyd
                }
            }
        }

        // Add option prices (for "Options" type categories, usually no extra price but could have)
        for (_, optionId) in selectedOptions {
            for category in itemOptions?.categories ?? [] {
                if let option = category.options.first(where: { $0.id == optionId && category.categoryType == "Addon" }) {
                    totalExtra += option.extraPriceLyd
                }
            }
        }

        modifierExtraLyd = totalExtra
    }

    // MARK: - Validation

    public var isValidSelection: Bool {
        guard let options = itemOptions else { return true }

        // Check required option categories
        for category in options.categories {
            if category.categoryType == "Options" && !category.options.isEmpty {
                // Check if any option is required (has isDefault or marked as required)
                let hasRequired = category.options.contains { $0.isDefault }
                if hasRequired && selectedOptions[category.id] == nil {
                    // Check if there's a default selected
                    let hasDefault = category.options.contains { $0.isDefault }
                    if !hasDefault {
                        return false // Required option not selected
                    }
                }
            }
        }
        return true
    }

    public var validationErrorAr: String? {
        guard let options = itemOptions else { return nil }

        for category in options.categories {
            if category.categoryType == "Options" && !category.options.isEmpty {
                let hasRequired = category.options.contains { $0.isDefault }
                if hasRequired && selectedOptions[category.id] == nil {
                    let hasDefault = category.options.contains { $0.isDefault }
                    if !hasDefault {
                        return "يرجى اختيار \(category.nameAr)"
                    }
                }
            }
        }
        return nil
    }

    public var validationErrorEn: String? {
        guard let options = itemOptions else { return nil }

        for category in options.categories {
            if category.categoryType == "Options" && !category.options.isEmpty {
                let hasRequired = category.options.contains { $0.isDefault }
                if hasRequired && selectedOptions[category.id] == nil {
                    let hasDefault = category.options.contains { $0.isDefault }
                    if !hasDefault {
                        return "Please select \(category.nameEn)"
                    }
                }
            }
        }
        return nil
    }

    // MARK: - Cart Item Creation

    public func createCartItem() -> CartItem? {
        guard let menuItem = menuItem, isValidSelection else { return nil }

        let cartItem = CartItem(
            menuItem: menuItem,
            quantity: selectedQuantity,
            note: customizationNote,
            modifierExtraLyd: modifierExtraLyd,
            quotedUnitPriceLyd: menuItem.priceLyd
        )

        return cartItem
    }

    public func addToCart(cartStore: LocalCartStore = LocalCartStore.shared) {
        guard let cartItem = createCartItem() else { return }
        cartStore.addCartItem(cartItem)
    }
}