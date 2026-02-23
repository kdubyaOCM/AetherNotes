# ADR-0001: Single Swift Package with Multiple Targets

**Date:** 2026-02-23
**Status:** Accepted
**Phase:** 01 (Foundation)

---

## Context

AetherNotes requires shared logic across five platform targets: iOS, iPadOS, macOS, watchOS, and a Widgets extension. All shared code must live in `Packages/` per the repository contract (CLAUDE.md).

Two structural options exist for organising this shared code:

1. **Multiple packages** — one `Package.swift` per domain layer (e.g., `AetherNotesCore`, `AetherNotesSync`, `AetherNotesSecurity`).
2. **Single package, multiple targets** — one `Package.swift` under `Packages/AetherNotesKit/` that declares all library targets.

The repository already contained two exploratory packages (`AetherNotesCore`, `AetherNotesUI`) created in Phase 00 bootstrapping. Phase 01 supersedes those with a production-grade structure.

---

## Decision

Use **one package (`AetherNotesKit`) with multiple library targets**, defined in `Packages/AetherNotesKit/Package.swift`.

Library targets defined in Phase 01:

| Target | Role |
|---|---|
| `AetherNotesCoreModels` | Domain structs, ID types |
| `AetherNotesRepositories` | Repository protocols + InMemory impl |
| `AetherNotesUseCases` | Use cases, AppEnvironment |
| `AetherNotesSecurity` | SecretsStore protocol + noop stub |
| `AetherNotesSync` | CKSyncEngine stub (Phase 02) |
| `AetherNotesAudio` | AVFoundation capture stub (Phase 03) |
| `AetherNotesTranscription` | WhisperKit stub (Phase 03) |
| `AetherNotesUIShared` | SwiftUI views and view models |

---

## Rationale

### Why not multiple packages?

**Package resolution overhead.** Xcode resolves each local package separately, even when they live in the same repo. With 8+ packages, cold-resolution time grows noticeably. A single `Package.swift` resolves once.

**Simplified workspace.** The `xcworkspace` needs a `<FileRef>` for every local package. One entry is simpler to maintain than eight.

**Intra-package build caching.** Within one package, the Swift compiler can share module caches across targets more efficiently than across package boundaries.

**Version coordination is trivial.** All targets share a single `swift-tools-version` and platform constraints block. Cross-package version skew cannot occur.

**Refactoring ergonomics.** Moving a type from one target to another (e.g., promoting a model from Repositories to CoreModels) is a file move inside one package, not a cross-package import update.

### Why not a single target?

A single monolithic target defeats the purpose of enforced layering. The compiler cannot catch import violations across a single target's source files. Multiple targets enforce that `AetherNotesUIShared` cannot accidentally import `AetherNotesSecurity` without an explicit dependency declaration in `Package.swift`.

### Trade-offs accepted

- **Larger Package.swift.** A single file grows with each new target. Mitigated by `MARK:` comments and alphabetical ordering.
- **Single failure domain.** A compile error in any target blocks the whole package resolution. Acceptable: each target is small and well-scoped.
- **Future split is possible.** If a target grows large enough to warrant independent versioning (e.g., `AetherNotesSync` as a reusable library), it can be extracted into its own package without changing the public API.

---

## Consequences

- All app targets in `AetherNotes.xcodeproj` link products from `AetherNotesKit` only.
- The workspace references `Packages/AetherNotesKit` only. The Phase 00 packages (`AetherNotesCore`, `AetherNotesUI`) are superseded and their directories can be removed in a future cleanup phase.
- New domain modules are added as targets inside `AetherNotesKit/Package.swift`.
- Minimum OS versions are declared once in `Package.swift` and must match `Docs/STATE.md` and the Xcode project build settings.
