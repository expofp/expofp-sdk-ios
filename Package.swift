// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExpoFP",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ExpoFP",
            targets: ["ExpoFP"]),
    ],
    targets: [
        .binaryTarget(
            name: "ExpoFP",
            path: "ExpoFP.xcframework"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
