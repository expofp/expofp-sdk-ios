import Foundation
import WebKit

@available(iOS 13.0, *)
class FpHandler : NSObject, WKScriptMessageHandler {
    
    private let fplanReadyHandler: () -> Void
    
    public init(_ fplanReadyHandler: (() -> Void)!) {
        self.fplanReadyHandler = fplanReadyHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        fplanReadyHandler()
    }
}
