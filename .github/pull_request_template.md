## Summary
What does this PR change. Keep it concrete.

## Scope
- In scope:
- Out of scope:

## How to test
- [ ] swift test (packages)
- [ ] xcodebuild (schemes) or N/A (no Xcode project yet)
- [ ] Manual smoke test (describe)

## Contract checks
- [ ] Does not violate CLAUDE.md constraints (Swift 6 concurrency, no secrets, no main-thread IO)
- [ ] Apps/ only contains thin platform shells. Shared logic remains in Packages/
- [ ] No new third-party dependencies introduced without explicit approval

## Data and sync
- [ ] No SwiftData uniqueness assumptions when CloudKit is involved
- [ ] Sync merges are deterministic (if sync touched)

## Security
- [ ] No plaintext secrets added (source, tests, logs, Docs, configs)
- [ ] Any key handling uses Secure Enclave and/or Keychain envelope encryption patterns

## Performance
- [ ] No unbounded memory growth introduced (especially audio or transcription)
- [ ] Any streaming UI updates are throttled

## Docs and handoff
- [ ] Docs/STATE.md updated if phase or invariants changed
- [ ] Docs/Handoff/PhaseNN.md updated if this is a phase PR
- [ ] ADR added if architecture or storage format changed

## Notes for reviewer
Anything that should be reviewed carefully.
