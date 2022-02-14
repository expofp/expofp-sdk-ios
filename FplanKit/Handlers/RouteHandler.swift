import Foundation
import WebKit

struct JSONRoute : Decodable {
    let distance: String
    let time: Int
}

@available(iOS 13.0, *)
class RouteHandler : NSObject, WKScriptMessageHandler {
    private let webView: WKWebView
    private let routeBuildHandler: (_ webView: WKWebView, _ route: Route) -> Void
    
    public init(_ webView: WKWebView, _ routeBuildHandler: ((_ webView: WKWebView, _ route: Route) -> Void)!) {
        self.webView = webView
        self.routeBuildHandler = routeBuildHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let json = message.body as? String{
            let decoder = JSONDecoder()
            guard let jRoute = try? decoder.decode(JSONRoute.self, from: json.data(using: .utf8)!) else {
                return
            }
            routeBuildHandler(webView, Route(distance: jRoute.distance, duration: TimeInterval(jRoute.time)))
        }
    }
}
