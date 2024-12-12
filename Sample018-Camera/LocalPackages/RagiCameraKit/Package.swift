// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagiCameraKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "RagiCameraKit",
            targets: ["RagiCameraKit"]
        )
    ],
    targets: [
        .target(
            name: "RagiCameraKit"
        )
    ]
)
