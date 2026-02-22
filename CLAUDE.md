# AetherNotes. Claude Code Project Contract

This repository is the single source of truth. Do not rely on chat history as memory. The repo, commits, and Docs/ are the memory.

## Hard constraints
- Swift 6 strict concurrency everywhere. Use async/await. Do not use DispatchQueue unless an Apple API requires it, and document the reason in an ADR.
- SwiftUI Views are implicitly MainActor. Do not annotate View structs with @MainActor.
- Prefer Observation (@Observable). Avoid ObservableObject and Combine unless forced by a framework API. If used, isolate it behind an adapter.
- SwiftData is the local source of truth. CloudKit is a replica. Do not depend on automatic SwiftData CloudKit sync for core features that require CKAsset, chunking, deterministic merges, and retry policies.
- Secrets: Never store plaintext API keys in source code, tests, logs, SwiftData, UserDefaults, or files. Use Secure Enclave where available plus Keychain access control and envelope encryption.
- Audio and ML: Do not accumulate full recordings in RAM. Use file streaming, bounded ring buffers, and backpressure. Assume WhisperKit and Core ML can spike memory.

## Platform targets
- iOS, iPadOS, macOS, watchOS, plus a Widgets extension target.
- Minimum OS versions are defined once in Docs/STATE.md and must be applied consistently across targets.

## Repository layout
- Apps/ contains thin platform shells only (SwiftUI views, app composition, platform adapters).
- Packages/ contains all shared logic.
- Docs/ADR/ contains architecture decision records.
- Docs/Handoff/ contains phase handoffs and manifests.
- Tools/ contains scripts and utilities.

## Phase workflow and gating
Work is executed in phases (Phase 0 through Phase 8). Each phase must:
1) Build and run tests before declaring completion.
2) Write a handoff file in Docs/Handoff/PhaseNN.md.
3) Update Docs/STATE.md.
4) Add tests for critical logic introduced in the phase.
5) Add ADRs for any architectural change.

Never start future phases in the current phase branch.

## Coding rules
- Prefer small actors and pure functions. Avoid "manager" god objects.
- Do not perform file IO on the main thread.
- All cross-actor data must be Sendable. Avoid @unchecked Sendable. If unavoidable, explain why it is safe in a comment.
- Never log secrets. Never log full transcripts by default. Use redaction and explicit debug toggles.
- Determinism required for:
  - sync merge outcomes
  - chunking and hashing
  - encryption format versions and rotation

## Git hygiene
- Use short-lived feature branches per phase, for example phase-01-sync.
- Use small commits with clear messages.
- Keep diffs reviewable. Do not reformat the entire codebase without an explicit phase and ADR.

## What to do if you are unsure
- Search existing Docs/STATE.md, latest Docs/Handoff/PhaseNN.md, and ADRs.
- If still uncertain, propose 2 options with risks and pick the safest default.
