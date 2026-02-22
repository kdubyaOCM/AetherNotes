# Phase 00 Handoff

## Base and end commits
- Base: b797186 (Merge pull request #1 from kdubyaOCM/copilot/generate-xcode-workspace-app-targets)
- End: TBD (set to HEAD of bootstrap/claude-contract-and-skeleton after merge)

## Scope delivered
- Added CLAUDE.md: project contract with hard constraints, layout rules, phase workflow, coding rules, git hygiene
- Added Docs/STATE.md: current phase, stack constraints, minimum OS versions (TBD), invariants, next actions
- Added Docs/ADR/README.md: ADR format guide and template
- Added Docs/Handoff/TEMPLATE.md: standard phase handoff template
- Added .github/workflows/ci.yml: minimal CI workflow that handles empty package state gracefully
- Updated README.md: full project description with stack constraints and development workflow
- Updated .gitignore: merged in DerivedData/, *.xcuserstate, *.xcuserdata/, *.xcworkspace/xcuserdata/, .swiftpm/
- Created directory skeleton: Docs/ADR/, Docs/Handoff/, Tools/Scripts/, .github/workflows/

## Files changed
- README.md (updated)
- CLAUDE.md (new)
- .gitignore (merged additions)
- Docs/STATE.md (new)
- Docs/ADR/README.md (new)
- Docs/Handoff/TEMPLATE.md (new)
- Docs/Handoff/Phase00.md (new)
- .github/workflows/ci.yml (new)

## Public API changes
- Added: None (bootstrap phase, no Swift code introduced)
- Changed: None
- Removed: None

## Data and schema changes
- SwiftData: None (no models introduced in Phase 00)
- CloudKit mapping: None

## How to build and test
- Build: Open AetherNotes.xcworkspace in Xcode and build each target
- Tests: `swift test` in Packages/AetherNotesCore and Packages/AetherNotesUI; CI workflow validates this

## Known issues
- Minimum OS versions are not yet defined; must be set before Phase 01 implementation begins
- Xcode project targets exist (iOS, macOS, iPadOS, watchOS) but CI does not run xcodebuild yet (added in a later phase when build environment is stable)

## Instructions for next phase
- Define minimum OS versions in Docs/STATE.md before writing any platform-specific code
- Create a Phase 01 issue and branch (e.g., phase-01-sync) — do NOT start Phase 01 in this branch
- First ADR should cover the CloudKit sync strategy (CKSyncEngine vs. NSPersistentCloudKitContainer)
- Review and tighten Swift 6 concurrency settings in Package.swift files
