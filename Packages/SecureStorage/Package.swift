// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)