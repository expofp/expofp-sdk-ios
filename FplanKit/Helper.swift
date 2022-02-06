import Foundation


public class Helper{
    
    public static func GetIndexHtml() -> String {
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
<script src="$url#/packages/master/expofp.js" crossorigin="anonymous"></script>
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
}
