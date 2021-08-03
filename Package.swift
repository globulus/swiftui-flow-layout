// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftUIFlowLayout",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
        ],
    products: [
        .library(
            name: "SwiftUIFlowLayout",
            targets: ["SwiftUIFlowLayout"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftUIFlowLayout",
            dependencies: []),
    ]
)
