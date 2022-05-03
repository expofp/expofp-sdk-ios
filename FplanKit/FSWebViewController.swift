import Foundation
import WebKit
import UniformTypeIdentifiers

class FSWebViewController: UIViewController, WKURLSchemeHandler, WKNavigationDelegate {
    private var expoCacheDirectory: String = ""
    private var expoUrl: String = ""
    
    public func initForExpo(_ expoUrl: String, _ expoCacheDirectory: String){
        self.expoUrl = expoUrl
        self.expoCacheDirectory = expoCacheDirectory
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("###### FSWebViewController #1 url: \(navigationAction.request.url)")
        
        if(navigationAction.navigationType == WKNavigationType.other){
            decisionHandler(.allow)
            return
        }
        
        if let url = navigationAction.request.url {
            if url.scheme == "https" || url.scheme == "http" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        print("###### FSWebViewController #2 urlSchemeTask.request.url: \(urlSchemeTask.request.url) ")
        
        if(urlSchemeTask.request.url == nil || urlSchemeTask.request.url?.scheme != Constants.scheme){
            return
        }
        
        var realPath = urlSchemeTask.request.url!.absoluteString.replacingOccurrences(of: Constants.scheme, with: "file")
        if let index = realPath.firstIndex(of: "?"){
            realPath = String(realPath[..<index])
        }
        
        print("###### FSWebViewController #2 realPath: \(realPath) ")
        
        let realUrl = URL.init(string: realPath)
        print("###### FSWebViewController #2 realUrl: \(realUrl) ")
        
        if(!FileManager.default.fileExists(atPath: realUrl!.path)){
            let dir = realUrl!.deletingLastPathComponent().path
            print("###### FSWebViewController #2 dir: \(dir)")
            
            try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            
            print("###### FSWebViewController #2 FILE NOT FOUND")
            print("###### FSWebViewController #2 expoCacheDirectory: \(expoCacheDirectory)")
            
            let pth = realPath.lowercased().replacingOccurrences(of: expoCacheDirectory.lowercased(), with: "")
            print("###### FSWebViewController #2 pth: \(pth)")
            
            let reqUrl = expoUrl + pth
            print("###### FSWebViewController #2 reqUrl: \(reqUrl)")
            
            Helper.updateFile(URL.init(string: reqUrl)!, realUrl!){
                self.setData(urlSchemeTask: urlSchemeTask, dataURL: realUrl!)
            }
        }
        else {
            setData(urlSchemeTask: urlSchemeTask, dataURL: realUrl!)
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("###### FSWebViewController #3 urlSchemeTask.request.url: \(urlSchemeTask.request.url) ")
    }
    
    private func setData(urlSchemeTask: WKURLSchemeTask, dataURL: URL){
        print("###### FSWebViewController #4 setData, dataURL: \(dataURL) ")
        
        let data = try? Data(contentsOf: dataURL)
        if(data == nil) {
            print("###### FSWebViewController #4 setData: data == nil ")
            
            let urlResponse = URLResponse(url: urlSchemeTask.request.url!, mimeType: nil, expectedContentLength: -1, textEncodingName: "gzip")
            urlSchemeTask.didReceive(urlResponse)
            urlSchemeTask.didFinish()
            return
        }
        
        let mimeType = dataURL.mimeType()
        print("###### FSWebViewController #2 mimeType: \(mimeType) ")
        
        let urlResponse = URLResponse(url: urlSchemeTask.request.url!, mimeType: mimeType, expectedContentLength: data!.count, textEncodingName: "gzip")
        urlSchemeTask.didReceive(urlResponse)
        
        print("###### FSWebViewController #2 data!.count: \(data!.count) ")
        
        urlSchemeTask.didReceive(data!)
        urlSchemeTask.didFinish()
    }
}

