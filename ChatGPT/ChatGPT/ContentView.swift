import SwiftUI
import WebKit

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel()
    @State private var isLoading = true
    @State private var loadingProgress: Double = 0
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isHoveringBack = false
    @State private var isHoveringForward = false
    @State private var isHoveringReload = false
    @State private var isHoveringHome = false
    
    private let chatGPTURL = "https://chatgpt.com/"
    
    var body: some View {
        ZStack {
            // Background
            Color(nsColor: NSColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0))
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Title Bar
                titleBar
                
                // Loading Progress Bar
                if isLoading {
                    ProgressView(value: loadingProgress)
                        .progressViewStyle(.linear)
                        .tint(Color(red: 0.063, green: 0.639, blue: 0.498))
                }
                
                // Web Content
                WebView(
                    url: URL(string: chatGPTURL)!,
                    viewModel: webViewModel,
                    isLoading: $isLoading,
                    loadingProgress: $loadingProgress,
                    showError: $showError,
                    errorMessage: $errorMessage
                )
                .ignoresSafeArea(edges: .bottom)
            }
            
            // Loading Overlay
            if isLoading && loadingProgress < 0.1 {
                loadingOverlay
            }
            
            // Error View
            if showError {
                errorView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .newChat)) { _ in
            webViewModel.loadURL(chatGPTURL)
        }
        .onReceive(NotificationCenter.default.publisher(for: .reloadPage)) { _ in
            webViewModel.reload()
        }
        .onReceive(NotificationCenter.default.publisher(for: .goBack)) { _ in
            webViewModel.goBack()
        }
        .onReceive(NotificationCenter.default.publisher(for: .goForward)) { _ in
            webViewModel.goForward()
        }
    }
    
    // MARK: - Title Bar
    private var titleBar: some View {
        HStack(spacing: 12) {
            // Traffic light spacer
            Color.clear
                .frame(width: 70)
            
            // Navigation Buttons
            HStack(spacing: 8) {
                // Back Button
                Button(action: { webViewModel.goBack() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(webViewModel.canGoBack ? .white : .gray.opacity(0.5))
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isHoveringBack && webViewModel.canGoBack ? Color.white.opacity(0.1) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!webViewModel.canGoBack)
                .onHover { hovering in isHoveringBack = hovering }
                .help("Go Back")
                
                // Forward Button
                Button(action: { webViewModel.goForward() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(webViewModel.canGoForward ? .white : .gray.opacity(0.5))
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isHoveringForward && webViewModel.canGoForward ? Color.white.opacity(0.1) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!webViewModel.canGoForward)
                .onHover { hovering in isHoveringForward = hovering }
                .help("Go Forward")
                
                // Reload Button
                Button(action: { webViewModel.reload() }) {
                    Image(systemName: isLoading ? "xmark" : "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isHoveringReload ? Color.white.opacity(0.1) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .onHover { hovering in isHoveringReload = hovering }
                .help(isLoading ? "Stop Loading" : "Reload")
            }
            
            Spacer()
            
            // Title
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.green)
                
                Text("chatgpt.com")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
            )
            
            Spacer()
            
            // Home Button
            Button(action: { webViewModel.loadURL(chatGPTURL) }) {
                Image(systemName: "house")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isHoveringHome ? Color.white.opacity(0.1) : Color.clear)
                    )
            }
            .buttonStyle(.plain)
            .onHover { hovering in isHoveringHome = hovering }
            .help("Go to ChatGPT Home")
            
            Color.clear
                .frame(width: 12)
        }
        .frame(height: 52)
        .background(Color(nsColor: NSColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0)))
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color(nsColor: NSColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0))
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Logo
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.063, green: 0.639, blue: 0.498),
                                    Color(red: 0.051, green: 0.549, blue: 0.427)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.063, green: 0.639, blue: 0.498),
                                    Color(red: 0.051, green: 0.549, blue: 0.427)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: isLoading
                )
                
                Text("ChatGPT")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Loading...")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)
                    .tint(Color(red: 0.063, green: 0.639, blue: 0.498))
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Error View
    private var errorView: some View {
        ZStack {
            Color(nsColor: NSColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.95))
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 48))
                    .foregroundColor(.red.opacity(0.8))
                
                Text("Connection Error")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    showError = false
                    webViewModel.loadURL(chatGPTURL)
                }) {
                    Text("Try Again")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.063, green: 0.639, blue: 0.498))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Web View Model
class WebViewModel: ObservableObject {
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var currentURL: String = ""
    
    weak var webView: WKWebView?
    
    func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        webView?.load(URLRequest(url: url))
    }
    
    func reload() {
        webView?.reload()
    }
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func stopLoading() {
        webView?.stopLoading()
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .frame(width: 1200, height: 800)
}
