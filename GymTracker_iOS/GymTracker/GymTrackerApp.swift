import SwiftUI
import WebKit

@main
struct GymTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            GymTrackerWebView()
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

struct GymTrackerWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return webView
    }
    func updateUIView(_ webView: WKWebView, context: Context) {}
}
