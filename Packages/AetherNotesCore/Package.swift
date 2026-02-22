// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AetherNotesCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "AetherNotesCore",
            targets: ["AetherNotesCore"]
        ),
    ],
    targets: [
        .target(
            name: "AetherNotesCore",
            path: "Sources/AetherNotesCore"
        ),
        .testTarget(
            name: "AetherNotesCoreTests",
            dependencies: ["AetherNotesCore"],
            path: "Tests/AetherNotesCoreTests"
        ),
    ]
)
