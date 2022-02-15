# ExpoFP Fplan - iOS library for displaying expo plans

Create your expo plan on the website https://expofp.com then use the URL of the created expo plan when you working with the library

![WhatsApp Image 2022-01-05 at 22 51 07](https://user-images.githubusercontent.com/60826376/148282339-c53466a3-4b65-42ba-ba12-54156f77497f.jpeg)

## Version for Android

https://github.com/expofp/expofp-android-sdk

## Usage example

https://github.com/expofp/expofp-swiftui-example

## Add to project

### Cocoapods

```swift
pod 'FplanKit'
```

## Usage

```swift
import SwiftUI
import FplanKit

@main
struct FplanApp: App {
    
    @State var url: String = "https://wayfinding.expofp.com"
    @State var selectedBooth: String? = nil
    @State var route: Route? = nil
    @State var currentPosition: Point? = nil
    
    func selectBooth() {
        self.currentPosition = nil
        self.route = nil
        self.selectedBooth = "1306"
    }
    
    func buildRoute() {
        self.selectedBooth = nil
        self.currentPosition = Point(x: 2870, y: 1780)
        self.route = Route(from: "1306", to: "2206", exceptInaccessible: false)
    }
    
    func directionReady(direction: Direction){
        //Some code
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom)
            {
                FplanView(url, selectedBooth: $selectedBooth, route: route, currentPosition: currentPosition, buildDirectionAction: directionReady)
                HStack
                {
                    Spacer()
                    Button("Select booth", action: selectBooth)
                    Spacer()
                    Button("Build route", action: buildRoute)
                    Spacer()
                }
            }
        }
    }
}
```
