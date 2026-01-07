import SwiftUI
import WebKit

@main
struct ChatGPTApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Chat") {
                    NotificationCenter.default.post(name: .newChat, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(replacing: .help) {
                Button("ChatGPT Help") {
                    NSWorkspace.shared.open(URL(string: "https://help.openai.com/")!)
                }
            }
            
            CommandGroup(after: .appInfo) {
                Divider()
                Button("Visit ChatGPT Website") {
                    NSWorkspace.shared.open(URL(string: "https://chatgpt.com/")!)
                }
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure the main window
        if let window = NSApplication.shared.windows.first {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isMovableByWindowBackground = true
            window.backgroundColor = NSColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

extension Notification.Name {
    static let newChat = Notification.Name("newChat")
    static let reloadPage = Notification.Name("reloadPage")
    static let goBack = Notification.Name("goBack")
    static let goForward = Notification.Name("goForward")
}

struct SettingsView: View {
    @AppStorage("clearCacheOnQuit") private var clearCacheOnQuit = false
    @AppStorage("enableNotifications") private var enableNotifications = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Clear cache on quit", isOn: $clearCacheOnQuit)
                Toggle("Enable notifications", isOn: $enableNotifications)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ChatGPT Desktop App")
                        .font(.headline)
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Powered by OpenAI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Link("https://chatgpt.com/", destination: URL(string: "https://chatgpt.com/")!)
                        .font(.caption)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 250)
        .padding()
    }
}

// MARK: - Cookie Storage Helper
class CookieManager {
    static let shared = CookieManager()
    
    private init() {}
    
    func saveCookies() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.httpCookieStore.getAllCookies { cookies in
            let cookieData = cookies.compactMap { cookie -> [String: Any]? in
                return [
                    "name": cookie.name,
                    "value": cookie.value,
                    "domain": cookie.domain,
                    "path": cookie.path,
                    "expires": cookie.expiresDate?.timeIntervalSince1970 ?? 0,
                    "secure": cookie.isSecure,
                    "httpOnly": cookie.isHTTPOnly
                ]
            }
            
            if let data = try? JSONSerialization.data(withJSONObject: cookieData) {
                UserDefaults.standard.set(data, forKey: "savedCookies")
            }
        }
    }
    
    func restoreCookies(to webView: WKWebView) {
        guard let data = UserDefaults.standard.data(forKey: "savedCookies"),
              let cookieData = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return
        }
        
        for cookie in cookieData {
            var properties: [HTTPCookiePropertyKey: Any] = [:]
            properties[.name] = cookie["name"]
            properties[.value] = cookie["value"]
            properties[.domain] = cookie["domain"]
            properties[.path] = cookie["path"]
            
            if let expires = cookie["expires"] as? TimeInterval, expires > 0 {
                properties[.expires] = Date(timeIntervalSince1970: expires)
            }
            
            properties[.secure] = cookie["secure"]
            
            if let httpCookie = HTTPCookie(properties: properties) {
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(httpCookie)
            }
        }
    }
}
