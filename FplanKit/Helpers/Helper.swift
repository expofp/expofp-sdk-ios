import Foundation

@available(iOS 13.0.0, *)
struct Helper{
    public static func getEventAddress(_ url: String) -> String {
        func getWithoutParams (_ url: String, _ delimiter: Character) -> String {
            if let sIndex = url.firstIndex(of: delimiter){
                return String(url[...url.index(before: sIndex)])
            }
            else{
                return url
            }
        }
        
        let mainPart = url.replacingOccurrences(of: "https://www.", with: "").replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://www.", with: "").replacingOccurrences(of: "http://", with: "")
        
        let result = getWithoutParams(getWithoutParams(mainPart, "/"), "?")
        return result
    }
    
    public static func getEventId(_ url: String) -> String {
        let eventAddress = getEventAddress(url)
        if let index = eventAddress.firstIndex(of: ".") {
            return String(eventAddress[...eventAddress.index(index, offsetBy: -1)])
        }
        else{
            return ""
        }
    }
    
    public static func createHtmlFile(filePath: URL, noOverlay: Bool, directory: URL, baseUrl: String, eventId: String, autoInit: Bool) throws {
        let fileManager = FileManager.default
        let html = Helper.getIndexHtml()
            .replacingOccurrences(of: "$url#", with: baseUrl)
            .replacingOccurrences(of: "$eventId#", with: eventId)
            .replacingOccurrences(of: "$noOverlay#", with: String(noOverlay))
            .replacingOccurrences(of: "$autoInit#", with: String(autoInit))
        
        if !fileManager.fileExists(atPath: filePath.path){
            try! fileManager.createDirectory(atPath: directory.path, withIntermediateDirectories: true, attributes: nil)
        }
        try html.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
    }
    
    public static func getCacheDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public static func updateAllFiles(baseUrl: URL!, directory: URL!, callback: @escaping (() -> Void)) throws {
        let dirs:[String] = [
            directory.appendingPathComponent("fonts/").path,
            directory.appendingPathComponent("vendor/fa/css/").path,
            directory.appendingPathComponent("vendor/fa/webfonts/").path,
            directory.appendingPathComponent("vendor/perfect-scrollbar/css/").path,
            directory.appendingPathComponent("vendor/sanitize-css/").path,
            directory.appendingPathComponent("locales/").path,
            directory.appendingPathComponent("data/").path
        ]
        
        for(_, dirPath) in dirs.enumerated(){
            try createDirectory(dirPath: dirPath)
        }

        let paths: [String: String] = [
            "data/fp.svg.js": "data/fp.svg.js",
            "data/data.js": "data/data.js",
            "data/wf.data.js": "data/wf.data.js",
            "data/demo.png": "data/demo.png",
            
            "packages/master/expofp.js": "expofp.js",
            "packages/master/floorplan.js": "floorplan.js",
            "packages/master/vendors~floorplan.js": "vendors~floorplan.js",
            "packages/master/expofp-overlay.png": "expofp-overlay.png",
            "packages/master/free.js": "free.js",
            "packages/master/slider.js": "slider.js",
            
            "packages/master/fonts/oswald-v17-cyrillic_latin-300.woff2": "fonts/oswald-v17-cyrillic_latin-300.woff2",
            "packages/master/fonts/oswald-v17-cyrillic_latin-500.woff2": "fonts/oswald-v17-cyrillic_latin-500.woff2",
            
            "packages/master/vendor/fa/css/fontawesome-all.min.css": "vendor/fa/css/fontawesome-all.min.css",
            
            "packages/master/vendor/fa/webfonts/fa-brands-400.woff2": "vendor/fa/webfonts/fa-brands-400.woff2",
            "packages/master/vendor/fa/webfonts/fa-light-300.woff2": "vendor/fa/webfonts/fa-light-300.woff2",
            "packages/master/vendor/fa/webfonts/fa-regular-400.woff2": "vendor/fa/webfonts/fa-regular-400.woff2",
            "packages/master/vendor/fa/webfonts/fa-solid-900.woff2": "vendor/fa/webfonts/fa-solid-900.woff2",
            
            "packages/master/vendor/perfect-scrollbar/css/perfect-scrollbar.css": "vendor/perfect-scrollbar/css/perfect-scrollbar.css",
            
            "packages/master/vendor/sanitize-css/sanitize.css": "vendor/sanitize-css/sanitize.css",
            
            "packages/master/locales/ar.json": "locales/ar.json",
            "packages/master/locales/de.json": "locales/de.json",
            "packages/master/locales/es.json": "locales/es.json",
            "packages/master/locales/fr.json": "locales/fr.json",
            "packages/master/locales/it.json": "locales/it.json",
            "packages/master/locales/ko.json": "locales/ko.json",
            "packages/master/locales/nl.json": "locales/nl.json",
            "packages/master/locales/pt.json": "locales/pt.json",
            "packages/master/locales/ru.json": "locales/ru.json",
            "packages/master/locales/sv.json": "locales/sv.json",
            "packages/master/locales/th.json": "locales/th.json",
            "packages/master/locales/tr.json": "locales/tr.json",
            "packages/master/locales/vi.json": "locales/vi.json",
            "packages/master/locales/zh.json": "locales/zh.json",
        ]
        
        var count = 0
        
        for(_, path) in paths.enumerated(){
            let url = baseUrl.appendingPathComponent("/" + path.key)
            let filePath = directory.appendingPathComponent(path.value)
            updateFile(url, filePath){
                count += 1
                if(count == paths.count){
                    callback()
                }
            }
        }
    }
    
    
    public static func getIndexHtml() -> String {
        return
"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, width=device-width" />
    <style>
      html,
      body {
        touch-action: none;
        margin: 0;
        padding: 0;
        height: 100%;
        width: 100%;
        background: #ebebeb;
        position: fixed;
        overflow: hidden;
      }
      @media (max-width: 820px) and (min-width: 500px) {
        html {
          font-size: 13px;
        }
      }
    </style>
    <style>
      .lds-grid {
        top: 42vh;
        margin: 0 auto;
        display: block;
        position: relative;
        width: 64px;
        height: 64px;
      }

      .lds-grid div {
        position: absolute;
        width: 13px;
        height: 13px;
        background: #aaa;
        border-radius: 50%;
        /* border: solid 1px #fff; */
        animation: lds-grid 1.2s linear infinite;
      }

      .lds-grid div:nth-child(1) {
        top: 6px;
        left: 6px;
        animation-delay: 0s;
      }

      .lds-grid div:nth-child(2) {
        top: 6px;
        left: 26px;
        animation-delay: -0.4s;
      }

      .lds-grid div:nth-child(3) {
        top: 6px;
        left: 45px;
        animation-delay: -0.8s;
      }

      .lds-grid div:nth-child(4) {
        top: 26px;
        left: 6px;
        animation-delay: -0.4s;
      }

      .lds-grid div:nth-child(5) {
        top: 26px;
        left: 26px;
        animation-delay: -0.8s;
      }

      .lds-grid div:nth-child(6) {
        top: 26px;
        left: 45px;
        animation-delay: -1.2s;
      }

      .lds-grid div:nth-child(7) {
        top: 45px;
        left: 6px;
        animation-delay: -0.8s;
      }

      .lds-grid div:nth-child(8) {
        top: 45px;
        left: 26px;
        animation-delay: -1.2s;
      }

      .lds-grid div:nth-child(9) {
        top: 45px;
        left: 45px;
        animation-delay: -1.6s;
      }

      @keyframes lds-grid {
        0%,
        100% {
          opacity: 1;
        }

        50% {
          opacity: 0.5;
        }
      }
    </style>
</head>
<body>
<div id="floorplan">
    <div class="lds-grid">
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
    </div>
</div>
<script>
      function initFloorplan() {
        window.floorplan = new ExpoFP.FloorPlan({
          element: document.querySelector("#floorplan"),
          dataUrl: "$url#/data/",
          eventId: "$eventId#",
          noOverlay: $noOverlay#,
          onBoothClick: e => {
             window.webkit?.messageHandlers?.onBoothClickHandler?.postMessage(e.target.name);
          },
          onFpConfigured: () => {
             window.webkit?.messageHandlers?.onFpConfiguredHandler?.postMessage("FLOOR PLAN CONFIGURED");
          },
          onDirection: (e) => {
             window.webkit?.messageHandlers?.onDirectionHandler?.postMessage(JSON.stringify(e));
          }
        });
      }

      function init() {
        const expofpScript = document.createElement("script");
        expofpScript.src = "$url#/expofp.js";
        expofpScript.crossorigin = "anonymous";
        expofpScript.onload = function() {
            initFloorplan();
        };

        document.body.appendChild(expofpScript);
      }

      function selectRoute(from, to, exceptUnAccessible) {
        window.floorplan?.selectRoute(from, to, exceptUnAccessible);
      }

      function selectBooth(name) {
        window.floorplan?.selectBooth(name);
      }

      function setCurrentPosition(x, y, z, angle, focus) {
        if (x == null || y == null) {
          window.floorplan?.selectCurrentPosition(null, focus);
        } else {
          window.floorplan?.selectCurrentPosition({ x: x, y: y, z: z, angle: angle }, focus);
        }
      }

      function autoInit() {
        if($autoInit#){
            init();
        }
      }
      autoInit();
    </script>
</body>
</html>
""";
    }
    
    public static func updateFile(_ url: URL, _ filePath: URL, callback: @escaping (()->Void)){
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath.path, contents: data)
            callback()
        })
        task.resume()
    }
    
    private static func createDirectory(dirPath: String) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
    }
}

