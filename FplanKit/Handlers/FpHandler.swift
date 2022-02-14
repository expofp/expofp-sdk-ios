import Foundation
import WebKit

@available(iOS 13.0, *)
class FpHandler : NSObject, WKScriptMessageHandler {
    private let webView: WKWebView
    private let fplanReadyHandler: (_ webView: WKWebView) -> Void
    
    public init(_ webView: WKWebView, _ fplanReadyHandler: ((_ webView: WKWebView) -> Void)!) {
        self.webView = webView
        self.fplanReadyHandler = fplanReadyHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        fplanReadyHandler(webView)
    }
}
