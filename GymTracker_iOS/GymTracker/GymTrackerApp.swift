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
        configuration.websiteDataStore = .default()

        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.navigationDelegate = context.coordinator

        // Mostra gli errori JavaScript invece di lasciare una schermata bianca
        webView.configuration.userContentController.add(
            context.coordinator,
            name: "jsError"
        )

        if let url = Bundle.main.url(
            forResource: "index",
            withExtension: "html"
        ) {
            webView.loadFileURL(
                url,
                allowingReadAccessTo: Bundle.main.bundleURL
            )
        } else {
            webView.loadHTMLString(
                "<h1>ERRORE: index.html non trovato</h1>",
                baseURL: nil
            )
        }

        return webView
    }

    func updateUIView(
        _ webView: WKWebView,
        context: Context
    ) {}

    class Coordinator: NSObject,
                       WKNavigationDelegate,
                       WKScriptMessageHandler {

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            if message.name == "jsError" {
                print("JAVASCRIPT ERROR:", message.body)
            }
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            showError(webView, error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            showError(webView, error.localizedDescription)
        }

        private func showError(
            _ webView: WKWebView,
            _ message: String
        ) {
            webView.loadHTMLString(
                """
                <html>
                <body style="font-family:-apple-system;padding:30px">
                <h2>Gym Tracker — errore</h2>
                <p>\(message)</p>
                </body>
                </html>
                """,
                baseURL: nil
            )
        }
    }
}
