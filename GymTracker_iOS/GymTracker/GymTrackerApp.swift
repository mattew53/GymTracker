import SwiftUI
import WebKit

@main
struct GymTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            GymTrackerWebView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
        }
        .windowManagerRole(.principal)
    }
}

struct GymTrackerWebView: UIViewRepresentable {

    func makeUIView(context: Context) -> WKWebView {

        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()

        let bundleHandler = BundleSchemeHandler()
        configuration.setURLSchemeHandler(
            bundleHandler,
            forURLScheme: "gymtracker"
        )

        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.navigationDelegate = context.coordinator

        configuration.userContentController.add(
            context.coordinator,
            name: "jsError"
        )

        if let url = URL(string: "gymtracker://local/index.html") {
            webView.load(URLRequest(url: url))
        } else {
            webView.loadHTMLString(
                "<h1>Errore caricamento Gym Tracker</h1>",
                baseURL: nil
            )
        }

        return webView
    }
    func updateUIView(
        _ webView: WKWebView,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

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
            showError(
                in: webView,
                message: error.localizedDescription
            )
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            showError(
                in: webView,
                message: error.localizedDescription
            )
        }

        private func showError(
            in webView: WKWebView,
            message: String
        ) {
            let safeMessage = message
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")

            webView.loadHTMLString(
                """
                <html>
                <body style="font-family:-apple-system;padding:30px">
                <h2>Gym Tracker — errore</h2>
                <p>\(safeMessage)</p>
                </body>
                </html>
                """,
                baseURL: nil
            )
        }
    }
}


// MARK: - Local Bundle Handler

final class BundleSchemeHandler: NSObject, WKURLSchemeHandler {

    func webView(
        _ webView: WKWebView,
        start urlSchemeTask: WKURLSchemeTask
    ) {

        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(
                NSError(
                    domain: "GymTracker",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "URL non valida."
                    ]
                )
            )
            return
        }

        let fileName = url.path
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        let components = fileName.split(
            separator: ".",
            omittingEmptySubsequences: false
        )

        let name: String
        let ext: String

        if components.count >= 2 {
            ext = String(components.last!)
            name = components.dropLast().joined(separator: ".")
        } else {
            name = fileName
            ext = ""
        }

        guard let fileURL = Bundle.main.url(
            forResource: name,
            withExtension: ext.isEmpty ? nil : ext
        ) else {
            urlSchemeTask.didFailWithError(
                NSError(
                    domain: "GymTracker",
                    code: 2,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "File non trovato: \(fileName)"
                    ]
                )
            )
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)

            let mimeType: String

            switch ext.lowercased() {
            case "html":
                mimeType = "text/html"
            case "css":
                mimeType = "text/css"
            case "js":
                mimeType = "application/javascript"
            case "png":
                mimeType = "image/png"
            case "jpg", "jpeg":
                mimeType = "image/jpeg"
            case "svg":
                mimeType = "image/svg+xml"
            default:
                mimeType = "application/octet-stream"
            }

            let response = URLResponse(
                url: url,
                mimeType: mimeType,
                expectedContentLength: data.count,
                textEncodingName: ext.lowercased() == "html"
                    || ext.lowercased() == "css"
                    || ext.lowercased() == "js"
                    ? "utf-8"
                    : nil
            )

            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()

        } catch {
            urlSchemeTask.didFailWithError(error)
        }
    }

    func webView(
        _ webView: WKWebView,
        stop urlSchemeTask: WKURLSchemeTask
    ) {
        // Nessuna operazione da interrompere.
    }
}
