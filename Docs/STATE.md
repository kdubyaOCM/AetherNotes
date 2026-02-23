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
