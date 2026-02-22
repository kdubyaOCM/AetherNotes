# AetherNotes. Project State

## Current phase
- Phase: 00 (Bootstrap)
- Branch: bootstrap/claude-contract-and-skeleton

## Stack constraints
- Swift 6, SwiftUI, SwiftData
- CloudKit for sync (CKSyncEngine planned)
- WhisperKit for on-device transcription
- Secure Enclave + Keychain for LLM API key cryptography

## Minimum OS versions
TBD. Define minimum versions before Phase 1 implementation and keep them consistent across all targets.

## Repository invariants
- Apps/ are thin shells only
- Shared logic lives in Packages/
- No plaintext secrets in repo or logs
- No unbounded memory growth during recording or transcription

## Next actions
- Land Phase 00 scaffolding PR
- Create Phase 01 issue and branch plan
