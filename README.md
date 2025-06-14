<img src="https://expofp.com/template/img/site-header-logo-inverse.png" width="350"/>

[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ExpoFP.svg)](https://cocoapods.org/pods/ExpoFP)
[![Platform](https://img.shields.io/badge/Platforms-%20iOS%20|%20iPadOS-lightgrey.svg)](https://expofp.github.io/expofp-mobile-sdk/ios-sdk/)

ExpoFP is a binary package (XCFramework) to show and manage floor plans.

## 1 Installation
### 1.1 Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/expofp/expofp-sdk-ios", from: "5.0.0"),
]
```

and then as a dependency for the Package target utilizing **ExpoFP**:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "ExpoFP", package: "expofp-sdk-ios"),
    ]
),
```

### 1.2 CocoaPods

```
spec.dependency 'ExpoFP', '~>5.0.0'
```

## 2 Usage
### 2.1 Load a plan

```swift
let expoKey = "YourExpoKey"
let presenter = ExpoFpPlan.createPlanPresenter(with: .expoKey(expoKey))
```

### 2.2 Load a plan with additional tools

```swift
let expoKey = "YourExpoKey"
let additionalParams = [URLQueryItem(name: "noOverlay", value: "true")]
let locationProvider: IExpoFpLocationProvider = YourLocationProvider() // or Golbal location provider
let messageListener: IExpoFpPlanMessageListener = YourMessageListener()

let presenter = ExpoFpPlan.createPlanPresenter(
    with: .expoKey(expoKey),
    additionalParams: additionalParams,
    locationProvider: locationProvider,
    messageListener: messageListener
)
```

### 2.3 Display loaded plan

```swift
let swiftUIView = presenter.getView()
let uiKitViewController = presenter.getViewController()
```

## 3 Preparing a plan in advance

### 3.1.1 Download a plan for later use

Plan will be downloaded into cache directory in user domain mask.

```swift
let expoKey = "YourExpoKey"
let downloadedPlanResult = await ExpoFpPlan.downloader.downloadPlan(withExpoKey: expoKey) // Also awailable with completion
let downloadedPlanInfo = try downloadedPlanResult.get()

let presenter = ExpoFpPlan.createPlanPresenter(with: .downloadedPlanInfo(downloadedPlanInfo))
```

### 3.1.2 Get info about all downloaded plans

```swift
let downloadedPlansInfo = await ExpoFpPlan.downloader.getDownloadedPlansInfo() // Also awailable with completion
```

### 3.1.3 Delete downloaded plans

```swift
ExpoFpPlan.downloader.removeDownloadedPlan(with: downloadedPlanInfo)
or
ExpoFpPlan.downloader.removeAllDownloadedPlans()
```

### 3.2.1 Preload a plan for later use

All preloaded plans retain their state during app lifecycle and release after app is terminated.

```swift
let expoKey = "YourExpoKey"
let preloadedPlanInfo = ExpoFpPlan.preloader.preloadPlan(with: .expoKey(expoKey))
or
let preloadedPlanInfo = ExpoFpPlan.preloader.preloadPlan(with: .downloadedPlanInfo(downloadedPlanInfo))

let presenter = ExpoFpPlan.preloader.getPreloadedPlanPresenter(with: preloadedPlanInfo)
```

### 3.2.2 Get info about all preloaded plans

```swift
let preloadedPlansInfo = await ExpoFpPlan.preloader.getPreloadedPlansInfo() // Also awailable with completion
```

### 3.2.3 Delete preloaded plans

```swift
ExpoFpPlan.preloader.disposePreloadedPlan(with: preloadedPlanInfo)
or
ExpoFpPlan.preloader.removeAllPreloadedPlans()
```

## 4 Location provider usage

To use Location Provider you **must add** `NSLocationWhenInUseUsageDescription` key in your app `Info.plist` file.<br>
To use Location Provider in background you **must also add** `NSLocationAlwaysUsageDescription` key in your app `Info.plist` file.

### 4.1 Individual location provider

You need to import [Indoor Atlas](https://github.com/expofp/expofp-indooratlas-ios) or [Crowd Connected](https://github.com/expofp/expofp-crowdconnected-ios) and use their documentation to initialize location provider.<br>
You can use your own location provider after confirming it to `IExpoFpLocationProvider` protocol.<br>
Plan will call `startUpdatingLocation()` when it appers and `stopUpdatingLocation()` when it disappears.

### 4.2 Global location provider

To use Global location provider you need to set location provider to `ExpoFpPlan.globalLocationProvider.sharedProvider` instance.<br>
Global location provider is not set to a plan automatically, but you can set `ExpoFpPlan.globalLocationProvider` to a plan presenter instead of shared instance.<br>
Plan will call `startUpdatingLocation()` when it appers.<br>
**Important:** Plan will not call `stopUpdatingLocation()` when it disappears.

## 5 Plan management

During plan lifecycle you can use `presenter` to:

* Apply new additional params, location provider, message listener;
* Reload plan with all previously applied params;
* Monitor loading, initialization and errors via `presenter.planStatusPublisher`;
* Zoom, select booth or category, build routes and many more.

Feel free to check out our detailed instructions at [expofp.github.io](https://expofp.github.io/expofp-mobile-sdk/ios-sdk/)

