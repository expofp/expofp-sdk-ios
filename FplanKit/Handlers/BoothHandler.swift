import Foundation
import WebKit

@available(iOS 13.0, *)
class BoothHandler : NSObject, WKScriptMessageHandler {
    
    private let boothSelectionHandler: (_ boothName: String) -> Void
    
    public init(_ boothSelectionHandler: ((_ boothName: String) -> Void)!) {
        self.boothSelectionHandler = boothSelectionHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let boothName = message.body as? String{
            boothSelectionHandler(boothName)
        }
    }
}
