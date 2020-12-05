// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftApmAgent",
    platforms: [
        .macOS(SupportedPlatform.MacOSVersion.v10_11),
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "SwiftApmAgent",
            targets: ["SwiftApmAgent"]),
    ],
    targets: [
        .target(
            name: "SwiftApmAgent",
            dependencies: []),
        .testTarget(
            name: "SwiftApmAgentTests",
            dependencies: ["SwiftApmAgent"]),
    ]
)
