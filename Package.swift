// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CancellablePromiseKit",
    products: [
        .library(
            name: "CancellablePromiseKit",
            targets: ["CancellablePromiseKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mxcl/PromiseKit", .upToNextMajor(from: "6.18.0"))
    ],
    targets: [
        .target(
            name: "CancellablePromiseKit",
            dependencies: [
                "PromiseKit"
            ]),
        .testTarget(
            name: "CancellablePromiseKitTests",
            dependencies: ["CancellablePromiseKit"]),
    ]
)
