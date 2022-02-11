import Foundation
import SwiftUI
import Combine
import WebKit
import UIKit

/**
 Views to display the floor plan

 You can create a floor plan on the site https://expofp.com
 */
@available(iOS 13.0, *)
public struct FplanView: UIViewRepresentable {
    
    private let webView: WKWebView
    private let fplanReadyHandler: (() -> Void)?
    private let boothSelectionHandler: ((_ boothName: String) -> Void)?
    private let routeBuildHandler: ((_ route: Route) -> Void)?
    
    /**
     This function initializes the view.
      
     **Parameters:**
         - url: Floor plan URL address in the format https://[expo_name].expofp.com
         - fplanReadyHandler: Callback called after the floor plan has been built
         - boothSelectionHandler: Callback called after clicking on the booth
         - routeBuildHandler: Callback to be called after the route has been built
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
     This function selects a booth on the floor plan.
      
     **Parameters:**
         - boothName: Name of the booth
     */
    public func selectBooth(_ boothName:String){
        self.webView.evaluateJavaScript("window.selectBooth('\(boothName)');")
    }
    
    
    /**
     This function builds a route from one booth to another.
      
     **Parameters:**
         - from: Start booth name
         - to: End booth name
         - exceptInaccessible: Exclude routes inaccessible to people with disabilities
     */
    public func buildRoute(_ from: String, _ to: String, _ exceptInaccessible: Bool = false){
        self.webView.evaluateJavaScript("window.selectRoute('\(from)', '\(to)', \(exceptInaccessible))")
    }
    
    /**
     This function sets current position(blue-dot) on the floor plan.
      
     **Parameters:**
         - x: X
         - y: Y
         - focus: Focus on a point
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
