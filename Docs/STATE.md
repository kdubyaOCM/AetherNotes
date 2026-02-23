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

## Known gaps (to resolve in Phase 01)
- Widgets extension target is listed in CLAUDE.md but not yet created in the Xcode project.

## Next actions
- Create Phase 01 issue and branch (e.g., phase-01-data-arch)
- Add Widgets extension target to the Xcode project
- First ADR: CloudKit sync strategy (CKSyncEngine vs. NSPersistentCloudKitContainer)
