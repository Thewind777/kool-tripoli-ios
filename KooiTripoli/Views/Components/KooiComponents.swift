import SwiftUI
import CoreHaptics

// MARK: - Common KOOI Components

/// Button styles
struct KooiPrimaryButtonStyle: ButtonStyle {
    @EnvironmentObject private var themeManager: ThemeManager

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(KooiTypography.buttonLarge.font(locale: Locale.current))
            .foregroundColor(themeManager.activePalette.textOnPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                configuration.isPressed ? themeManager.activePalette.primaryPressed : themeManager.activePalette.primary
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: themeManager.activePalette.primary.opacity(configuration.isPressed ? 0.2 : 0.4),
                radius: configuration.isPressed ? 6 : 12,
                x: 0,
                y: configuration.isPressed ? 3 : 6
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct KooiSecondaryButtonStyle: ButtonStyle {
    @EnvironmentObject private var themeManager: ThemeManager

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(KooiTypography.buttonMedium.font(locale: Locale.current))
            .foregroundColor(themeManager.activePalette.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                configuration.isPressed ? themeManager.activePalette.primarySubtle : themeManager.activePalette.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(themeManager.activePalette.primary, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct KooiGhostButtonStyle: ButtonStyle {
    @EnvironmentObject private var themeManager: ThemeManager

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(KooiTypography.buttonMedium.font(locale: Locale.current))
            .foregroundColor(configuration.isPressed ? themeManager.activePalette.textTertiary : themeManager.activePalette.textSecondary)
            .padding(.vertical, 12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Text field style
struct KooiTextFieldStyle: TextFieldStyle {
    @EnvironmentObject private var themeManager: ThemeManager
    @FocusState private var isFocused: Bool

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(KooiTypography.bodyMedium.font(locale: Locale.current))
            .padding(16)
            .background(themeManager.activePalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ? themeManager.activePalette.primary : themeManager.activePalette.borderSubtle,
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .focused($isFocused)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isFocused)
    }
}

/// Card container
struct KooiCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadow: Bool

    @EnvironmentObject private var themeManager: ThemeManager

    init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 16,
        shadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(themeManager.activePalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: shadow ? themeManager.activePalette.overlayScrim : .clear,
                radius: shadow ? 6 : 0,
                x: 0,
                y: shadow ? 3 : 0
            )
    }
}

/// Badge component
struct KooiBadge: View {
    let text: String
    let color: Color
    let icon: String?

    @EnvironmentObject private var themeManager: ThemeManager

    init(text: String, color: Color, icon: String? = nil) {
        self.text = text
        self.color = color
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(KooiTypography.labelSmall.font(locale: Locale.current))
        }
        .foregroundColor(themeManager.activePalette.textOnPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color)
        .clipShape(Capsule())
    }
}

/// Divider with text
struct KooiSectionDivider: View {
    let text: String

    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack {
            Rectangle()
                .fill(themeManager.activePalette.borderSubtle)
                .frame(height: 1)

            Text(text)
                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textTertiary)

            Rectangle()
                .fill(themeManager.activePalette.borderSubtle)
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
}

/// Loading overlay
struct KooiLoadingOverlay: View {
    let message: String?

    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack {
            themeManager.activePalette.overlayScrim
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: themeManager.activePalette.primary))
                    .scaleEffect(1.5)

                if let message = message {
                    Text(message)
                        .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary)
                }
            }
            .padding(32)
            .background(themeManager.activePalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

/// Empty state view
struct KooiEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?

    @EnvironmentObject private var themeManager: ThemeManager

    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(themeManager.activePalette.textTertiary)

            VStack(spacing: 8) {
                Text(title)
                    .font(KooiTypography.headlineMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)

                Text(subtitle)
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(KooiTypography.buttonLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary)
                        .frame(width: 280)
                        .padding(.vertical, 16)
                        .background(themeManager.activePalette.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Discovery Cards

/// Restaurant discovery card for home screen collections
struct RestaurantDiscoveryCard: View {
    let restaurant: Restaurant
    let style: DiscoveryCardStyle

    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: AppCoordinator

    enum DiscoveryCardStyle {
        case standard
        case compact
        case featured
    }

    var body: some View {
        Group {
            switch style {
            case .standard:
                StandardRestaurantCard(restaurant: restaurant)
            case .compact:
                CompactRestaurantCard(restaurant: restaurant)
            case .featured:
                FeaturedRestaurantCard(restaurant: restaurant)
            }
        }
        .onTapGesture {
            coordinator.showRestaurantDetail(restaurant.id)
        }
    }
}

struct StandardRestaurantCard: View {
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image with badges
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        RestaurantImagePlaceholder(artType: restaurant.heroArt)
                    }
                }
                .frame(width: 280, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Badges
                VStack(alignment: .leading, spacing: 8) {
                    if let promoTag = restaurant.promoTagAr ?? restaurant.promoTagEn {
                        PromoBadgeView(text: themeManager.isRTL ? (restaurant.promoTagAr ?? promoTag) : (restaurant.promoTagEn ?? promoTag))
                    }
                    if restaurant.isNew {
                        NewBadgeView()
                    }
                }
                .padding(8)
            }
            .frame(width: 280, height: 160)

            // Info
            RestaurantInfoView(restaurant: restaurant)
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: themeManager.activePalette.overlayScrim, radius: 6, x: 0, y: 3)
        .frame(width: 280)
    }
}

struct CompactRestaurantCard: View {
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    RestaurantImagePlaceholder(artType: restaurant.heroArt)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(themeManager.isRTL ? restaurant.nameAr : restaurant.nameEn)
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(themeManager.activePalette.accent)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(KooiTypography.labelSmall.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textSecondary)
                    }

                    Text("·").foregroundColor(themeManager.activePalette.textTertiary)

                    Text("\(restaurant.deliveryMinutes) \(themeManager.isRTL ? "د" : "min")")
                        .font(KooiTypography.labelSmall.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textTertiary)
                }

                Text(ArabicNumeralFormatter.formatLYD(restaurant.deliveryFeeLyd, isRTL: themeManager.isRTL))
                    .font(KooiTypography.labelMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
            }

            Spacer()
        }
        .padding(12)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct FeaturedRestaurantCard: View {
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: restaurant.coverImageUrl ?? restaurant.imageUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    RestaurantImagePlaceholder(artType: restaurant.heroArt)
                }
            }
            .frame(height: 200)
            .clipped()

            LinearGradient(
                colors: [themeManager.activePalette.background.opacity(0), themeManager.activePalette.background.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 100)

            VStack(alignment: .leading, spacing: 8) {
                Text(themeManager.isRTL ? restaurant.nameAr : restaurant.nameEn)
                    .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary)

                Text(themeManager.isRTL ? restaurant.cuisineAr : restaurant.cuisineEn)
                    .font(KooiTypography.bodyMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textOnPrimary.opacity(0.9))

                HStack(spacing: 16) {
                    Label("\(restaurant.deliveryMinutes) \(themeManager.isRTL ? "د" : "min")", systemImage: "clock.fill")
                    Label(ArabicNumeralFormatter.formatLYD(restaurant.deliveryFeeLyd, isRTL: themeManager.isRTL), systemImage: "bicycle.circle.fill")
                }
                .font(KooiTypography.labelMedium.font(locale: Locale.current))
                .foregroundColor(themeManager.activePalette.textOnPrimary.opacity(0.9))
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: themeManager.activePalette.overlayScrim, radius: 12, x: 0, y: 6)
    }
}

/// QR code and badges components
struct QRCodeView: View {
    let payload: String
    let size: CGFloat

    var body: some View {
        Image(uiImage: generateQRCode(from: payload))
            .interpolation(.none)
            .resizable()
            .frame(width: size, height: size)
    }

    private func generateQRCode(from string: String) -> UIImage {
        let data = string.data(using: .ascii)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        if let outputImage = filter.outputImage {
            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return UIImage(systemName: "qrcode")!
    }
}

struct KOOIBadge: View {
    let type: BadgeType
    let customText: String?

    @EnvironmentObject private var themeManager: ThemeManager

    enum BadgeType {
        case new
        case popular
        case offer
        case delivery
        case pickup
        case loyalty
        case custom
    }

    init(type: BadgeType, customText: String? = nil) {
        self.type = type
        self.customText = customText
    }

    var body: some View {
        Text(displayText)
            .font(KooiTypography.labelSmall.font(locale: Locale.current))
            .foregroundColor(themeManager.activePalette.textOnPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var displayText: String {
        if let custom = customText { return custom }
        switch type {
        case .new: return themeManager.isRTL ? "جديد" : "New"
        case .popular: return themeManager.isRTL ? "شائع" : "Popular"
        case .offer: return themeManager.isRTL ? "عرض" : "Offer"
        case .delivery: return themeManager.isRTL ? "توصيل" : "Delivery"
        case .pickup: return themeManager.isRTL ? "استلام" : "Pickup"
        case .loyalty: return themeManager.isRTL ? "ولاء" : "Loyalty"
        case .custom: return ""
        }
    }

    private var backgroundColor: Color {
        switch type {
        case .new: return themeManager.activePalette.success
        case .popular: return themeManager.activePalette.warning
        case .offer: return themeManager.activePalette.error
        case .delivery: return themeManager.activePalette.primary
        case .pickup: return themeManager.activePalette.accent
        case .loyalty: return themeManager.activePalette.accent
        case .custom: return themeManager.activePalette.primary
        }
    }
}

/// Feature hero showcase
struct FeatureHeroShowcaseView: View {
    let feature: KooiFeatureType
    let action: () -> Void

    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                Image(systemName: heroIcon)
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(themeManager.activePalette.textOnPrimary)
                    .frame(width: 100, height: 100)
                    .background(themeManager.activePalette.primary)
                    .clipShape(Circle())
                    .shadow(color: themeManager.activePalette.primary.opacity(0.3), radius: 16, x: 0, y: 8)

                // Title
                Text(themeManager.isRTL ? feature.heroHeadlineAr : feature.heroHeadlineEn)
                    .font(KooiTypography.headlineLarge.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .multilineTextAlignment(.center)

                // Description
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

                // CTA
                Text(themeManager.isRTL ? feature.heroCtaAr : feature.heroCtaEn)
                    .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.primary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(themeManager.activePalette.textOnPrimary)
                    .clipShape(Capsule())
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [themeManager.activePalette.primary, themeManager.activePalette.primary.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: themeManager.activePalette.primary.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(.plain)
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

/// Haptics controller
@MainActor
public final class HapticsController: ObservableObject {
    public static let shared = HapticsController()

    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?

    private init() {
        prepareEngine()
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()

            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
        } catch {
            print("Haptics engine error: \(error)")
        }
    }

    // MARK: - Public Haptic Methods

    /// Light impact (button tap)
    public func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact (card press)
    public func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact (important action)
    public func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Success notification
    public func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification
    public func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification
    public func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    /// Selection changed
    public func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    /// Custom haptic pattern for envelope opening
    public func envelopeOpen() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }

        do {
            let pattern = try CHHapticPattern(events: [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ], relativeTime: 0),
                CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ], relativeTime: 0.1, duration: 0.5)
            ], parameters: [])

            let player = try engine.makeAdvancedPlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Envelope haptic error: \(error)")
        }
    }

    /// Cart add haptic
    public func cartAdd() {
        mediumImpact()
    }

    /// Cart remove haptic
    public func cartRemove() {
        lightImpact()
    }

    /// Tab switch haptic
    public func tabSwitch() {
        selectionChanged()
    }

    /// Payment success haptic
    public func paymentSuccess() {
        success()
    }

    /// Order placed haptic
    public func orderPlaced() {
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.success()
        }
    }
}