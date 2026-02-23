# Phase 01 Handoff — Foundation (Workspace, Targets, Shared Package)

## Base and end commits
- Base: bootstrap/claude-contract-and-skeleton (Phase 00 merge)
- End: phase-01/foundation-workspace-packages HEAD

## Scope delivered

- Single Xcode workspace (`AetherNotes.xcworkspace`) referencing the project and `AetherNotesKit`.
- Xcode project (`AetherNotes.xcodeproj`) with five native targets: iOS, iPadOS, macOS, watchOS, Widgets (extension).
- One local Swift package (`Packages/AetherNotesKit`) with eight library targets and three test targets.
- Minimal compile-clean SwiftUI app shells for all five targets. Each app shell creates `AppEnvironment.makeDefault()` and presents `NotesListView`.
- `NotesListView` and `NoteDetailView` in `AetherNotesUIShared`: list notes, tap to drill down, "New Note" button triggers `CreateNoteUseCase`.
- Stub modules: `AetherNotesSync`, `AetherNotesAudio`, `AetherNotesTranscription`, `AetherNotesSecurity` — protocols and no-op implementations only.
- Minimum OS versions locked: iOS/iPadOS 17.0, macOS 14.0, watchOS 10.0 — encoded in `Package.swift`, project build settings, and `PlatformTargets.swift`.
- ADR-0001: single-package multi-target rationale.
- `Tools/Scripts/build_all.sh` for local CI verification.

## Files changed

**New — Packages/AetherNotesKit/**
- `Package.swift`
- `Sources/AetherNotesCoreModels/` — NoteID, Note, RecordingID, Recording, RecordingHandle
- `Sources/AetherNotesRepositories/` — NoteRepository, RecordingRepository, InMemoryNoteRepository
- `Sources/AetherNotesUseCases/` — AppEnvironment, CreateNoteUseCase, ListNotesUseCase, StartRecordingUseCase, StopRecordingUseCase, Platform/PlatformTargets
- `Sources/AetherNotesSecurity/` — SecretsStore, NoopSecretsStore
- `Sources/AetherNotesSync/` — SyncEngine, NoopSyncEngine
- `Sources/AetherNotesAudio/` — AudioCapture, NoopAudioCapture
- `Sources/AetherNotesTranscription/` — TranscriptionEngine, NoopTranscriptionEngine
- `Sources/AetherNotesUIShared/` — NotesListView, NoteDetailView, RecordingStatusView, NotesListViewModel
- `Tests/AetherNotesCoreModelsTests/` — NoteIDTests
- `Tests/AetherNotesSecurityTests/` — NoopSecretsStoreTests
- `Tests/AetherNotesUseCasesTests/` — CreateNoteUseCaseTests, ListNotesUseCaseTests

**New — Apps/**
- `Apps/Widgets/WidgetExtension.swift`

**Updated — Apps/**
- `Apps/iOS/App.swift` — imports and uses AetherNotesUIShared
- `Apps/iPadOS/App.swift` — imports and uses AetherNotesUIShared
- `Apps/macOS/App.swift` — NavigationSplitView + AetherNotesUIShared
- `Apps/watchOS/App.swift` — imports and uses AetherNotesUIShared

**Updated — Project files**
- `AetherNotes.xcworkspace/contents.xcworkspacedata` — replaced old package refs with AetherNotesKit
- `AetherNotes.xcodeproj/project.pbxproj` — added Widgets target, package reference, product dependencies

**New — Docs/**
- `Docs/ADR/ADR-0001-swift-package-multi-target.md`
- `Docs/Handoff/Phase01.md` (this file)
- `Docs/STATE.md` — updated phase and next actions

**New — Tools/**
- `Tools/Scripts/build_all.sh`

## Public API changes

**Added (AetherNotesCoreModels):**
- `NoteID`, `RecordingID` — typed UUID wrappers, Sendable, Codable
- `Note`, `Recording` — Sendable, Identifiable, Equatable value types
- `RecordingHandle` — opaque recording session handle

**Added (AetherNotesRepositories):**
- `NoteRepository` protocol
- `RecordingRepository` protocol
- `InMemoryNoteRepository` actor

**Added (AetherNotesUseCases):**
- `AppEnvironment` — dependency container with `makeDefault()`
- `CreateNoteUseCase`, `ListNotesUseCase`, `StartRecordingUseCase`, `StopRecordingUseCase`
- `PlatformTargets` — OS version constants

**Added (AetherNotesSecurity):**
- `SecretsStore` protocol, `SecretsStoreError`
- `NoopSecretsStore`

**Added (AetherNotesSync, AetherNotesAudio, AetherNotesTranscription):**
- Stub protocols and no-op implementations

**Added (AetherNotesUIShared):**
- `NotesListView`, `NoteDetailView`, `RecordingStatusView`

## Data and schema changes

- SwiftData: not introduced in Phase 01. Models are plain structs.
- CloudKit: not introduced in Phase 01.

## How to build and test

**Package tests (no Xcode needed):**
```bash
cd Packages/AetherNotesKit
swift test
```

**All package targets (build only):**
```bash
cd Packages/AetherNotesKit
swift build
```

**Xcode (requires macOS SDK):**
```
Open AetherNotes.xcworkspace
Select scheme AetherNotes-iOS (or macOS/watchOS/iPadOS/Widgets)
Product > Build (⌘B)
```

**Build script:**
```bash
bash Tools/Scripts/build_all.sh
```

## Known issues

- `AetherNotesCoreModels` contains a `#if canImport(SwiftData)` placeholder; the conditional file is not included in Phase 01 (plain structs only). Wire-up happens in Phase 02.
- The Widgets target produces an appex but is not embedded in any host app target in the current pbxproj. A host app embed build phase is needed before the widget displays in the simulator; deferred to Phase 05.
- Strict concurrency is enabled via `.enableExperimentalFeature("StrictConcurrency")` (Swift 5.9 mode). Upgrading to `swift-tools-version: 6.0` with `.swiftLanguageMode(.v6)` is the Phase 02 gate.
- `AetherNotesCore` and `AetherNotesUI` directories (from Phase 00) remain on disk but are no longer referenced by the workspace or project. They can be deleted in a future cleanup.

## Instructions for next phase

**Phase 02 — Data Architecture and Sync:**
1. Replace `InMemoryNoteRepository` with a SwiftData-backed `SwiftDataNoteRepository`.
2. Implement `SwiftDataSecretsStore` using Secure Enclave + Keychain.
3. Begin `CKSyncEngine` wrapper in `AetherNotesSync` with state persistence and retry.
4. Upgrade `Package.swift` to swift-tools-version 6.0 and resolve any remaining strict concurrency errors.
5. Write ADR-0002: SwiftData schema design and CloudKit record mapping.
6. Embed the Widgets target in a host app and add a basic WidgetKit timeline.

**Phase 03 — Audio and ML Pipeline:**
1. Implement `AVFoundationAudioCapture` in `AetherNotesAudio` with file streaming.
2. Integrate WhisperKit in `AetherNotesTranscription`.
3. Enable recording flow in use cases and UI.
