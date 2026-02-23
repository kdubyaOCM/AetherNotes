// swift-tools-version: 5.9
// AetherNotesKit — single multi-target package for all shared logic.
// See Docs/ADR/ADR-0001-swift-package-multi-target.md for rationale.
import PackageDescription

// Strict concurrency setting applied to every target.
let strictConcurrency: SwiftSetting = .enableExperimentalFeature("StrictConcurrency")

let package = Package(
    name: "AetherNotesKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
    ],
    products: [
        .library(name: "AetherNotesCoreModels",   targets: ["AetherNotesCoreModels"]),
        .library(name: "AetherNotesRepositories",  targets: ["AetherNotesRepositories"]),
        .library(name: "AetherNotesUseCases",      targets: ["AetherNotesUseCases"]),
        .library(name: "AetherNotesSync",          targets: ["AetherNotesSync"]),
        .library(name: "AetherNotesAudio",         targets: ["AetherNotesAudio"]),
        .library(name: "AetherNotesTranscription", targets: ["AetherNotesTranscription"]),
        .library(name: "AetherNotesSecurity",      targets: ["AetherNotesSecurity"]),
        .library(name: "AetherNotesUIShared",      targets: ["AetherNotesUIShared"]),
    ],
    targets: [

        // MARK: - Core domain models. No framework dependencies.
        .target(
            name: "AetherNotesCoreModels",
            dependencies: [],
            path: "Sources/AetherNotesCoreModels",
            swiftSettings: [strictConcurrency]
        ),

        // MARK: - Repository protocols and in-memory implementations.
        .target(
            name: "AetherNotesRepositories",
            dependencies: ["AetherNotesCoreModels"],
            path: "Sources/AetherNotesRepositories",
            swiftSettings: [strictConcurrency]
        ),

        // MARK: - Use cases and app environment container.
        .target(
            name: "AetherNotesUseCases",
            dependencies: ["AetherNotesCoreModels", "AetherNotesRepositories", "AetherNotesSecurity"],
            path: "Sources/AetherNotesUseCases",
            swiftSettings: [strictConcurrency]
        ),

        // MARK: - CloudKit sync stub. Implementation in Phase 02.
        .target(
            name: "AetherNotesSync",
            dependencies: ["AetherNotesCoreModels"],
            path: "Sources/AetherNotesSync",
            swiftSettings: [strictConcurrency]
        ),

        // MARK: - Audio capture stub. AVFoundation usage in Phase 03.
        .target(
            name: "AetherNotesAudio",
            dependencies: ["AetherNotesCoreModels"],
            path: "Sources/AetherNotesAudio",
            swiftSettings: [strictConcurrency]
        ),

        // MARK: - Transcription stub. WhisperKit integration in Phase 03.
        .target(
            name: "AetherNotesTranscription",
            dependencies: [],
            path: "Sources/AetherNotesTranscription",
            swiftSettings: [strictConcurrency]
        ),

        // MARK: - Secrets store protocol and noop stub. Real crypto in Phase 02.
        .target(
            name: "AetherNotesSecurity",
            dependencies: [],
            path: "Sources/AetherNotesSecurity",
            swiftSettings: [strictConcurrency]
        ),

        // MARK: - Shared SwiftUI views and view models.
        .target(
            name: "AetherNotesUIShared",
            dependencies: ["AetherNotesCoreModels", "AetherNotesUseCases"],
            path: "Sources/AetherNotesUIShared",
            swiftSettings: [strictConcurrency]
        ),

        // MARK: - Test targets
        .testTarget(
            name: "AetherNotesCoreModelsTests",
            dependencies: ["AetherNotesCoreModels"],
            path: "Tests/AetherNotesCoreModelsTests",
            swiftSettings: [strictConcurrency]
        ),
        .testTarget(
            name: "AetherNotesSecurityTests",
            dependencies: ["AetherNotesSecurity"],
            path: "Tests/AetherNotesSecurityTests",
            swiftSettings: [strictConcurrency]
        ),
        .testTarget(
            name: "AetherNotesUseCasesTests",
            dependencies: ["AetherNotesUseCases", "AetherNotesRepositories"],
            path: "Tests/AetherNotesUseCasesTests",
            swiftSettings: [strictConcurrency]
        ),
    ]
)
