import SwiftUI
import WebKit

@main
struct GymTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            GymTrackerWebView()
                .ignoresSafeArea()
        }
    }
}

struct GymTrackerWebView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Memoria persistente dell'app
        configuration.websiteDataStore = .default()

        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.backgroundColor = .systemBackground
        webView.isOpaque = true

        if let url = Bundle.main.url(
            forResource: "index",
            withExtension: "html"
        ) {
            webView.loadFileURL(
                url,
                allowingReadAccessTo: url.deletingLastPathComponent()
            )
        } else {
            let html = """
            <html>
            <body style="font-family: sans-serif; padding: 30px;">
            <h2>Gym Tracker</h2>
            <p>Errore: index.html non trovato nell'app.</p>
            </body>
            </html>
            """

            webView.loadHTMLString(html, baseURL: nil)
        }

        return webView
    }

    func updateUIView(
        _ webView: WKWebView,
        context: Context
    ) {}

    class Coordinator: NSObject, WKNavigationDelegate {

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            showError(in: webView, message: error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            showError(in: webView, message: error.localizedDescription)
        }

        private func showError(
            in webView: WKWebView,
            message: String
        ) {
            let html = """
            <html>
            <body style="font-family: -apple-system; padding: 30px;">
            <h2>Gym Tracker</h2>
            <p>Errore di caricamento:</p>
            <pre>\(message)</pre>
            </body>
            </html>
            """

            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}
