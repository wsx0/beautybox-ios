import SwiftUI
import WebKit

/// 混合模式：直接加载后端 H5。原生侧通过 beautybox:// 协议接收下载、分享、关闭等指令。
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
        if let bundledPath,
           let fileURL = Bundle.main.url(forResource: bundledPath, withExtension: nil) {
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        } else if let url {
            webView.load(URLRequest(url: url))
        }
        context.coordinator.webView = webView
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.stopLoading()
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        weak var webView: WKWebView?

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let html = """
            <html><body style="background:#0f0f14;color:#eee;font-family:-apple-system;padding:40px">
            <h3>加载失败</h3><p>\(error.localizedDescription)</p>
            <p>请在「设置」里切换到可达的后端地址。</p></body></html>
            """
            webView.loadHTMLString(html, baseURL: nil)
        }

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
