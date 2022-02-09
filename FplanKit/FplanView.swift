import Foundation
import SwiftUI
import Combine
import WebKit
import UIKit


@available(iOS 13.0, *)
public struct FplanView: UIViewRepresentable {
    
    private let webView: WKWebView
    private let fplanReadyHandler: (() -> Void)?
    private let boothSelectionHandler: ((_ boothName: String) -> Void)?
    private let routeBuildHandler: ((_ route: Route) -> Void)?
    
    /**
     Initialize view
     @param url expo URL address in the format https://[expo_name].expofp.com
     @param fplanReadyHandler Callback called after the map has been built
     @param boothSelectionHandler Callback called after clicking on the booth on the map
     @param routeBuildHandler Callback to be called after the route has been built
     */
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
    
    /**
     Select booth and focus on map
     @param boothName Name of the booth
     */
    public func selectBooth(_ boothName:String){
        self.webView.evaluateJavaScript("window.selectBooth('\(boothName)');")
    }
    
    /**
     Build a route from one booth to another
     @param from Start booth name
     @param to End booth name
     @param exceptInaccessible True - exclude routes inaccessible to people with disabilities
     */
    public func buildRoute(_ from: String, _ to: String, _ exceptInaccessible: Bool = false){
        self.webView.evaluateJavaScript("window.selectRoute('\(from)', '\(to)', \(exceptInaccessible))")
    }
    
    /**
     Set current position(Blu Dot) on the map
     @param x X
     @param y Y
     @param focus true - focus on a point
     */
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
        
        let fplanDirectory = Helper.getCacheDirectory().appendingPathComponent("fplan/")
        let directory = fplanDirectory.appendingPathComponent("\(eventAddress)/")
        let indexPath = directory.appendingPathComponent("index.html")
        
        do {
            if(netReachability.checkConnection()){
                if fileManager.fileExists(atPath: fplanDirectory.path){
                    try fileManager.removeItem(at: fplanDirectory)
                }
                
                let expofpJsUrl = "\(eventUrl)/packages/master/expofp.js"
                try createHtmlFile(filePath: indexPath, directory: directory,expofpJsUrl: expofpJsUrl, eventId: eventId )
                
                let requestUrl = URLRequest(url: indexPath, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
                self.webView.load(requestUrl)
                
                try Helper.updateAllFiles(baseUrl: URL(string: eventUrl), directory: directory)
            }
            else{
                let expofpJsUrl = "\(directory.path)/expofp.js"
                try createHtmlFile(filePath: indexPath, directory: directory, expofpJsUrl: expofpJsUrl, eventId: eventId )
                
                let requestUrl = URLRequest(url: indexPath, cachePolicy: .returnCacheDataElseLoad)
                self.webView.load(requestUrl)
            }
        } catch {
            print(error)
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
