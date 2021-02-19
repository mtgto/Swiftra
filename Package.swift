// swift-tools-version:5.3
// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import PackageDescription

let package = Package(
    name: "Swiftra",
    platforms: [
        .macOS(.v10_14), .iOS(.v13),
    ],
    products: [
        .library(
            name: "Swiftra",
            targets: ["Swiftra"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", "2.26.0"..<"3.0.0")
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
    ],
    swiftLanguageVersions: [.v5]
)
