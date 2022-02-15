import Foundation
import WebKit

struct JSONLine : Decodable {
    let p0: Point
    let p1: Point
    let weight: Int
}

struct JSONRoute : Decodable {
    let distance: String
    let time: Int
    let from: Booth
    let to: Booth
    let lines: [JSONLine]
}

@available(iOS 13.0, *)
class DirectionHandler : NSObject, WKScriptMessageHandler {
    private let webView: WKWebView
    private let directionBuildHandler: (_ webView: WKWebView, _ direction: Direction) -> Void
    
    public init(_ webView: WKWebView, _ directionBuildHandler: ((_ webView: WKWebView, _ direction: Direction) -> Void)!) {
        self.webView = webView
        self.directionBuildHandler = directionBuildHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let json = message.body as? String{
            let decoder = JSONDecoder()
            
            guard let jRoute = try? decoder.decode(JSONRoute.self, from: json.data(using: .utf8)!) else {
                return
            }
            directionBuildHandler(webView, Direction(distance: jRoute.distance, duration: TimeInterval(jRoute.time), from: jRoute.from, to: jRoute.to, lines: jRoute.lines.map { (jline) -> Line in return Line(startPoint: jline.p0, endPoint: jline.p1, weight: jline.weight)}))
        }
    }
}
