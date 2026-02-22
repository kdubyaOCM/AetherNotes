# AetherNotes

AetherNotes is a local-first AI note-taking ecosystem targeting iOS, iPadOS, macOS, and watchOS.

Core stack constraints:
- Swift 6, SwiftUI, SwiftData
- CloudKit for sync
- WhisperKit for on-device transcription
- Secure Enclave + Keychain for LLM API key cryptography

Development workflow:
- Multi-phase implementation with strict handoffs in Docs/Handoff/
- Architecture decisions recorded as ADRs in Docs/ADR/

Status: See Docs/STATE.md
