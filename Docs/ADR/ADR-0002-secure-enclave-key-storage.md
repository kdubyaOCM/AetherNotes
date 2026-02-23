# ADR-0002: Secure Enclave Key Storage for LLM API Keys

## Status
Accepted

## Date
2026-02-23

## Context

AetherNotes needs to store LLM provider API keys (OpenAI, Anthropic, etc.) on device. Per our security policy, plaintext secrets must never be stored in source code, SwiftData, UserDefaults, logs, or files.

We need a system that:
- Encrypts API keys at rest using hardware-backed keys where available.
- Works across iOS, iPadOS, macOS, and watchOS.
- Handles devices without Secure Enclave gracefully.
- Uses only CryptoKit (no CommonCrypto/OpenSSL).
- Supports key rotation.
- Is deterministic in its encryption format versioning.

## Decision

### Architecture

1. **Key Generation**: On first launch, generate a `SecureEnclave.P256.KeyAgreement.PrivateKey` (or fallback to software `P256.KeyAgreement.PrivateKey`). Also generate an ephemeral P256 key pair and a 32-byte random salt.

2. **Key Storage**: Store the enclave key's opaque `dataRepresentation`, the ephemeral key's `rawRepresentation`, and the salt in Keychain with `.whenUnlockedThisDeviceOnly` accessibility. These are not the API keys themselves.

3. **Key Derivation**: Perform ECDH key agreement between the enclave private key and the ephemeral public key, then derive a 256-bit symmetric key via HKDF-SHA256 with the stored salt.

4. **Encryption**: AES-256-GCM via `CryptoKit.AES.GCM.seal`. Each encryption generates a fresh nonce (CryptoKit default behavior).

5. **Storage Format**: `EncryptedBlob` (JSON-serializable) containing format version, nonce, ciphertext, and tag. Stored in a separate Keychain item per secret identifier.

6. **Fallback**: On devices without Secure Enclave (`SecureEnclave.isAvailable == false`), use a software P256 key. This is still encrypted at rest by the Keychain but lacks hardware isolation.

### Package Structure

All code lives in `Packages/SecureStorage/` as a standalone Swift package with no external dependencies beyond CryptoKit and Security frameworks.

### Key Types

- `EnclaveKeyManager` (actor): Manages key lifecycle, derivation. Actor isolation prevents concurrent key generation races.
- `SecretStore` (actor): High-level encrypt/store/retrieve/delete API.
- `KeychainHelper` (enum, static methods): Low-level Keychain CRUD.
- `EncryptedBlob` (struct, Codable, Sendable): Serializable encrypted container.
- `SecretIdentifier` (enum): Well-known secret names.

## Consequences

### Positive
- API keys are never stored in plaintext on device.
- Hardware-backed encryption when Secure Enclave is available.
- Actor-based concurrency prevents data races (Swift 6 compliant).
- Format versioning enables future encryption scheme changes.
- Key rotation supported via `SecretStore.rotateKeys`.

### Negative
- Secure Enclave keys are device-bound. Users must re-enter API keys on new devices or after Keychain reset.
- Keys do not survive iCloud backup restoration (by design: `.whenUnlockedThisDeviceOnly`).
- Software fallback is weaker than enclave-backed encryption.

### Risks
- If the Keychain is compromised on a non-enclave device, the attacker can derive the symmetric key (mitigated by OS-level Keychain encryption).
- Key rotation requires all secrets to be temporarily decrypted in memory. Mitigated by doing this in an actor with no persistence of intermediates.

## References
- Apple: "Protecting keys with the Secure Enclave"
- Apple: "Storing CryptoKit keys in the Keychain"
- CryptoKit documentation: `SecureEnclave.P256.KeyAgreement.PrivateKey`
- Docs/Security/Secrets.md