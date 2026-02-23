# AetherNotes

AetherNotes is a local-first AI note-taking ecosystem targeting iOS, iPadOS, macOS, and watchOS.

## Platform support

| Platform | Minimum OS      |
|----------|----------------|
| iOS      | 17.0           |
| iPadOS   | 17.0           |
| macOS    | 14.0 (Sonoma)  |
| watchOS  | 10.0           |

## Core stack

- **Swift 6** — strict concurrency everywhere (async/await, `Sendable`)
- **SwiftUI** — all UI; Views are implicitly `MainActor`
- **SwiftData** — local source of truth
- **CloudKit / CKSyncEngine** — sync replica (planned; Phase 01)
- **WhisperKit** — on-device audio transcription
- **Secure Enclave + Keychain** — envelope encryption for LLM API keys

## Repository layout

```
Apps/          Thin platform shells (SwiftUI entry points, platform adapters only)
  iOS/
  iPadOS/
  macOS/
  watchOS/
Packages/      All shared logic (Swift packages)
  AetherNotesCore/   Models and business logic
  AetherNotesUI/     Shared SwiftUI components
Docs/
  ADR/         Architecture Decision Records
  Handoff/     Per-phase handoff documents
Tools/
  Scripts/     Automation scripts
.github/
  workflows/   CI (swift test for all packages)
  ISSUE_TEMPLATE/
```

## Building and testing

```bash
# Run tests for all Swift packages
cd Packages/AetherNotesCore && swift test
cd Packages/AetherNotesUI  && swift test

# Open the Xcode workspace to build and run platform targets
open AetherNotes.xcworkspace
```

CI runs `swift test` automatically on every push and pull request.

## Development workflow

- Work is executed in phases (Phase 00–08). See the current phase in [Docs/STATE.md](Docs/STATE.md).
- Architecture decisions are recorded as ADRs in [Docs/ADR/](Docs/ADR/).
- Each phase writes a handoff document to [Docs/Handoff/](Docs/Handoff/).
- Read [CLAUDE.md](CLAUDE.md) for the full project contract (hard constraints, coding rules, git hygiene).

## Status

See [Docs/STATE.md](Docs/STATE.md) for the current phase, known gaps, and next actions.
