import SwiftUI

/// KOOI Typography System
/// Ports the Compose `KooiTypography` with Tajawal (Arabic) and Plus Jakarta Sans (Latin) fonts.
/// Full RTL support for Arabic text alignment.
public struct KooiTypography {
    // Font family names - these should be added to the Xcode project as custom fonts
    public static let arabicFontFamily = "Tajawal"
    public static let latinFontFamily = "PlusJakartaSans"

    // Font weights available in Tajawal/Plus Jakarta Sans
    public enum Weight: String, CaseIterable {
        case light = "Light"
        case regular = "Regular"
        case medium = "Medium"
        case semiBold = "SemiBold"
        case bold = "Bold"
        case extraBold = "ExtraBold"
    }

    /// Returns the appropriate font family for the given locale/language
    public static func fontFamily(for locale: Locale = Locale.current) -> String {
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        return languageCode == "ar" ? arabicFontFamily : latinFontFamily
    }

    /// Creates a font with the correct family for the current locale
    public static func font(
        _ style: Font.TextStyle,
        weight: Weight = .regular,
        locale: Locale = Locale.current
    ) -> Font {
        let family = fontFamily(for: locale)
        let fontName = "\(family)-\(weight.rawValue)"
        return Font.custom(fontName, size: style.size, relativeTo: style)
            .weight(swiftUIWeight(weight))
    }

    /// Creates a font with explicit size
    public static func font(
        size: CGFloat,
        weight: Weight = .regular,
        locale: Locale = Locale.current
    ) -> Font {
        let family = fontFamily(for: locale)
        let fontName = "\(family)-\(weight.rawValue)"
        return Font.custom(fontName, size: size)
            .weight(swiftUIWeight(weight))
    }

    private static func swiftUIWeight(_ weight: Weight) -> Font.Weight {
        switch weight {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semiBold: return .semibold
        case .bold: return .bold
        case .extraBold: return .heavy
        }
    }
}

/// Semantic text styles matching the Compose design system
public extension KooiTypography {
    // Display / Hero
    static let displayLarge = FontStyle(size: 36, weight: .bold, lineHeight: 44)
    static let displayMedium = FontStyle(size: 28, weight: .bold, lineHeight: 36)
    static let displaySmall = FontStyle(size: 24, weight: .bold, lineHeight: 32)

    // Headlines
    static let headlineLarge = FontStyle(size: 22, weight: .semiBold, lineHeight: 28)
    static let headlineMedium = FontStyle(size: 20, weight: .semiBold, lineHeight: 26)
    static let headlineSmall = FontStyle(size: 18, weight: .semiBold, lineHeight: 24)

    // Titles
    static let titleLarge = FontStyle(size: 16, weight: .semiBold, lineHeight: 22)
    static let titleMedium = FontStyle(size: 14, weight: .semiBold, lineHeight: 20)
    static let titleSmall = FontStyle(size: 12, weight: .medium, lineHeight: 16)

    // Body
    static let bodyLarge = FontStyle(size: 16, weight: .regular, lineHeight: 24)
    static let bodyMedium = FontStyle(size: 14, weight: .regular, lineHeight: 20)
    static let bodySmall = FontStyle(size: 12, weight: .regular, lineHeight: 16)

    // Labels / UI
    static let labelLarge = FontStyle(size: 14, weight: .medium, lineHeight: 20)
    static let labelMedium = FontStyle(size: 12, weight: .medium, lineHeight: 16)
    static let labelSmall = FontStyle(size: 11, weight: .medium, lineHeight: 14)

    // Special: Arabic numerals
    static let arabicNumerals = FontStyle(size: 16, weight: .medium, lineHeight: 22)

    // Button
    static let buttonLarge = FontStyle(size: 16, weight: .semiBold, lineHeight: 22)
    static let buttonMedium = FontStyle(size: 14, weight: .semiBold, lineHeight: 20)
    static let buttonSmall = FontStyle(size: 12, weight: .medium, lineHeight: 16)

    // Caption / Overline
    static let caption = FontStyle(size: 11, weight: .regular, lineHeight: 14)
    static let overline = FontStyle(size: 10, weight: .medium, lineHeight: 12, uppercase: true)
}

/// Font style descriptor for consistent typography
public struct FontStyle {
    public let size: CGFloat
    public let weight: KooiTypography.Weight
    public let lineHeight: CGFloat
    public let uppercase: Bool

    public init(size: CGFloat, weight: KooiTypography.Weight, lineHeight: CGFloat, uppercase: Bool = false) {
        self.size = size
        self.weight = weight
        self.lineHeight = lineHeight
        self.uppercase = uppercase
    }

    /// Creates a SwiftUI Font from this style for the current locale
    public func font(locale: Locale = Locale.current) -> Font {
        KooiTypography.font(size: size, weight: weight, locale: locale)
    }

    /// Creates a Text view with this style applied
    public func apply(to text: String, locale: Locale = Locale.current) -> Text {
        var result = Text(text.uppercased() ? text.uppercased() : text)
            .font(font(locale: locale))
            .lineSpacing(lineHeight - size)
        if uppercase {
            result = Text(text.uppercased())
                .font(font(locale: locale))
                .lineSpacing(lineHeight - size)
        }
        return result
    }
}

/// RTL-aware text alignment
public extension TextAlignment {
    static func rtlAware(for locale: Locale = Locale.current) -> TextAlignment {
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        return languageCode == "ar" ? .trailing : .leading
    }
}

/// Environment key for RTL layout direction
private struct RTLLayoutKey: EnvironmentKey {
    static let defaultValue: Bool = Locale.current.language.languageCode?.identifier == "ar"
}

public extension EnvironmentValues {
    var isRTL: Bool {
        get { self[RTLLayoutKey.self] }
        set { self[RTLLayoutKey.self] = newValue }
    }
}

/// View modifier to enforce RTL layout direction globally
public struct RTLLayoutModifier: ViewModifier {
    let isRTL: Bool

    public func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
            .environment(\.isRTL, isRTL)
    }
}

public extension View {
    /// Applies RTL layout direction for Arabic locale
    func rtlLayout(_ isRTL: Bool = Locale.current.language.languageCode?.identifier == "ar") -> some View {
        modifier(RTLLayoutModifier(isRTL: isRTL))
    }
}

/// Arabic numeral formatter matching the Kotlin `ArabicNumeralFormatter`
public struct ArabicNumeralFormatter {
    private static let arabicDigits: [Character] = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
    private static let arabicDecimalSeparator: Character = "٫"

    public static func toArabicDigits(_ input: String) -> String {
        var result = ""
        for ch in input {
            if ch.isNumber, let digit = ch.wholeNumberValue {
                result.append(arabicDigits[digit])
            } else if ch == "." {
                result.append(arabicDecimalSeparator)
            } else {
                result.append(ch)
            }
        }
        return result
    }

    public static func formatInt(_ value: Int, useArabicNumerals: Bool) -> String {
        useArabicNumerals ? toArabicDigits(String(value)) : String(value)
    }

    public static func formatDecimal(_ value: Double, useArabicNumerals: Bool, fractionDigits: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let raw = formatter.string(from: NSNumber(value: value)) ?? String(value)
        return useArabicNumerals ? toArabicDigits(raw) : raw
    }

    public static func formatRating(_ rating: Double, useArabicNumerals: Bool) -> String {
        formatDecimal(rating, useArabicNumerals: useArabicNumerals)
    }

    public static func formatDistanceKm(_ km: Double, isRTL: Bool) -> String {
        let formatted = formatDecimal(km, useArabicNumerals: isRTL)
        return isRTL ? "\(formatted) كم" : "\(formatted) km"
    }

    public static func formatLYD(_ amount: Int, isRTL: Bool) -> String {
        if isRTL {
            return "\(toArabicDigits(String(amount))) د.ل"
        } else {
            return "\(amount) LYD"
        }
    }
}