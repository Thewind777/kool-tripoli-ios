import SwiftUI
import SwiftData

/// Main App entry point
@main
struct KooiApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var cartStore = LocalCartStore.shared
    @StateObject private var restaurantsVM = RestaurantsViewModel()
    @StateObject private var cartVM = CartViewModel()
    @StateObject private var onboardingVM = OnboardingViewModel()
    @StateObject private var apiClient = APIClient.shared

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environmentObject(themeManager)
                .environmentObject(cartStore)
                .environmentObject(restaurantsVM)
                .environmentObject(cartVM)
                .environmentObject(onboardingVM)
                .environmentObject(apiClient)
                .withThemeManager(themeManager)
                .rtlLayout(themeManager.isRTL)
                .modelContainer(cartStore.modelContainer)
                .onOpenURL { url in
                    NotificationCenter.default.post(name: .deepLinkReceived, object: url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    if let url = userActivity.webpageURL {
                        NotificationCenter.default.post(name: .deepLinkReceived, object: url)
                    }
                }
        }
    }
}

/// Scene delegate for handling deep links
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            handleDeepLink(url)
        }

        if let urlContext = connectionOptions.urlContexts.first {
            handleDeepLink(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            handleDeepLink(url)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            handleDeepLink(url)
        }
    }

    private func handleDeepLink(_ url: URL) {
        NotificationCenter.default.post(name: .deepLinkReceived, object: url)
    }
}

extension Notification.Name {
    static let deepLinkReceived = Notification.Name("deepLinkReceived")
}
