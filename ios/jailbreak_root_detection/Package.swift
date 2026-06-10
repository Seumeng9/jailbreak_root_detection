// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "jailbreak_root_detection",
    platforms: [
        .iOS("11.0")
    ],
    products: [
        .library(name: "jailbreak-root-detection", targets: ["jailbreak_root_detection"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/securing/IOSSecuritySuite.git", .upToNextMinor(from: "1.9.10"))
    ],
    targets: [
        .target(
            name: "jailbreak_root_detection",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "IOSSecuritySuite", package: "IOSSecuritySuite")
            ]
        )
    ]
)
