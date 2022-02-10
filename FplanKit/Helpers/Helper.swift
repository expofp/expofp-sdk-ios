import Foundation

@available(iOS 13.0.0, *)
class Helper{
    
    public static func getCacheDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public static func updateAllFiles(baseUrl: URL!, directory: URL!) throws {
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
            "packages/master/expofp.js": "expofp.js",
            "packages/master/floorplan.js": "floorplan.js",
            "packages/master/vendors~floorplan.js": "vendors~floorplan.js",
            "packages/master/expofp-overlay.png": "expofp-overlay.png",
            
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
            
            "data/data.js": "data/data.js",
            "data/fp.svg.js": "data/fp.svg.js",
            "data/demo.png": "data/demo.png",
        ]
        
        for(_, path) in paths.enumerated(){
            let url = baseUrl.appendingPathComponent("/" + path.key)
            let filePath = directory.appendingPathComponent(path.value)
            updateFile(url, filePath)
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
</head>
<body>
<div id="floorplan">Loading...</div>
<script src="$expofp_js_url#" crossorigin="anonymous"></script>
<script>
            window.floorplan = new ExpoFP.FloorPlan({
                element: document.querySelector("#floorplan"),
                eventId: "$eventId#",
                noOverlay: true,
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

      function selectRoute(from, to, exceptUnAccessible){
        window.floorplan?.selectRoute(from, to, exceptUnAccessible);
      }

      function selectBooth(name){
        window.floorplan?.selectBooth(name);
      }

      function setCurrentPosition(x, y, focus){
        window.floorplan?.selectCurrentPosition({x: x, y: y}, focus);
      }
        </script>
</body>
</html>
""";
    }
    
    private static func updateFile(_ url: URL, _ filePath: URL){
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath.path, contents: data)
        })
        task.resume()
    }
    
    private static func createDirectory(dirPath: String) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
    }
}

