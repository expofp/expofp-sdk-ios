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
    
    let fplanView: FplanView
    
    init() {
        func fplanReadyHandler(){
            //Some code
        }
        
        func boothSelectionHandler(boothName: String){
            //Some code
        }
        
        func routeBuildHandler(route: Route){
            //Some code
        }
        
        //Specify the url address of your expo plan
        fplanView = FplanView("https://wayfinding.expofp.com",
                              fplanReadyHandler: fplanReadyHandler,
                              boothSelectionHandler: boothSelectionHandler,
                              routeBuildHandler: routeBuildHandler)
    }
    
    func selectBooth(_ boothName: String) {
        fplanView.selectBooth(boothName)
    }
    
    func selectBooth(_ from: String, _ to: String, _ exceptUnaccessible: Bool) {
        fplanView.buildRoute(from, to, exceptUnaccessible)
    }
    
    var body: some Scene {
        WindowGroup {
            fplanView
        }
    }
}
```

## Functions

Select booth:

```swift
fplanView.selectBooth("1306")
```

Buid route:

```swift
fplanView.buildRoute("1306", "2206")
```

## Events


### Handling the plan load event

Handler:

```swift
func fplanReadyHandler(){
    //Some code
}
```

Init:

```swift
fplanView = FplanView("https://wayfinding.expofp.com", fplanReadyHandler: fplanReadyHandler)
```


### Handling the booth selection event

Handler:

```swift
func boothSelectionHandler(boothName: String){
    //Some code
}
```

Init:

```swift
fplanView = FplanView("https://wayfinding.expofp.com", boothSelectionHandler: boothSelectionHandler)
```


### Route creation event handling

Handler:

```swift
func routeBuildHandler(route: Route){
    //Some code
}
```

Init:

```swift
fplanView = FplanView("https://wayfinding.expofp.com", routeBuildHandler: routeBuildHandler)
```

