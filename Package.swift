// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Version",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "Version",
            targets: ["Version"]),
    ],
    targets: [
        .target(
            name: "Version"),
        .testTarget(
            name: "VersionTests",
            dependencies: ["Version"]),
    ]
)
