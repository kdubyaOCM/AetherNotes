// swift-tools-version: 5.9
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
            path: "Sources/AetherNotesUI"
        ),
        .testTarget(
            name: "AetherNotesUITests",
            dependencies: ["AetherNotesUI"],
            path: "Tests/AetherNotesUITests"
        ),
    ]
)
