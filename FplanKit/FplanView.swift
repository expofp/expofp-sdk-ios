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
    private let focusOnCurrentPosition: Bool
    private let fpReadyAction: (() -> Void)?
    private let buildDirectionAction: ((_ direction: Direction) -> Void)?
    
    @State private var webViewController = FSWebViewController()
    @Binding var selectedBooth: String?
    @Binding var currentPosition: BlueDotPoint?
    
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
                currentPosition: Binding<BlueDotPoint?>? = nil,
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
        self._currentPosition = currentPosition ?? Binding.constant(nil)
        self.focusOnCurrentPosition = focusOnCurrentPosition
        self.fpReadyAction = fpReadyAction
        self.buildDirectionAction = buildDirectionAction
    }
    
    public func makeUIView(context: Context) -> FSWebView {
        let preferences = WKPreferences()
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        preferences.setValue(true, forKey: "offlineApplicationCacheIsEnabled")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.setURLSchemeHandler(webViewController, forURLScheme: Constants.scheme)
        
        let webView = FSWebView(frame: CGRect.zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.navigationDelegate = webViewController
        
        webView.configuration.userContentController.add(FpHandler(webView, fpReady), name: "onFpConfiguredHandler")
        webView.configuration.userContentController.add(BoothHandler(webView, selectBooth), name: "onBoothClickHandler")
        webView.configuration.userContentController.add(DirectionHandler(webView, buildDirection), name: "onDirectionHandler")
        
        return webView
    }
    
    public func updateUIView(_ webView: FSWebView, context: Context) {
        
        let newEventAddress = Helper.getEventAddress(self.url).lowercased()
        
        if(!(webView.url?.absoluteString.lowercased().contains(newEventAddress) ?? false)){
            initWebView(webView)
        }
        else{
            updateWebView(webView)
        }
    }
    
    private func updateWebView(_ webView: FSWebView) {
        if(webView.selectedBooth != self.selectedBooth){
            webView.selectedBooth = self.selectedBooth
            
            if(self.selectedBooth != nil && self.selectedBooth != "" && self.route == nil){
                webView.evaluateJavaScript("window.selectBooth('\(self.selectedBooth!)');")
            }
            else if(self.route == nil){
                webView.evaluateJavaScript("window.selectBooth(null);")
            }
        }
        
        if(webView.route != self.route){
            webView.route = self.route
            
            if(self.route != nil){
                webView.evaluateJavaScript("window.selectRoute('\(self.route!.from)', '\(self.route!.to)', \(self.route!.exceptInaccessible));")
            }
            else if(self.selectedBooth == nil){
                webView.evaluateJavaScript("window.selectRoute(null, null, false);")
            }
        }
        
        if(webView.currentPosition != self.currentPosition){
            webView.currentPosition = self.currentPosition
            
            if(self.currentPosition != nil){
                let z = self.currentPosition!.z != nil ? "'\(self.currentPosition!.z!)'" : "null"
                let angle = self.currentPosition!.angle != nil ? "\(self.currentPosition!.angle!)" : "null"
                
                webView.evaluateJavaScript("window.setCurrentPosition(\(self.currentPosition!.x), \(self.currentPosition!.y), \(z), \(angle), \(focusOnCurrentPosition));")
            }
            else{
                webView.evaluateJavaScript("window.setCurrentPosition(null, null, null, null, false);")
            }
        }
    }
    
    private func initWebView(_ webView: FSWebView) {
        let fileManager = FileManager.default
        let netReachability = NetworkReachability()
        
        let eventAddress = Helper.getEventAddress(self.url)
        let eventUrl = "https://\(eventAddress)"
        
        let fplanDirectory = Helper.getCacheDirectory().appendingPathComponent("fplan/")
        let directory = fplanDirectory.appendingPathComponent("\(eventAddress)/")
        webViewController.initForExpo(eventUrl, directory.absoluteString)

        let indexPath = directory.appendingPathComponent("index.html")
        let baseUrl = "\(Constants.scheme)://\(directory.path)"
        
        let indexUrlString = selectedBooth != nil && selectedBooth != "" ? baseUrl + "/index.html" + "?\(selectedBooth!)" : baseUrl + "/index.html"
        let indexUrl = URL(string: indexUrlString)
        
        do {
            if(netReachability.checkConnection()){
                if fileManager.fileExists(atPath: fplanDirectory.path){
                    try? fileManager.removeItem(at: fplanDirectory)
                }
                
                try Helper.createHtmlFile(filePath: indexPath, noOverlay: noOverlay, directory: directory, baseUrl: baseUrl, eventId: self.eventId, autoInit: false)
                
                let requestUrl = URLRequest(url: indexUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
                webView.load(requestUrl)
                
                try Helper.updateAllFiles(baseUrl: URL(string: eventUrl), directory: directory){
                    DispatchQueue.main.async {
                        webView.evaluateJavaScript("window.init()")
                    }
                }
            }
            else{
                
                try Helper.createHtmlFile(filePath: indexPath, noOverlay: noOverlay, directory: directory, baseUrl: baseUrl, eventId: self.eventId, autoInit: true)
                
                let requestUrl = URLRequest(url: indexUrl!, cachePolicy: .returnCacheDataElseLoad)
                webView.load(requestUrl)
            }
        } catch {
            print(error)
        }
    }
    
    private func fpReady(_ webView: FSWebView){
        updateWebView(webView)
        self.fpReadyAction?()
    }
    
    private func selectBooth(_ webView: FSWebView, _ boothName: String){
        self.selectedBooth = boothName
    }
    
    private func buildDirection(_ webView: FSWebView, _ direction: Direction){
        self.buildDirectionAction?(direction)
    }
}

@available(iOS 13.0.0, *)
public struct FplanView_Previews: PreviewProvider {
    
    public init(){
        
    }
    
    public static var previews: some View {
        FplanView("https://demo.expofp.com")
    }
}
