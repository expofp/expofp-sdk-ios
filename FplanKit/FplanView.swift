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
    
    @Binding private var selectedBooth: String?
    
    private let route: Route?
    
    private let currentPosition: BlueDotPoint?
    private let focusOnCurrentPosition: Bool
    
    private let selectBoothAction: ((_ boothName: String) -> Void)?
    private let fpReadyAction: (() -> Void)?
    private let buildDirectionAction: ((_ direction: Direction) -> Void)?
    
    @State private var webViewController = FSWebViewController()
    
    /**
     This function initializes the view.
     Recommended for use in UIKit.
      
     **Parameters:**
     - url: Floor plan URL address in the format https://[expo_name].expofp.com
     - eventId = [expo_name]: Id of the expo
     - noOverlay: True - Hides the panel with information about exhibitors
     - selectBoothAction: Callback to be called after the booth has been select
     - fpReadyAction: Callback to be called after the floor plan has been ready
     - buildDirectionAction: Callback to be called after the route has been built
     */
    public init(_ url: String,
                eventId: String? = nil,
                noOverlay: Bool = true,
                selectBoothAction: ((_ boothName: String) -> Void)? = nil,
                fpReadyAction:(() -> Void)? = nil,
                buildDirectionAction: ((_ direction: Direction) -> Void)? = nil){
        
        let eventAddress = Helper.getEventAddress(url)
        let eventUrl = "https://\(eventAddress)"
        
        self.url = eventUrl
        self.eventId = eventId ?? Helper.getEventId(eventUrl)
        self.noOverlay = noOverlay
        
        self._selectedBooth = Binding.constant(nil)
        
        self.route = nil
        
        self.currentPosition = nil
        self.focusOnCurrentPosition = false
        
        self.selectBoothAction = nil
        self.fpReadyAction = fpReadyAction
        self.buildDirectionAction = buildDirectionAction
    }
    
    
    /**
     This function initializes the view.
     Recommended for use in SwiftUI.
     
     **Parameters:**
     - url: Floor plan URL address in the format https://[expo_name].expofp.com
     - eventId = [expo_name]: Id of the expo
     - noOverlay: True - Hides the panel with information about exhibitors
     - selectedBooth: Booth selected on the floor plan
     - route: Information about the route to be built.
            After the route is built, the buildDirectionAction callback is called.
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
                currentPosition: BlueDotPoint? = nil,
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
        
        self.selectBoothAction = nil
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
        webViewController.wkWebView = webView
        
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
    
    /**
     This function selects a booth on the floor plan.
     
     **Parameters:**
     - boothName: Booth name
     */
    public func selectBooth(_ boothName: String?){
        if(boothName != nil && boothName != "") {
            webViewController.wkWebView?.evaluateJavaScript("window.floorplan?.selectBooth('\(boothName!)');")
        }
        else {
            webViewController.wkWebView?.evaluateJavaScript("window.floorplan?.selectBooth(null);")
        }
    }
    
    /**
     This function starts the process of building a route from one booth to another.
     After the route is built, the buildDirectionAction callback is called.
     
     **Parameters:**
     - route: Route info
     */
    public func buildRoute(_ route: Route?){
        if(route != nil) {
            webViewController.wkWebView?.evaluateJavaScript("window.floorplan?.selectRoute('\(route!.from)', '\(route!.to)', \(route!.exceptInaccessible));")
        }
        else {
            webViewController.wkWebView?.evaluateJavaScript("window.floorplan?.selectRoute(null, null, false);")
        }
    }
    
    /**
     This function sets a blue-dot point.
     
     **Parameters:**
     - position: Coordinates.
     - focus: True - focus the floor plan display on the passed coordinates.
     */
    public func setCurrentPosition(_ position: BlueDotPoint?, _ focus: Bool = false){
        if(position != nil) {
            let z = position!.z != nil ? "'\(position!.z!)'" : "null"
            let angle = position!.angle != nil ? "\(position!.angle!)" : "null"
            
            webViewController.wkWebView?.evaluateJavaScript(
                "window.floorplan?.selectCurrentPosition({ x: \(position!.x), y: \(position!.y), z: \(z), angle: \(angle) }, \(focus));")
        }
        else {
            webViewController.wkWebView?.evaluateJavaScript("window.floorplan?.selectCurrentPosition(null, false);")
        }
    }
    
    /**
     This function clears the floor plan
     */
    public func clear() {
        selectBooth(nil)
        buildRoute(nil)
        setCurrentPosition(nil)
    }
    
    private func updateWebView(_ webView: FSWebView) {
        if(webViewController.selectedBooth != self.selectedBooth){
            webViewController.selectedBooth = self.selectedBooth
            
            if(self.selectedBooth != nil && self.selectedBooth != "" && self.route == nil){
                selectBooth(self.selectedBooth)
            }
            else if(self.route == nil){
                selectBooth(nil)
            }
        }
        
        if(webViewController.route != self.route){
            webViewController.route = self.route
            
            if(self.route != nil){
                buildRoute(self.route)
            }
            else if(self.selectedBooth == nil){
                buildRoute(nil)
            }
        }
        
        if(webViewController.currentPosition != self.currentPosition){
            webViewController.currentPosition = self.currentPosition
            
            if(self.currentPosition != nil){
                setCurrentPosition(self.currentPosition)
            }
            else{
                setCurrentPosition(nil)
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
        webViewController.setExpo(eventUrl, directory.absoluteString)

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
        self.selectBoothAction?(boothName)
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
