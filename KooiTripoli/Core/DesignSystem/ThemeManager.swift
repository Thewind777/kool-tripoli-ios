import SwiftUI
import Combine

/// Theme manager handling palette selection, RTL direction, and reduced motion preferences.
/// Mirrors the Compose `KooiTheme` + `KooiUiState` palette/RTL/reducedMotion management.
@MainActor
public final class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()

    @Published public var activePalette: KooiPalette = KooiColorPresets.kooiSunsetOrange
    @Published public var isRTL: Bool = Locale.current.language.languageCode?.identifier == "ar"
    @Published public var reducedMotion: Bool = false

    private init() {
        // Load saved preferences
        if let savedPaletteName = UserDefaults.standard.string(forKey: "activePalette"),
           let palette = paletteByName(savedPaletteName) {
            activePalette = palette
        }
        if let savedRTL = UserDefaults.standard.object(forKey: "isRTL") as? Bool {
            isRTL = savedRTL
        }
        if let savedReducedMotion = UserDefaults.standard.object(forKey: "reducedMotion") as? Bool {
            reducedMotion = savedReducedMotion
        }
    }

    public func selectPalette(_ palette: KooiPalette) {
        activePalette = palette
        UserDefaults.standard.set(paletteName(palette), forKey: "activePalette")
    }

    public func selectPalette(named name: String) {
        if let palette = paletteByName(name) {
            selectPalette(palette)
        }
    }

    public func toggleRTL() {
        isRTL.toggle()
        UserDefaults.standard.set(isRTL, forKey: "isRTL")
    }

    public func setRTL(_ value: Bool) {
        isRTL = value
        UserDefaults.standard.set(isRTL, forKey: "isRTL")
    }

    public func setReducedMotion(_ enabled: Bool) {
        reducedMotion = enabled
        UserDefaults.standard.set(reducedMotion, forKey: "reducedMotion")
    }

    public func toggleReducedMotion() {
        setReducedMotion(!reducedMotion)
    }

    /// Updates the restaurant info bubble opacity (0.25 – 0.98)
    public func updateRestaurantBubbleOpacity(_ alpha: Double) {
        let clamped = max(0.25, min(0.98, alpha))
        activePalette = KooiPalette(
            background: activePalette.background,
            surface: activePalette.surface,
            surfaceSubtle: activePalette.surfaceSubtle,
            surfaceInverse: activePalette.surfaceInverse,
            primary: activePalette.primary,
            primaryPressed: activePalette.primaryPressed,
            primarySubtle: activePalette.primarySubtle,
            accent: activePalette.accent,
            warning: activePalette.warning,
            information: activePalette.information,
            error: activePalette.error,
            textPrimary: activePalette.textPrimary,
            textSecondary: activePalette.textSecondary,
            textTertiary: activePalette.textTertiary,
            textOnPrimary: activePalette.textOnPrimary,
            textInverse: activePalette.textInverse,
            textDisabled: activePalette.textDisabled,
            border: activePalette.border,
            borderSubtle: activePalette.borderSubtle,
            success: activePalette.success,
            successSubtle: activePalette.successSubtle,
            warningSubtle: activePalette.warningSubtle,
            errorSubtle: activePalette.errorSubtle,
            infoSubtle: activePalette.infoSubtle,
            overlayScrim: activePalette.overlayScrim,
            restaurantInfoBubbleAlpha: clamped,
            promoTopLeftAlpha: activePalette.promoTopLeftAlpha,
            promoMidAlpha: activePalette.promoMidAlpha,
            promoBottomRightAlpha: activePalette.promoBottomRightAlpha,
            skeletonBase: activePalette.skeletonBase,
            skeletonHighlight: activePalette.skeletonHighlight
        )
    }

    /// Updates the hero promo bubble alphas
    public func updateHeroBubbleOpacities(
        topLeft: Double? = nil,
        mid: Double? = nil,
        bottomRight: Double? = nil
    ) {
        activePalette = KooiPalette(
            background: activePalette.background,
            surface: activePalette.surface,
            surfaceSubtle: activePalette.surfaceSubtle,
            surfaceInverse: activePalette.surfaceInverse,
            primary: activePalette.primary,
            primaryPressed: activePalette.primaryPressed,
            primarySubtle: activePalette.primarySubtle,
            accent: activePalette.accent,
            warning: activePalette.warning,
            information: activePalette.information,
            error: activePalette.error,
            textPrimary: activePalette.textPrimary,
            textSecondary: activePalette.textSecondary,
            textTertiary: activePalette.textTertiary,
            textOnPrimary: activePalette.textOnPrimary,
            textInverse: activePalette.textInverse,
            textDisabled: activePalette.textDisabled,
            border: activePalette.border,
            borderSubtle: activePalette.borderSubtle,
            success: activePalette.success,
            successSubtle: activePalette.successSubtle,
            warningSubtle: activePalette.warningSubtle,
            errorSubtle: activePalette.errorSubtle,
            infoSubtle: activePalette.infoSubtle,
            overlayScrim: activePalette.overlayScrim,
            restaurantInfoBubbleAlpha: activePalette.restaurantInfoBubbleAlpha,
            promoTopLeftAlpha: (topLeft ?? activePalette.promoTopLeftAlpha).clamped(0.30, 0.96),
            promoMidAlpha: (mid ?? activePalette.promoMidAlpha).clamped(0.30, 0.96),
            promoBottomRightAlpha: (bottomRight ?? activePalette.promoBottomRightAlpha).clamped(0.35, 0.99),
            skeletonBase: activePalette.skeletonBase,
            skeletonHighlight: activePalette.skeletonHighlight
        )
    }

    // MARK: - Helpers

    private func paletteName(_ palette: KooiPalette) -> String {
        switch palette {
        case _ where palette === KooiColorPresets.kooiSunsetOrange: return "kooiSunsetOrange"
        case _ where palette === KooiColorPresets.ramadanKareem: return "ramadanKareem"
        case _ where palette === KooiColorPresets.highContrast: return "highContrast"
        default: return "custom"
        }
    }

    private func paletteByName(_ name: String) -> KooiPalette? {
        switch name {
        case "kooiSunsetOrange": return KooiColorPresets.kooiSunsetOrange
        case "ramadanKareem": return KooiColorPresets.ramadanKareem
        case "highContrast": return KooiColorPresets.highContrast
        default: return nil
        }
    }
}

private extension Double {
    func clamped(_ min: Double, _ max: Double) -> Double {
        Swift.max(min, Swift.min(max, self))
    }
}

/// Environment key for ThemeManager
private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue: ThemeManager = ThemeManager.shared
}

public extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

/// View modifier to inject ThemeManager into environment
public struct ThemeEnvironmentModifier: ViewModifier {
    let themeManager: ThemeManager

    public func body(content: Content) -> some View {
        content
            .environmentObject(themeManager)
            .environment(\.themeManager, themeManager)
            .rtlLayout(themeManager.isRTL)
    }
}

public extension View {
    func withThemeManager(_ manager: ThemeManager = ThemeManager.shared) -> some View {
        modifier(ThemeEnvironmentModifier(themeManager: manager))
    }
}

/// SwiftUI Color extension for palette-aware colors
public extension Color {
    /// Primary brand color from current theme
    static var kooiPrimary: Color {
        ThemeManager.shared.activePalette.primary
    }

    /// Primary pressed state
    static var kooiPrimaryPressed: Color {
        ThemeManager.shared.activePalette.primaryPressed
    }

    /// Primary subtle (for chips, badges)
    static var kooiPrimarySubtle: Color {
        ThemeManager.shared.activePalette.primarySubtle
    }

    /// Accent/warm amber
    static var kooiAccent: Color {
        ThemeManager.shared.activePalette.accent
    }

    /// Background
    static var kooiBackground: Color {
        ThemeManager.shared.activePalette.background
    }

    /// Surface (card background)
    static var kooiSurface: Color {
        ThemeManager.shared.activePalette.surface
    }

    /// Surface subtle
    static var kooiSurfaceSubtle: Color {
        ThemeManager.shared.activePalette.surfaceSubtle
    }

    /// Text primary
    static var kooiTextPrimary: Color {
        ThemeManager.shared.activePalette.textPrimary
    }

    /// Text secondary
    static var kooiTextSecondary: Color {
        ThemeManager.shared.activePalette.textSecondary
    }

    /// Text tertiary
    static var kooiTextTertiary: Color {
        ThemeManager.shared.activePalette.textTertiary
    }

    /// Border
    static var kooiBorder: Color {
        ThemeManager.shared.activePalette.border
    }

    /// Border subtle
    static var kooiBorderSubtle: Color {
        ThemeManager.shared.activePalette.borderSubtle
    }

    /// Success
    static var kooiSuccess: Color {
        ThemeManager.shared.activePalette.success
    }

    /// Warning
    static var kooiWarning: Color {
        ThemeManager.shared.activePalette.warning
    }

    /// Error
    static var kooiError: Color {
        ThemeManager.shared.activePalette.error
    }

    /// Info
    static var kooiInfo: Color {
        ThemeManager.shared.activePalette.information
    }

    /// Skeleton base
    static var kooiSkeletonBase: Color {
        ThemeManager.shared.activePalette.skeletonBase
    }

    /// Skeleton highlight
    static var kooiSkeletonHighlight: Color {
        ThemeManager.shared.activePalette.skeletonHighlight
    }

    /// Overlay scrim
    static var kooiOverlayScrim: Color {
        ThemeManager.shared.activePalette.overlayScrim
    }

    /// Text on primary
    static var kooiTextOnPrimary: Color {
        ThemeManager.shared.activePalette.textOnPrimary
    }
}