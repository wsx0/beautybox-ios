import SwiftUI
import WebKit

/// 混合模式：可加载远端 H5，也可加载包内 webapp。
struct WebContainerView: UIViewRepresentable {
    var url: URL? = nil
    var bundledPath: String? = nil

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        let userContent = WKUserContentController()
        userContent.add(context.coordinator, name: "beautybox")
        config.userContentController = userContent

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        context.coordinator.webView = webView

        if let fileURL = Self.resolveBundledFile(bundledPath) {
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        } else if let url {
            webView.load(URLRequest(url: url))
        } else {
            webView.loadHTMLString("<html><body style='background:#fff'>没有可加载的页面</body></html>", baseURL: nil)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.stopLoading()
    }

    /// 兼容两种打包形态：目录引用（webapp/index.html）与平铺资源（index.html）。
    static func resolveBundledFile(_ path: String?) -> URL? {
        guard let path else { return nil }
        let parts = path.split(separator: "/").map(String.init)
        if parts.count == 2,
           let u = Bundle.main.url(forResource: parts[1], withExtension: nil, subdirectory: parts[0]) {
            return u
        }
        let direct = Bundle.main.bundleURL.appendingPathComponent(path)
        if FileManager.default.fileExists(atPath: direct.path) { return direct }
        if let u = Bundle.main.url(forResource: path, withExtension: nil) { return u }
        return nil
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        weak var webView: WKWebView?

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let html = """
            <html><body style="background:#fff;color:#333;font-family:-apple-system;padding:40px">
            <h3>加载失败</h3><p>\(error.localizedDescription)</p>
            <p>请在设置里切换运行模式或检查服务器地址。</p></body></html>
            """
            webView.loadHTMLString(html, baseURL: nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let body = message.body as? [String: Any], let action = body["action"] as? String else { return }
            switch action {
            case "back":
                if webView?.canGoBack == true { webView?.goBack() }
            case "reload":
                webView?.reload()
            default:
                break
            }
        }
    }
}
