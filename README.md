# ExpoFP Fplan - iOS library for displaying expo plans

Create your expo plan on the website https://expofp.com then use the URL of the created expo plan when you working with the library

![WhatsApp Image 2022-01-05 at 22 51 07](https://user-images.githubusercontent.com/60826376/148282339-c53466a3-4b65-42ba-ba12-54156f77497f.jpeg)

## Table of Contents
* [Version for Android](#version-for-android)
* [Usage example](#usage-example)
* [3.0.1 version](#3.0.1)
  * [What's New](#3.0.1-what-is-new)
  * [Installation](#3.0.1-installation)
  * [Usage](#3.0.1-usage)
  * [Functions](#3.0.1-functions)
  * [Events](#3.0.1-events)
  * [Navigation](#3.0.1-navigation)
  * [CrowdConnected location provider](#3.0.1-cc-navigation)
  * [IndoorAtlas location provider](#3.0.1-ia-navigation)

## Version for Android<a id='version-for-android'></a>

https://github.com/expofp/expofp-android-sdk

## Usage example<a id='usage-example'></a>

https://github.com/expofp/expofp-swiftui-example

## 3.0.1 version<a id='3.0.1'></a>

### What's New in ExpoFP Fplan version 3.0.1<a id='3.0.1-what-is-new'></a>

Navigation from CrowdConnected and IndoorAtlas has been added.

### Installation<a id='3.0.1-installation'></a>

Cocoapods:

```swift
pod 'ExpoFpFplan', '3.0.1'
```

### Usage<a id='3.0.1-usage'></a>

```swift
import SwiftUI
import ExpoFpFplan

@main
struct FplanApp: App {
    
    var fplanView = FplanView()
    
    var body: some Scene {
        WindowGroup {
            VStack
            {
                fplanView.onAppear{
                    fplanView.load("https://demo.expofp.com")
                }
                .onDisappear {
                    fplanView.destoy()
                }
            }
        }
    }
}
```

Stop FplanView.  
After you finish working with FplanView, you need to stop it.  
To do this, you need to call the 'destroy' function:  

```swift
fplanView.destoy()
```

### Functions<a id='3.0.1-functions'></a>

Open plan:

```swift
fplanView.load("https://demo.expofp.com")
```

Stop FplanView:

```swift
fplanView.destoy()
```

Select booth:

```swift
fplanView.selectBooth("720")
```

Build route:

```swift
fplanView.buildRoute(Route(from: "720", to: "751", exceptInaccessible: false))
```

Set current position(Blue-dot):

```swift
fplanView.setCurrentPosition(BlueDotPoint(x: 22270, y: 44900), true)
```

Clear floor plan:

```swift
fplanView.clear()
```

### Events<a id='3.0.1-events'></a>

Floor plan ready event:

```swift
import SwiftUI
import ExpoFpFplan

@main
struct FplanApp: App {
    
    var fplanView = FplanView()
    
    var body: some Scene {
        WindowGroup {
            VStack
            {
                fplanView.onFpReady{
                    print("[Fplan] - fpReady")
                }
                .onAppear{
                    fplanView.load("https://demo.expofp.com")
                }
                .onDisappear {
                    fplanView.destoy()
                }
            }
        }
    }
}
```

Select booth event:

```swift
import SwiftUI
import ExpoFpFplan

@main
struct FplanApp: App {
    
    var fplanView = FplanView()
    
    var body: some Scene {
        WindowGroup {
            VStack
            {
                fplanView.onBoothClick{ boothName in
                    print("[Fplan] - select booth \(boothName)")
                }
                .onAppear{
                    fplanView.load("https://demo.expofp.com")
                }
                .onDisappear {
                    fplanView.destoy()
                }
            }
        }
    }
}
```

Route create event:

```swift
import SwiftUI
import ExpoFpFplan

@main
struct FplanApp: App {
    
    var fplanView = FplanView()
    
    var body: some Scene {
        WindowGroup {
            VStack
            {
                fplanView.onBuildDirection { direction in
                    print(direction)
                }
                .onAppear{
                    fplanView.load("https://demo.expofp.com")
                }
                .onDisappear {
                    fplanView.destoy()
                }
            }
        }
    }
}
```

### Navigation<a id='3.0.1-navigation'></a>

There are 2 ways to use navigation in FplanView. The first way is to explicitly specify the provider. In this case, FplanView will start and stop the LocationProvider on its own.

```swift
let locationProvider: LocationProvider = ...
fplanView.load(state.url, noOverlay: false, locationProvider: locationProvider)
```

The second way is to run the GlobalLocationProvider when the program starts:

```swift
let locationProvider: LocationProvider = ...
GlobalLocationProvider.initialize(locationProvider)
GlobalLocationProvider.start()
```

Using the GlobalLocationProvider in the FplanView:

```swift
fplanView.load(state.url, noOverlay: false, useGlobalLocationProvider: true)
```

When the program terminates, the GlobalLocationProvider must also be stopped:

```swift
GlobalLocationProvider.stop();
```

### CrowdConnected location provider<a id='3.0.1-cc-navigation'></a>

Сocoapods:

```swift
pod 'ExpoFpCrowdConnected', '3.0.1'
```

Import:

```swift
import ExpoFpCrowdConnected
```

Initialization:

```swift
let locationProvider: LocationProvider = CrowdConnectedProvider(Settings("APP_KEY", "TOKEN", "SECRET"))
```

Aliases:

```swift
let settings = ExpoFpCrowdConnected.Settings("APP_KEY", "TOKEN", "SECRET")
settings.addAlias("KEY_1", "VALUE_1")
settings.addAlias("KEY_2", "VALUE_2")
let locationProvider: LocationProvider = CrowdConnectedProvider(settings)
```

### IndoorAtlas location provider<a id='3.0.1-ia-navigation'></a>

Сocoapods:

```swift
pod 'ExpoFpIndoorAtlas', '3.0.1'
```

Import:

```swift
import ExpoFpIndoorAtlas
```

Initialization:

```swift
let locationProvider: LocationProvider = IndoorAtlasProvider(Settings("API_KEY", "API_SECRET_KEY"))
```
