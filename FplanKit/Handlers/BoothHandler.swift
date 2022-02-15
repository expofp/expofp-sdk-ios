import Foundation
import WebKit

@available(iOS 13.0, *)
class BoothHandler : NSObject, WKScriptMessageHandler {
    
    private let webView: WKWebView
    private let boothSelectionHandler: ((_ webView: WKWebView, _ boothName: String) -> Void)
    
    public init(_ webView: WKWebView, _ boothSelectionHandler: ((_ webView: WKWebView, _ boothName: String) -> Void)!) {
        self.webView = webView
        self.boothSelectionHandler = boothSelectionHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let boothName = message.body as? String{
            boothSelectionHandler(webView, boothName)
        }
    }
}
