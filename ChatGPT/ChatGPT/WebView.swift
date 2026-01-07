import SwiftUI
import WebKit

// MARK: - WebView
struct WebView: NSViewRepresentable {
    let url: URL
    @ObservedObject var viewModel: WebViewModel
    @Binding var isLoading: Bool
    @Binding var loadingProgress: Double
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // Enable JavaScript
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        // Configure web view settings
        let webpagePreferences = WKWebpagePreferences()
        webpagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = webpagePreferences
        
        // Enable local storage
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        // User agent for better compatibility
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsMagnification = true
        
        // Set background color
        webView.setValue(false, forKey: "drawsBackground")
        
        // Observe loading progress
        context.coordinator.webView = webView
        context.coordinator.setupObservers()
        
        // Store reference in view model
        viewModel.webView = webView
        
        // Restore cookies
        CookieManager.shared.restoreCookies(to: webView)
        
        // Load the URL
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webView.load(request)
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Updates handled by coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        weak var webView: WKWebView?
        private var progressObserver: NSKeyValueObservation?
        private var canGoBackObserver: NSKeyValueObservation?
        private var canGoForwardObserver: NSKeyValueObservation?
        private var urlObserver: NSKeyValueObservation?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func setupObservers() {
            guard let webView = webView else { return }
            
            progressObserver = webView.observe(\.estimatedProgress) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.loadingProgress = webView.estimatedProgress
                }
            }
            
            canGoBackObserver = webView.observe(\.canGoBack) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.viewModel.canGoBack = webView.canGoBack
                }
            }
            
            canGoForwardObserver = webView.observe(\.canGoForward) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.viewModel.canGoForward = webView.canGoForward
                }
            }
            
            urlObserver = webView.observe(\.url) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.viewModel.currentURL = webView.url?.absoluteString ?? ""
                }
            }
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.showError = false
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadingProgress = 1.0
                
                // Save cookies after page loads
                CookieManager.shared.saveCookies()
            }
            
            // Inject custom CSS for better dark mode integration
            let css = """
                ::-webkit-scrollbar {
                    width: 8px;
                }
                ::-webkit-scrollbar-track {
                    background: transparent;
                }
                ::-webkit-scrollbar-thumb {
                    background: rgba(255, 255, 255, 0.2);
                    border-radius: 4px;
                }
                ::-webkit-scrollbar-thumb:hover {
                    background: rgba(255, 255, 255, 0.3);
                }
            """
            
            let js = """
                var style = document.createElement('style');
                style.innerHTML = `\(css)`;
                document.head.appendChild(style);
            """
            
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handleError(error)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handleError(error)
        }
        
        private func handleError(_ error: Error) {
            let nsError = error as NSError
            
            // Ignore cancelled navigation errors
            if nsError.code == NSURLErrorCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.showError = true
                self.parent.errorMessage = error.localizedDescription
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            // Allow ChatGPT and OpenAI domains
            let allowedDomains = ["chatgpt.com", "chat.openai.com", "openai.com", "auth0.com", "auth.openai.com"]
            let host = url.host ?? ""
            
            if allowedDomains.contains(where: { host.contains($0) }) {
                decisionHandler(.allow)
            } else if url.scheme == "mailto" || url.scheme == "tel" {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
            } else if navigationAction.navigationType == .linkActivated {
                // Open external links in default browser
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
        
        // MARK: - WKUIDelegate
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Handle popup windows by loading in the same view
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = NSAlert()
            alert.messageText = "ChatGPT"
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.runModal()
            completionHandler()
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = NSAlert()
            alert.messageText = "ChatGPT"
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            let response = alert.runModal()
            completionHandler(response == .alertFirstButtonReturn)
        }
    }
}
