<img src="https://expofp.com/template/img/site-header-logo-inverse.png" width="350"/>

[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ExpoFP.svg)](https://cocoapods.org/pods/ExpoFP)
[![Platform](https://img.shields.io/badge/Platforms-%20iOS%20|%20iPadOS-lightgrey.svg)](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/)

ExpoFP is a binary package (XCFramework) to show and manage floor plans<br>
Full usage instructions on [expofp.github.io](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/)

## Installation
### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/expofp/expofp-sdk-ios", from: "5.4.1"),
]
```

and add it to your target’s dependencies

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "ExpoFP", package: "expofp-sdk-ios"),
    ]
),
```

### CocoaPods

```
target 'MyApp' do
    pod 'ExpoFP', '~> 5.4.1'
end
```

## Quick Guide
### Load a plan

```swift
let expoKey = "YourExpoKey"
let presenter = ExpoFpPlan.createPlanPresenter(with: .expoKey(expoKey))
```

### Present in UIKit

```swift
let planController = presenter.getViewController()
yourViewController.pushViewController(planController, animated: true)
```

### Present in SwiftUI

```swift
var body: some View {
    presenter.getView()
}
```
### Download a plan

```swift
let expoKey = "YourExpoKey"
let downloadedPlanResult = await ExpoFpPlan.downloader.downloadPlan(withExpoKey: expoKey) // Also awailable with completion
let downloadedPlanInfo = try downloadedPlanResult.get()

let presenter = ExpoFpPlan.createPlanPresenter(with: .downloadedPlanInfo(downloadedPlanInfo))
```

### Preload a plan

```swift
let expoKey = "YourExpoKey"
let preloadedPlanInfo = ExpoFpPlan.preloader.preloadPlan(with: .expoKey(expoKey))
or
let preloadedPlanInfo = ExpoFpPlan.preloader.preloadPlan(with: .downloadedPlanInfo(downloadedPlanInfo))

let presenter = ExpoFpPlan.preloader.getPreloadedPlanPresenter(with: preloadedPlanInfo)
```

### Manage a plan

* Apply additional params, location provider, message listener
* Reload plan with new or previously applied settings
* Monitor loading, initialization and errors via `presenter.planStatusPublisher`
* Zoom, select booth or category, build routes, listen events and many more

Feel free to check out our detailed instructions on [expofp.github.io](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/)

