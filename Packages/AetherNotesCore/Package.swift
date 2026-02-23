// swift-tools-version: 6.0
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
            path: "Sources/AetherNotesCore",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "AetherNotesCoreTests",
            dependencies: ["AetherNotesCore"],
            path: "Tests/AetherNotesCoreTests",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
