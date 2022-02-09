import Foundation
import WebKit

struct JSONRoute : Decodable {
    let distance: String
    let time: Int
}

@available(iOS 13.0, *)
class RouteHandler : NSObject, WKScriptMessageHandler {
    
    private let routeBuildHandler: (_ route: Route) -> Void
    
    public init(_ routeBuildHandler: ((_ route: Route) -> Void)!) {
        self.routeBuildHandler = routeBuildHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let json = message.body as? String{
            let decoder = JSONDecoder()
            guard let jRoute = try? decoder.decode(JSONRoute.self, from: json.data(using: .utf8)!) else {
                return
            }
            routeBuildHandler(Route(distance: jRoute.distance, duration: TimeInterval(jRoute.time)))
        }
    }
}
