import SwiftUI

/// Envelope onboarding view with full-bleed vector animation
/// Mirrors the Kotlin envelope onboarding animation
struct OnboardingView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                themeManager.activePalette.background
                    .ignoresSafeArea()

                // Envelope Animation
                EnvelopeAnimationView(state: viewModel.envelopeState, progress: viewModel.animationProgress)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()

                // Content (revealed after envelope opens)
                if viewModel.showContent {
                    OnboardingContentView()
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .rtlLayout(themeManager.isRTL)
    }
}

/// Envelope animation with vector graphics
struct EnvelopeAnimationView: View {
    let state: OnboardingViewModel.EnvelopeState
    let progress: Double
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack {
            // Envelope base
            EnvelopeShape(progress: progress)
                .fill(themeManager.activePalette.primary)
                .shadow(
                    color: themeManager.activePalette.overlayScrim,
                    radius: 20 * progress,
                    x: 0,
                    y: 10 * progress
                )

            // Envelope flap
            EnvelopeFlapShape(progress: progress)
                .fill(themeManager.activePalette.primaryPressed)
                .shadow(
                    color: themeManager.activePalette.overlayScrim,
                    radius: 10 * progress,
                    x: 0,
                    y: -5 * progress
                )

            // Decorative elements
            if progress > 0.3 {
                KOOILogoMark(progress: progress)
            }

            // Sparkle particles during opening
            if case .opening = state, progress < 1.0 {
                SparkleParticles(progress: progress)
            }
        }
        .scaleEffect(state == .completed ? 1.1 : 1.0)
        .opacity(state == .completed ? 0 : 1)
    }
}

/// Envelope base shape
struct EnvelopeShape: Shape {
    let progress: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let cornerRadius: CGFloat = 24

        // Envelope opens from center
        let openHeight = height * 0.6 * progress
        let topY = (height - openHeight) / 2

        // Main envelope body
        path.move(to: CGPoint(x: cornerRadius, y: topY))
        path.addLine(to: CGPoint(x: width - cornerRadius, y: topY))
        path.addQuadCurve(
            to: CGPoint(x: width - cornerRadius, y: topY + openHeight),
            control: CGPoint(x: width, y: topY + openHeight / 2)
        )
        path.addLine(to: CGPoint(x: cornerRadius, y: topY + openHeight))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: topY),
            control: CGPoint(x: 0, y: topY + openHeight / 2)
        )
        path.closeSubpath()

        return path
    }
}

/// Envelope flap shape
struct EnvelopeFlapShape: Shape {
    let progress: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let flapHeight = height * 0.4
        let openHeight = height * 0.6 * progress
        let topY = (height - openHeight) / 2

        // Flap rotates down as envelope opens
        let flapAngle = -progress * .pi / 2 // 0 to -90 degrees
        let flapCenterY = topY - flapHeight / 2

        path.move(to: CGPoint(x: 0, y: topY))
        path.addLine(to: CGPoint(x: width, y: topY))

        // Flap triangle
        let flapTipX = width / 2
        let flapTipY = topY - flapHeight * progress

        path.addLine(to: CGPoint(x: flapTipX, y: flapTipY))
        path.closeSubpath()

        return path
    }
}

/// KOOI logo mark with animation
struct KOOILogoMark: View {
    let progress: Double
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 8) {
            // Envelope icon
            Image(systemName: "envelope.fill")
                .font(.system(size: 60 * progress, weight: .medium))
                .foregroundColor(themeManager.activePalette.textOnPrimary)
                .scaleEffect(progress)
                .rotationEffect(.degrees(360 * (progress - 1)))

            // App name
            Text("KOOI")
                .font(.system(size: 32 * progress, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.activePalette.textOnPrimary)
                .opacity(progress > 0.5 ? (progress - 0.5) * 2 : 0)

            // Tagline
            Text("طرابلس في جيبك")
                .font(.system(size: 16 * progress, weight: .medium))
                .foregroundColor(themeManager.activePalette.textOnPrimary.opacity(0.9))
                .opacity(progress > 0.7 ? (progress - 0.7) * 3.33 : 0)
        }
    }
}

/// Sparkle particles during envelope opening
struct SparkleParticles: View {
    let progress: Double
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack {
            ForEach(0..<12) { index in
                SparkleParticle(
                    index: index,
                    progress: progress,
                    color: themeManager.activePalette.textOnPrimary
                )
            }
        }
    }
}

struct SparkleParticle: View {
    let index: Int
    let progress: Double
    let color: Color

    private var delay: Double {
        Double(index) * 0.05
    }

    private var angle: Double {
        Double(index) * 30.0 // 12 particles = 30 degrees each
    }

    private var distance: CGFloat {
        120 * progress
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .opacity(max(0, 1 - progress * 1.5))
            .offset(
                x: cos(angle * .pi / 180) * distance,
                y: sin(angle * .pi / 180) * distance
            )
            .scaleEffect(progress)
            .animation(
                .easeOut(duration: 1.0).delay(delay),
                value: progress
            )
    }
}

/// Onboarding content pages
struct OnboardingContentView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        TabView(selection: $viewModel.currentStep) {
            ForEach(viewModel.steps) { step in
                OnboardingStepView(step: step)
                    .tag(step.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            VStack(spacing: 16) {
                // Skip button
                if viewModel.currentStep < viewModel.steps.count - 1 {
                    Button(action: { viewModel.skipOnboarding() }) {
                        Text(themeManager.isRTL ? "تخطي" : "Skip")
                            .font(KooiTypography.buttonMedium.font(locale: Locale.current))
                            .foregroundColor(themeManager.activePalette.textSecondary)
                    }
                }

                // Next/Get Started button
                Button(action: {
                    if viewModel.currentStep < viewModel.steps.count - 1 {
                        viewModel.nextStep()
                    } else {
                        viewModel.completeOnboarding()
                    }
                }) {
                    Text(viewModel.currentStep < viewModel.steps.count - 1
                         ? (themeManager.isRTL ? "التالي" : "Next")
                         : (themeManager.isRTL ? "ابدأ الآن" : "Get Started"))
                        .font(KooiTypography.buttonLarge.font(locale: Locale.current))
                        .foregroundColor(themeManager.activePalette.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeManager.activePalette.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
            }
            .padding(.bottom, 50)
        }
    }
}

/// Individual onboarding step view
struct OnboardingStepView: View {
    let step: OnboardingStep
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Illustration
            ZStack {
                Circle()
                    .fill(themeManager.activePalette.primarySubtle)
                    .frame(width: 200, height: 200)

                Image(systemName: stepImageName)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(themeManager.activePalette.primary)
            }

            // Content
            VStack(spacing: 16) {
                Text(themeManager.isRTL ? step.titleAr : step.titleEn)
                    .font(KooiTypography.displayMedium.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textPrimary)
                    .multilineTextAlignment(.center)

                Text(themeManager.isRTL ? step.descriptionAr : step.descriptionEn)
                    .font(KooiTypography.bodyLarge.font(locale: Locale.current))
                    .foregroundColor(themeManager.activePalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .padding()
    }

    private var stepImageName: String {
        switch step.id {
        case 0: return "envelope.fill"
        case 1: return "map.fill"
        case 2: return "cart.fill.badge.plus"
        case 3: return "calendar.badge.clock"
        case 4: return "seal.fill"
        default: return "star.fill"
        }
    }
}