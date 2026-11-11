import SwiftUI
import WebKit

/// Payment WebView for handling online payment gateways
/// Mirrors the Kotlin `PaymentWebviewActivity` which loads a custom payment gateway URL
/// and handles success/failure callbacks via URL patterns
public struct PaymentWebView: UIViewRepresentable {
    public let url: URL
    public let onSuccess: () -> Void
    public let onFailure: (String) -> Void
    public let onCancel: () -> Void
    public let hideElements: [String] // JavaScript to hide specific elements

    @Environment(\.dismiss) private var dismiss

    public init(
        url: URL,
        hideElements: [String] = [],
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.url = url
        self.hideElements = hideElements
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.onCancel = onCancel
    }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        // Load the payment URL
        webView.load(URLRequest(url: url))

        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        let parent: PaymentWebView
        private var failingUrl: String = ""
        private var hasFinishedLoading = false

        init(_ parent: PaymentWebView) {
            self.parent = parent
        }

        // MARK: - WKNavigationDelegate

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            hasFinishedLoading = false
            failingUrl = webView.url?.absoluteString ?? ""
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            hasFinishedLoading = true

            // Inject JavaScript to hide elements (matching original app's HideHTMLTag)
            if !parent.hideElements.isEmpty {
                let userName = UserDefaults.standard.string(forKey: "userName") ?? ""
                let userPhone = UserDefaults.standard.string(forKey: "userPhone") ?? ""
                let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""

                for script in parent.hideElements {
                    let modifiedScript = script
                        .replacingOccurrences(of: "#USER_NAME#", with: userName)
                        .replacingOccurrences(of: "#USER_PHONE#", with: userPhone)
                        .replacingOccurrences(of: "#USER_EMAIL#", with: userEmail)
                    webView.evaluateJavaScript(modifiedScript, completionHandler: nil)
                }
            }
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handleError(error, webView: webView)
        }

        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handleError(error, webView: webView)
        }

        private func handleError(_ error: Error, webView: WKWebView) {
            // Show error state - could be enhanced with a retry mechanism
            print("PaymentWebView error: \(error.localizedDescription)")
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let urlString = url.absoluteString
            failingUrl = urlString

            // Check for success/failure patterns (matching original app's URL patterns)
            if urlString.contains("success=1") || urlString.contains("result.php?success=1") || urlString.contains("gift_action=success") {
                decisionHandler(.cancel)
                DispatchQueue.main.async {
                    self.parent.onSuccess()
                    self.parent.dismiss()
                }
                return
            }

            if urlString.contains("OPEN_IN_APP_WALLET=Yes") {
                decisionHandler(.cancel)
                DispatchQueue.main.async {
                    // Navigate to wallet screen
                    NotificationCenter.default.post(name: .navigateToWallet, object: nil)
                    self.parent.dismiss()
                }
                return
            }

            if urlString.contains("BUSINESS_PROFILE_SETUP=Yes") {
                decisionHandler(.cancel)
                DispatchQueue.main.async {
                    self.parent.dismiss()
                }
                return
            }

            // Allow all other navigation
            decisionHandler(.allow)
        }

        // MARK: - WKUIDelegate

        public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            // Handle JavaScript alerts
            completionHandler()
        }

        public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            // Handle JavaScript confirms (e.g., "Cancel payment process?")
            if message.contains("cancel") || message.contains("CANCEL") {
                completionHandler(true)
                DispatchQueue.main.async {
                    self.parent.onCancel()
                    self.parent.dismiss()
                }
            } else {
                completionHandler(false)
            }
        }

        public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            // Handle JavaScript prompts
            completionHandler(defaultText)
        }

        // MARK: - WKScriptMessageHandler

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Handle messages from JavaScript if needed
        }
    }
}

/// SwiftUI wrapper for presenting PaymentWebView as a sheet
public struct PaymentWebViewSheet: View {
    let url: URL
    let hideElements: [String]
    let onSuccess: () -> Void
    let onFailure: (String) -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    public init(
        url: URL,
        hideElements: [String] = [],
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.url = url
        self.hideElements = hideElements
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationStack {
            PaymentWebView(
                url: url,
                hideElements: hideElements,
                onSuccess: onSuccess,
                onFailure: onFailure,
                onCancel: onCancel
            )
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToWallet = Notification.Name("navigateToWallet")
}

// MARK: - Preview

#Preview {
    PaymentWebViewSheet(
        url: URL(string: "https://example.com/payment")!,
        onSuccess: { print("Payment success") },
        onFailure: { print("Payment failed: \($0)") },
        onCancel: { print("Payment cancelled") }
    )
}
