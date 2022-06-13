// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "UniversalMailComposer",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "UniversalMailComposer",
            targets: ["UniversalMailComposer"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "UniversalMailComposer",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "UniversalMailComposerTests",
            dependencies: ["UniversalMailComposer"],
            path: "Tests"
        ),
    ]
)
