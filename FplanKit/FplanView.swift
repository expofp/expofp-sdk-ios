import Foundation
import SwiftUI
import Combine
import WebKit
import UIKit

/**
 Views to display the floor plan

 You can create a floor plan on the https://expofp.com
 */
@available(iOS 13.0, *)
public struct FplanView: UIViewRepresentable {
    
    private let url: String
    private let eventId: String
    private let noOverlay: Bool
    private let route: Route?
    private let currentPosition: Point?
    private let focusOnCurrentPosition: Bool
    private let fpReadyAction: (() -> Void)?
    private let buildDirectionAction: ((_ direction: Direction) -> Void)?
    
    @Binding var selectedBooth: String?
    
    /**
     This function initializes the view.
      
     **Parameters:**
     - url: Floor plan URL address in the format https://[expo_name].expofp.com
     - eventId = [expo_name]: Id of the expo
     - noOverlay: True - Hides the panel with information about exhibitors
     - selectedBooth: Booth selected on the floor plan
     - route: Information about the route to be built
     - currentPosition: Current position on the floor plan
     - focusOnCurrentPosition: Focus on current position
     - fpReadyAction: Callback to be called after the floor plan has been ready
     - buildDirectionAction: Callback to be called after the route has been built
     */
    public init(_ url: String,
                eventId: String? = nil,
                noOverlay: Bool = true,
                selectedBooth: Binding<String?>? = nil,
                route: Route? = nil,
                currentPosition: Point? = nil,
                focusOnCurrentPosition: Bool = false,
                fpReadyAction:(() -> Void)? = nil,
                buildDirectionAction: ((_ direction: Direction) -> Void)? = nil){
        
        let eventAddress = Helper.getEventAddress(url)
        let eventUrl = "https://\(eventAddress)"
        
        self.url = eventUrl
        self.eventId = eventId ?? Helper.getEventId(eventUrl)
        self.noOverlay = noOverlay
        self._selectedBooth = selectedBooth ?? Binding.constant(nil)
        self.route = route
        self.currentPosition = currentPosition
        self.focusOnCurrentPosition = focusOnCurrentPosition
        self.fpReadyAction = fpReadyAction
        self.buildDirectionAction = buildDirectionAction
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        preferences.setValue(true, forKey: "offlineApplicationCacheIsEnabled")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        
        webView.configuration.userContentController.add(FpHandler(webView, fpReady), name: "onFpConfiguredHandler")
        webView.configuration.userContentController.add(BoothHandler(webView, selectBooth), name: "onBoothClickHandler")
        webView.configuration.userContentController.add(DirectionHandler(webView, buildDirection), name: "onDirectionHandler")

        return webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
        
        let newEventAddress = Helper.getEventAddress(self.url).lowercased()
        let path = webView.url?.path ?? ""
        
        if(!(webView.url?.absoluteString.lowercased().contains(newEventAddress) ?? false)){
            initWebView(webView)
        }
        else{
            updateWebView(webView)
        }
    }
    
    private func updateWebView(_ webView: WKWebView) {
        if(self.selectedBooth != nil){
            webView.evaluateJavaScript("window.selectBooth('\(self.selectedBooth!)');")
        }
        else if(self.route == nil){
            webView.evaluateJavaScript("window.selectBooth(null);")
        }
        
        if(self.route != nil){
            webView.evaluateJavaScript("window.selectRoute('\(self.route!.from)', '\(self.route!.to)', \(self.route!.exceptInaccessible));")
        }
        else if(self.selectedBooth == nil){
            webView.evaluateJavaScript("window.selectRoute(null, null, false);")
        }
        
        if(self.currentPosition != nil){
            webView.evaluateJavaScript("window.setCurrentPosition(\(self.currentPosition!.x), \(self.currentPosition!.y), \(focusOnCurrentPosition));")
        }
        else{
            webView.evaluateJavaScript("window.setCurrentPosition(null, null, false);")
        }
    }
    
    private func initWebView(_ webView: WKWebView) {
        let fileManager = FileManager.default
        let netReachability = NetworkReachability()
        
        let eventAddress = Helper.getEventAddress(self.url)
        
        let eventUrl = "https://\(eventAddress)"
        let fplanDirectory = Helper.getCacheDirectory().appendingPathComponent("fplan/")
        let directory = fplanDirectory.appendingPathComponent("\(eventAddress)/")
        let indexPath = directory.appendingPathComponent("index.html")
        
        do {
            if(netReachability.checkConnection()){
                if fileManager.fileExists(atPath: fplanDirectory.path){
                    try fileManager.removeItem(at: fplanDirectory)
                }
                
                let expofpJsUrl = "\(eventUrl)/packages/master/expofp.js"
                try Helper.createHtmlFile(filePath: indexPath, noOverlay: noOverlay, directory: directory,expofpJsUrl: expofpJsUrl, eventId: self.eventId )
                
                let requestUrl = URLRequest(url: indexPath, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
                webView.load(requestUrl)
                
                try Helper.updateAllFiles(baseUrl: URL(string: eventUrl), directory: directory)
            }
            else{
                let expofpJsUrl = "\(directory.path)/expofp.js"
                try Helper.createHtmlFile(filePath: indexPath, noOverlay: noOverlay, directory: directory, expofpJsUrl: expofpJsUrl, eventId: self.eventId )
                
                let requestUrl = URLRequest(url: indexPath, cachePolicy: .returnCacheDataElseLoad)
                webView.load(requestUrl)
            }
        } catch {
            print(error)
        }
        
    }
    
    private func fpReady(_ webView: WKWebView){
        //updateWebView(webView)
        self.fpReadyAction?()
    }
    
    private func selectBooth(_ webView: WKWebView, _ boothName: String){
        self.selectedBooth = boothName
    }
    
    private func buildDirection(_ webView: WKWebView, _ direction: Direction){
        self.buildDirectionAction?(direction)
    }
}

public struct FplanView_Previews: PreviewProvider {
    
    public init(){
        
    }
    
    @available(iOS 13.0.0, *)
    public static var previews: some View {
        FplanView("https://demo.expofp.com")
    }
}
