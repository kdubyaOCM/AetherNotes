// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AetherNotesUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "AetherNotesUI",
            targets: ["AetherNotesUI"]
        ),
    ],
    dependencies: [
        .package(path: "../AetherNotesCore"),
    ],
    targets: [
        .target(
            name: "AetherNotesUI",
            dependencies: ["AetherNotesCore"],
            path: "Sources/AetherNotesUI",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "AetherNotesUITests",
            dependencies: ["AetherNotesUI"],
            path: "Tests/AetherNotesUITests",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
