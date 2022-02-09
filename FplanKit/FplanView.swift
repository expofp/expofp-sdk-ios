import Foundation
import SwiftUI
import Combine
import WebKit
import UIKit

public struct Route {
    let distance: String
    let duration: TimeInterval
}

public struct JRoute : Decodable {
    let distance: String
    let time: Int
}

@available(iOS 13.0, *)
public class FpHandler : NSObject, WKScriptMessageHandler {
    
    private let fplanReadyHandler: () -> Void
    
    public init(_ fplanReadyHandler: (() -> Void)!) {
        self.fplanReadyHandler = fplanReadyHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        fplanReadyHandler()
    }
}

@available(iOS 13.0, *)
public class BoothHandler : NSObject, WKScriptMessageHandler {
    
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

@available(iOS 13.0, *)
public class RouteHandler : NSObject, WKScriptMessageHandler {
    
    private let routeBuildHandler: (_ route: Route) -> Void
    
    public init(_ routeBuildHandler: ((_ route: Route) -> Void)!) {
        self.routeBuildHandler = routeBuildHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let json = message.body as? String{
            let decoder = JSONDecoder()
            guard let jRoute = try? decoder.decode(JRoute.self, from: json.data(using: .utf8)!) else {
                return
            }
            routeBuildHandler(Route(distance: jRoute.distance, duration: TimeInterval(jRoute.time)))
        }
    }
}

@available(iOS 13.0, *)
public struct FplanView: UIViewRepresentable {
    
    private let webView: WKWebView
    private let fplanReadyHandler: (() -> Void)?
    private let boothSelectionHandler: ((_ boothName: String) -> Void)?
    private let routeBuildHandler: ((_ route: Route) -> Void)?
    
    public init(_ url: String, fplanReadyHandler: (() -> Void)? = nil,
                boothSelectionHandler: ((_ boothName: String) -> Void)? = nil,
                routeBuildHandler: ((_ route: Route) -> Void)? = nil){
        
        self.fplanReadyHandler = fplanReadyHandler
        self.boothSelectionHandler = boothSelectionHandler
        self.routeBuildHandler = routeBuildHandler
        
        let preferences = WKPreferences()
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        preferences.setValue(true, forKey: "offlineApplicationCacheIsEnabled")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.scrollView.isScrollEnabled = true
        
        intWebView(url: url)
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        return self.webView
    }
    
    public func selectBooth(_ boothName:String){
        self.webView.evaluateJavaScript("window.selectBooth('\(boothName)');")
    }
    
    public func buildRoute(_ from: String, _ to: String, _ exceptUnaccessible: Bool = false){
        self.webView.evaluateJavaScript("window.selectRoute('\(from)', '\(to)', \(exceptUnaccessible))")
    }
    
    public func setCurrentPosition(_ x: Int, _ y: Int, _ focus: Bool = false){
        self.webView.evaluateJavaScript("window.setCurrentPosition('\(x)', '\(y)', \(focus))")
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
    }
    
    private func intWebView(url: String) {
        let fileManager = FileManager.default
        let netReachability = NetworkReachability()
        
        let eventAddress = url.replacingOccurrences(of: "https://www.", with: "").replacingOccurrences(of: "https://", with: "")        
        let eventUrl = "https://\(eventAddress)"
        let eventId = String(eventAddress[...eventAddress.index(eventAddress.firstIndex(of: ".")!, offsetBy: -1)])
        let directory = Helper.getCacheDirectory().appendingPathComponent("fplan/\(eventAddress)/")
        let indexPath = directory.appendingPathComponent("index.html")
        do {
            if(netReachability.checkConnection()){
                try fileManager.removeItem(at: directory)
                
                let expofpJsUrl = "\(eventUrl)/packages/master/expofp.js"
                try createHtmlFile(filePath: indexPath, directory: directory,expofpJsUrl: expofpJsUrl, eventId: eventId )
                
                let requestUrl = URLRequest(url: indexPath, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
                self.webView.load(requestUrl)
                
                try Helper.updateAllFiles(baseUrl: URL(string: eventUrl), directory: directory)
            }
            else{
                let expofpJsUrl = "\(directory.path)/expofp.js"
                try createHtmlFile(filePath: indexPath, directory: directory,expofpJsUrl: expofpJsUrl, eventId: eventId )
                
                let requestUrl = URLRequest(url: indexPath, cachePolicy: .returnCacheDataElseLoad)
                self.webView.load(requestUrl)
            }
        } catch {
        }
        
        if let handle = fplanReadyHandler{
            self.webView.configuration.userContentController.add(FpHandler(handle), name: "onFpConfiguredHandler")
        }
        
        if let handle = boothSelectionHandler{
            self.webView.configuration.userContentController.add(BoothHandler(handle), name: "onBoothClickHandler")
        }
        
        if let handle = routeBuildHandler{
            self.webView.configuration.userContentController.add(RouteHandler(handle), name: "onDirectionHandler")
        }
    }
    
    private func createHtmlFile(filePath: URL, directory: URL, expofpJsUrl: String, eventId: String) throws {
        let fileManager = FileManager.default
        let html = Helper.getIndexHtml()
            .replacingOccurrences(of: "$expofp_js_url#", with: expofpJsUrl)
            .replacingOccurrences(of: "$eventId#", with: eventId)
        
        if !fileManager.fileExists(atPath: filePath.path){
            try! fileManager.createDirectory(atPath: directory.path, withIntermediateDirectories: true, attributes: nil)
        }
        try html.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
    }
}

public struct FplanView_Previews: PreviewProvider {
    public init(){
        
    }
    @available(iOS 13.0.0, *)
    public static var previews: some View {
        FplanView("https://wayfinding.expofp.com")
    }
}
