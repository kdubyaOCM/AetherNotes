# AetherNotes. Project State

## Current phase
- Phase: 00 (Bootstrap) — complete
- Last merged branch: bootstrap/claude-contract-and-skeleton
- Last phase handoff: Docs/Handoff/Phase00.md

## Stack constraints
- Swift 6, SwiftUI, SwiftData
- CloudKit for sync (CKSyncEngine planned)
- WhisperKit for on-device transcription
- Secure Enclave + Keychain for LLM API key cryptography

## Minimum OS versions
These versions are applied in all Package.swift targets and must be kept in sync with any Xcode project target settings.

| Platform | Minimum version |
|----------|----------------|
| iOS      | 17.0           |
| iPadOS   | 17.0           |
| macOS    | 14.0 (Sonoma)  |
| watchOS  | 10.0           |

## Repository invariants
- Apps/ are thin shells only
- Shared logic lives in Packages/
- No plaintext secrets in repo or logs
- No unbounded memory growth during recording or transcription

## Current phase
- Phase: 01 (Foundation) — in progress
- Branch: phase-01/foundation-workspace-packages
- Last phase handoff: Docs/Handoff/Phase01.md

## Package structure
- Single package: `Packages/AetherNotesKit`
- Targets: AetherNotesCoreModels, AetherNotesRepositories, AetherNotesUseCases, AetherNotesSecurity, AetherNotesSync, AetherNotesAudio, AetherNotesTranscription, AetherNotesUIShared
- See Docs/ADR/ADR-0001-swift-package-multi-target.md for rationale

## Next actions

### Phase 02 — Data Architecture and Sync
- Replace InMemoryNoteRepository with SwiftData-backed implementation
- Implement SecretsStore with Secure Enclave + Keychain
- Begin CKSyncEngine wrapper (state persistence, retry, chunking)
- Upgrade to swift-tools-version 6.0 and resolve strict concurrency errors
- Write ADR-0002: SwiftData schema and CloudKit record mapping

### Phase 03 — Audio and ML Pipeline
- Implement AVFoundation audio capture with file streaming and ring buffer
- Integrate WhisperKit for on-device transcription
- Enable recording flow end-to-end in use cases and shared UI
