import Foundation
import WebKit

@available(iOS 13.0, *)
class FpHandler : NSObject, WKScriptMessageHandler {
    private let webView: FSWebView
    private let fplanReadyHandler: (_ webView: FSWebView) -> Void
    
    public init(_ webView: FSWebView, _ fplanReadyHandler: ((_ webView: FSWebView) -> Void)!) {
        self.webView = webView
        self.fplanReadyHandler = fplanReadyHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        fplanReadyHandler(webView)
    }
}
