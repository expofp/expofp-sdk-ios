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
    @State var url: String = "https://demo.expofp.com"
    @State var selectedBooth: String? = nil

    var body: some Scene {
        WindowGroup {
            //noOverlay - Hides the panel with information about exhibitors
            FplanView(url, noOverlay: false, selectedBooth: $selectedBooth)
        }
    }
}
```
