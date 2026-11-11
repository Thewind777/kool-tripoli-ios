import SwiftUI

/// Raw color primitives extracted from the approved KOOI Home screen identity:
/// Warm Premium Minimalism with Subtle Playfulness.
/// Dark brown (#2A1810) / Orange (#FF6B00) theme tokens.
public struct KooiColorPrimitives {
    // Base Neutrals
    public static let pureWhite = Color(hex: 0xFFFFFFFF)
    public static let warmAlabaster = Color(hex: 0xFFFCFAF8)
    public static let warmSubtleSand = Color(hex: 0xFFF7F3EE)
    public static let deepEspresso = Color(hex: 0xFF1E1511)
    public static let roastedEspresso = Color(hex: 0xFF23130C)
    public static let darkRoastBubble = Color(hex: 0xFF1C100B)

    // Primary Brand - KOOI Orange
    public static let kooiOrange = Color(hex: 0xFFD14A17)
    public static let kooiOrangePressed = Color(hex: 0xFFB83D12)
    public static let kooiOrangeSubtle = Color(hex: 0xFFFFEFE7)
    public static let warmAmber = Color(hex: 0xFFF59E0B)
    public static let starGold = Color(hex: 0xFFFBBF24)

    // Typography
    public static let inkPrimary = Color(hex: 0xFF1E1511)
    public static let inkSecondary = Color(hex: 0xFF4A3E37)
    public static let inkTertiary = Color(hex: 0xFF6E5E56)

    // Borders & Dividers
    public static let borderWarm = Color(hex: 0xFFD4C9C0)
    public static let borderSubtle = Color(hex: 0xFFE0D8D1)
    public static let dividerWarm = Color(hex: 0xFFE8E0D9)

    // Semantic States
    public static let emeraldSuccess = Color(hex: 0xFF15803D)
    public static let emeraldSuccessSubtle = Color(hex: 0xFFECFDF5)
    public static let amberWarning = Color(hex: 0xFFD97706)
    public static let amberWarningSubtle = Color(hex: 0xFFFFFBEB)
    public static let crimsonError = Color(hex: 0xFFDC2626)
    public static let crimsonErrorSubtle = Color(hex: 0xFFFEF2F2)
    public static let medBlueInfo = Color(hex: 0xFF0369A1)
    public static let medBlueInfoSubtle = Color(hex: 0xFFF0F9FF)

    // Accessibility-specific (WCAG 2.2 AA compliant)
    public static let textOnPrimary = Color(hex: 0xFFFFFFFF)
    public static let textOnPrimaryDisabled = Color(hex: 0xCCFFFFFF)
    public static let textDisabled = Color(hex: 0xFF8A7D75)
    public static let backgroundDisabled = Color(hex: 0xFFE8E0D9)
    public static let surfaceDisabled = Color(hex: 0xFFF3EDE7)
    public static let borderDisabled = Color(hex: 0xFFD4C9C0)

    // Skeleton / Shimmer
    public static let skeletonBase = Color(hex: 0xFFE8E8E8)
    public static let skeletonHighlight = Color(hex: 0xFFF5F5F5)
}

/// Semantic palette tokens consumed by UI components.
/// Mirrors `KooiPalette` from the Compose design system.
public struct KooiPalette {
    // Core surfaces
    public let background: Color
    public let surface: Color
    public let surfaceSubtle: Color
    public let surfaceInverse: Color

    // Brand
    public let primary: Color          // KOOI Orange
    public let primaryPressed: Color
    public let primarySubtle: Color    // Orange tint for chips/badges
    public let accent: Color           // Warm Amber for secondary actions
    public let warning: Color
    public let information: Color
    public let error: Color

    // Text
    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color
    public let textOnPrimary: Color
    public let textInverse: Color
    public let textDisabled: Color

    // Borders
    public let border: Color
    public let borderSubtle: Color

    // State containers
    public let success: Color
    public let successSubtle: Color
    public let warningSubtle: Color
    public let errorSubtle: Color
    public let infoSubtle: Color

    // Overlays
    public let overlayScrim: Color

    // Restaurant info bubble alpha (0.25 – 0.98)
    public let restaurantInfoBubbleAlpha: Double
    // Hero promo bubble alphas
    public let promoTopLeftAlpha: Double
    public let promoMidAlpha: Double
    public let promoBottomRightAlpha: Double

    // Skeleton
    public let skeletonBase: Color
    public let skeletonHighlight: Color

    public init(
        background: Color = KooiColorPrimitives.warmAlabaster,
        surface: Color = KooiColorPrimitives.pureWhite,
        surfaceSubtle: Color = KooiColorPrimitives.warmSubtleSand,
        surfaceInverse: Color = KooiColorPrimitives.deepEspresso,
        primary: Color = KooiColorPrimitives.kooiOrange,
        primaryPressed: Color = KooiColorPrimitives.kooiOrangePressed,
        primarySubtle: Color = KooiColorPrimitives.kooiOrangeSubtle,
        accent: Color = KooiColorPrimitives.warmAmber,
        warning: Color = KooiColorPrimitives.amberWarning,
        information: Color = KooiColorPrimitives.medBlueInfo,
        error: Color = KooiColorPrimitives.crimsonError,
        textPrimary: Color = KooiColorPrimitives.inkPrimary,
        textSecondary: Color = KooiColorPrimitives.inkSecondary,
        textTertiary: Color = KooiColorPrimitives.inkTertiary,
        textOnPrimary: Color = KooiColorPrimitives.textOnPrimary,
        textInverse: Color = KooiColorPrimitives.warmAlabaster,
        textDisabled: Color = KooiColorPrimitives.textDisabled,
        border: Color = KooiColorPrimitives.borderWarm,
        borderSubtle: Color = KooiColorPrimitives.borderSubtle,
        success: Color = KooiColorPrimitives.emeraldSuccess,
        successSubtle: Color = KooiColorPrimitives.emeraldSuccessSubtle,
        warningSubtle: Color = KooiColorPrimitives.amberWarningSubtle,
        errorSubtle: Color = KooiColorPrimitives.crimsonErrorSubtle,
        infoSubtle: Color = KooiColorPrimitives.medBlueInfoSubtle,
        overlayScrim: Color = Color.black.opacity(0.45),
        restaurantInfoBubbleAlpha: Double = 0.85,
        promoTopLeftAlpha: Double = 0.77,
        promoMidAlpha: Double = 0.75,
        promoBottomRightAlpha: Double = 0.98,
        skeletonBase: Color = KooiColorPrimitives.skeletonBase,
        skeletonHighlight: Color = KooiColorPrimitives.skeletonHighlight
    ) {
        self.background = background
        self.surface = surface
        self.surfaceSubtle = surfaceSubtle
        self.surfaceInverse = surfaceInverse
        self.primary = primary
        self.primaryPressed = primaryPressed
        self.primarySubtle = primarySubtle
        self.accent = accent
        self.warning = warning
        self.information = information
        self.error = error
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textOnPrimary = textOnPrimary
        self.textInverse = textInverse
        self.textDisabled = textDisabled
        self.border = border
        self.borderSubtle = borderSubtle
        self.success = success
        self.successSubtle = successSubtle
        self.warningSubtle = warningSubtle
        self.errorSubtle = errorSubtle
        self.infoSubtle = infoSubtle
        self.overlayScrim = overlayScrim
        self.restaurantInfoBubbleAlpha = restaurantInfoBubbleAlpha
        self.promoTopLeftAlpha = promoTopLeftAlpha
        self.promoMidAlpha = promoMidAlpha
        self.promoBottomRightAlpha = promoBottomRightAlpha
        self.skeletonBase = skeletonBase
        self.skeletonHighlight = skeletonHighlight
    }
}

/// Preset palettes matching the Compose `KooiColorPresets`.
public enum KooiColorPresets {
    /// Default KOOI Sunset Orange — warm premium minimalism
    public static let kooiSunsetOrange = KooiPalette()

    /// Ramadan Kareem — deeper espresso with gold accent
    public static let ramadanKareem = KooiPalette(
        background: KooiColorPrimitives.darkRoastBubble,
        surface: KooiColorPrimitives.roastedEspresso,
        surfaceSubtle: Color(hex: 0xFF2D1A0F),
        surfaceInverse: KooiColorPrimitives.warmAlabaster,
        primary: KooiColorPrimitives.starGold,
        primaryPressed: Color(hex: 0xFFE6A800),
        primarySubtle: Color(hex: 0xFFFFF3D4),
        accent: KooiColorPrimitives.kooiOrange,
        textPrimary: KooiColorPrimitives.warmAlabaster,
        textSecondary: Color(hex: 0xFFD4C4B0),
        textTertiary: Color(hex: 0xFF9A8A7A),
        textInverse: KooiColorPrimitives.deepEspresso,
        border: Color(hex: 0xFF4A3520),
        borderSubtle: Color(hex: 0xFF3A2A18),
        overlayScrim: Color.black.opacity(0.65),
        restaurantInfoBubbleAlpha: 0.92,
        promoTopLeftAlpha: 0.85,
        promoMidAlpha: 0.82,
        promoBottomRightAlpha: 0.99
    )

    /// High Contrast Accessibility
    public static let highContrast = KooiPalette(
        background: Color.white,
        surface: Color.white,
        surfaceSubtle: Color(hex: 0xFFF0F0F0),
        surfaceInverse: Color.black,
        primary: Color(hex: 0xFFB83D12),
        primaryPressed: Color(hex: 0xFF9A2F0E),
        primarySubtle: Color(hex: 0xFFFFE8E0),
        accent: Color(hex: 0xFFCC7700),
        textPrimary: Color.black,
        textSecondary: Color(hex: 0xFF333333),
        textTertiary: Color(hex: 0xFF555555),
        textInverse: Color.white,
        border: Color(hex: 0xFF999999),
        borderSubtle: Color(hex: 0xFFCCCCCC)
    )
}

private extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 24) & 0xFF) / 255.0
        let g = Double((hex >> 16) & 0xFF) / 255.0
        let b = Double((hex >> 8) & 0xFF) / 255.0
        let a = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}