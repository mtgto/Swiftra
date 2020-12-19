// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swiftra",
    products: [
        .library(
            name: "Swiftra",
            targets: ["Swiftra"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", "2.0.0"..<"3.0.0")
    ],
    targets: [
        .target(
            name: "Swiftra",
            dependencies: [.product(name: "NIO", package: "swift-nio"), .product(name: "NIOHTTP1", package: "swift-nio")]),
        .target(
            name: "Example",
            dependencies: ["Swiftra"]),
        .testTarget(
            name: "SwiftraTests",
            dependencies: ["Swiftra"]),
    ]
)
