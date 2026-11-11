import Foundation
import Combine
import SwiftUI

/// ViewModel for envelope onboarding with transition states
/// Mirrors the Kotlin onboarding envelope animation states
@MainActor
public final class OnboardingViewModel: ObservableObject {
    // MARK: - Envelope States

    public enum EnvelopeState: Equatable {
        case closed
        case opening(progress: Double) // 0.0 to 1.0
        case open
        case revealingContent(progress: Double) // 0.0 to 1.0
        case completed
        case skipped
    }

    // MARK: - Published State

    @Published public var envelopeState: EnvelopeState = .closed
    @Published public var animationProgress: Double = 0.0
    @Published public var showContent: Bool = false
    @Published public var currentStep: Int = 0
    @Published public var isAnimating: Bool = false

    // Onboarding steps
    public let steps: [OnboardingStep] = [
        OnboardingStep(
            id: 0,
            titleAr: "مرحباً بك في كوي",
            titleEn: "Welcome to KOOI",
            descriptionAr: "تطبيق التوصيل الأول في طرابلس بميزات ذكية وحصرية",
            descriptionEn: "Tripoli's first delivery app with smart & exclusive features",
            imageName: "envelope_step_1"
        ),
        OnboardingStep(
            id: 1,
            titleAr: "طلب شارع MR",
            titleEn: "MR Street Order",
            descriptionAr: "اختر عدة مطاعم في نفس الشارع بقائمة وسلة موحدة",
            descriptionEn: "Combine multiple spots on one street in a unified menu & cart",
            imageName: "envelope_step_2"
        ),
        OnboardingStep(
            id: 2,
            titleAr: "سلة جماعية",
            titleEn: "Group Cart",
            descriptionAr: "ادفع للجميع أو يقسم كل مشارك حصته بسهولة",
            descriptionEn: "Pay for everyone or let each friend pay their own share",
            imageName: "envelope_step_3"
        ),
        OnboardingStep(
            id: 3,
            titleAr: "حجز طلب",
            titleEn: "Book Order",
            descriptionAr: "جدول موعد وجبتك مسبقاً واستفد من خصم خارج الذروة",
            descriptionEn: "Pre-book your slot & unlock off-peak scheduled savings",
            imageName: "envelope_step_4"
        ),
        OnboardingStep(
            id: 4,
            titleAr: "ولاء كوي",
            titleEn: "KOOI Loyalty",
            descriptionAr: "مكافآت عضوية كوي + بطاقات أختام المطاعم المستقلة",
            descriptionEn: "KOOI Circle perks + independent restaurant stamp rewards",
            imageName: "envelope_step_5"
        )
    ]

    private var animationTimer: Timer?
    private let animationDuration: Double = 1.5

    public init() {}

    // MARK: - Public Methods

    public func startOnboarding() {
        guard envelopeState == .closed else { return }
        animateEnvelopeOpening()
    }

    public func skipOnboarding() {
        stopAnimations()
        envelopeState = .skipped
        showContent = true
    }

    public func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            completeOnboarding()
        }
    }

    public func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    private func animateEnvelopeOpening() {
        isAnimating = true
        envelopeState = .opening(progress: 0.0)

        let startTime = Date()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / self.animationDuration, 1.0)

            Task { @MainActor in
                self.animationProgress = progress
                self.envelopeState = .opening(progress: progress)

                if progress >= 1.0 {
                    timer.invalidate()
                    self.envelopeState = .open
                    self.animateContentReveal()
                }
            }
        }
    }

    private func animateContentReveal() {
        let startTime = Date()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / 0.8, 1.0)

            Task { @MainActor in
                self.animationProgress = progress
                self.envelopeState = .revealingContent(progress: progress)

                if progress >= 1.0 {
                    timer.invalidate()
                    self.showContent = true
                    self.envelopeState = .completed
                    self.isAnimating = false
                }
            }
        }
    }

    private func completeOnboarding() {
        stopAnimations()
        envelopeState = .completed
        showContent = true
        // Mark onboarding as completed in user defaults
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
    }

    private func stopAnimations() {
        animationTimer?.invalidate()
        animationTimer = nil
        isAnimating = false
    }

    public static func hasCompletedOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: "onboardingCompleted")
    }

    public static func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "onboardingCompleted")
    }
}

/// Onboarding step model
public struct OnboardingStep: Identifiable {
    public let id: Int
    public let titleAr: String
    public let titleEn: String
    public let descriptionAr: String
    public let descriptionEn: String
    public let imageName: String

    public init(id: Int, titleAr: String, titleEn: String, descriptionAr: String, descriptionEn: String, imageName: String) {
        self.id = id
        self.titleAr = titleAr
        self.titleEn = titleEn
        self.descriptionAr = descriptionAr
        self.descriptionEn = descriptionEn
        self.imageName = imageName
    }
}