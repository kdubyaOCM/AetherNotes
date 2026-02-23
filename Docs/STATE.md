# AetherNotes – Project State

## Minimum OS Versions
- iOS / iPadOS: 17.0
- macOS: 14.0
- watchOS: 10.0

## Current Phase
Phase 0 – Foundation & Security Infrastructure

## Completed Work

### Phase 0
- [x] Repository structure created (Apps/, Packages/, Docs/, Tools/)
- [x] Phase workflow and gating documented (CLAUDE.md)
- [x] Security policy documented (Docs/Security/Secrets.md)
- [x] **SecureStorage package** (`Packages/SecureStorage/`)
  - Secure Enclave P-256 key generation with software fallback
  - ECDH + HKDF key derivation for AES-256-GCM encryption
  - Keychain-backed encrypted secret storage (`.whenUnlockedThisDeviceOnly`)
  - Key rotation support
  - EncryptedBlob format v1 with versioning for forward compatibility
  - ADR-0002 accepted

## Packages
| Package | Path | Purpose |
|---------|------|---------|
| SecureStorage | `Packages/SecureStorage/` | Secure Enclave + Keychain encrypted secret storage |

## ADRs
| ID | Title | Status |
|----|-------|--------|
| ADR-0002 | Secure Enclave Key Storage | Accepted |
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
