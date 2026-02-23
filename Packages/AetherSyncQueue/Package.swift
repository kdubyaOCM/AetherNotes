// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AetherSyncQueue",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "AetherSyncQueue",
            targets: ["AetherSyncQueue"]
        ),
    ],
    targets: [
        .target(
            name: "AetherSyncQueue",
            path: "Sources/AetherSyncQueue",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "AetherSyncQueueTests",
            dependencies: ["AetherSyncQueue"],
            path: "Tests/AetherSyncQueueTests",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
