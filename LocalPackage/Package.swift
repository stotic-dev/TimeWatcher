// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TimeWatcherLocalPackage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "TimeWatcherCore", targets: ["TimeWatcherCore"]),
        .library(name: "TimeWatcherFeature", targets: ["TimeWatcherFeature"]),
        .library(name: "TimeWatcherTestSupport", targets: ["TimeWatcherTestSupport"]),
    ],
    dependencies: [
        .package(path: "../TimeWatcherExternalResouce"),
    ],
    targets: [
        .target(
            name: "TimeWatcherCore",
            path: "Sources/TimeWatcherCore"
        ),
        .target(
            name: "TimeWatcherFeature",
            dependencies: [
                "TimeWatcherCore",
                .product(name: "TimeWatcherExternalResouce", package: "TimeWatcherExternalResouce"),
            ],
            path: "Sources/TimeWatcherFeature"
        ),
        .target(
            name: "TimeWatcherTestSupport",
            dependencies: ["TimeWatcherCore"],
            path: "Sources/TimeWatcherTestSupport"
        ),
        .testTarget(
            name: "TimeWatcherCoreTests",
            dependencies: ["TimeWatcherCore", "TimeWatcherTestSupport"],
            path: "Tests/TimeWatcherCoreTests"
        ),
    ]
)
