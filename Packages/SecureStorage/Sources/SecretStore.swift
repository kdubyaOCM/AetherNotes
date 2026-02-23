import Foundation
import CryptoKit

/// High-level API for storing and retrieving encrypted API keys.
///
/// Usage:
/// ```swift
/// let store = SecretStore()
/// try await store.initialize()
/// try await store.storeSecret("sk-abc123...", identifier: "openai-api-key")
/// let key = try await store.retrieveSecret(identifier: "openai-api-key")
/// ```
///
/// Secrets are AES-GCM encrypted using a key derived from a Secure Enclave
/// P-256 key agreement. Only the encrypted blob is stored in Keychain.
/// The raw API key is never persisted in plaintext.
public actor SecretStore {

    // MARK: - Constants

    private static let keychainService = "com.aethernotes.secrets"

    // MARK: - Dependencies

    private let keyManager: EnclaveKeyManager

    // MARK: - Init

    public init(keyManager: EnclaveKeyManager? = nil) {
        self.keyManager = keyManager ?? EnclaveKeyManager()
    }

    /// Initializes encryption keys if they don't already exist.
    /// Must be called before any store/retrieve operations.
    public func initialize() async throws {
        try await keyManager.ensureKeysExist()
    }

    // MARK: - Store

    /// Encrypts and stores an API key (or any secret string) under the given identifier.
    ///
    /// - Parameters:
    ///   - secret: The plaintext secret. Zeroed from memory after encryption.
    ///   - identifier: A stable identifier (e.g. "openai-api-key").
    public func storeSecret(_ secret: String, identifier: String) async throws {
        guard let plaintext = secret.data(using: .utf8) else {
            throw SecureStorageError.encryptionFailed(
                underlying: NSError(domain: "SecretStore", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Failed to encode secret as UTF-8"
                ])
            )
        }

        let symmetricKey = try await keyManager.deriveSymmetricKey()

        do {
            let sealedBox = try AES.GCM.seal(plaintext, using: symmetricKey)
            let blob = EncryptedBlob(sealedBox: sealedBox)
            let serialized = try blob.serialized()

            try KeychainHelper.save(
                data: serialized,
                service: Self.keychainService,
                account: identifier
            )
        } catch let error as SecureStorageError {
            throw error
        } catch {
            throw SecureStorageError.encryptionFailed(underlying: error)
        }
    }

    // MARK: - Retrieve

    /// Decrypts and returns the secret stored under the given identifier.
    ///
    /// - Parameter identifier: The identifier used when storing.
    /// - Returns: The plaintext secret string.
    public func retrieveSecret(identifier: String) async throws -> String {
        let serialized: Data
        do {
            serialized = try KeychainHelper.load(
                service: Self.keychainService,
                account: identifier
            )
        } catch is KeychainHelper.KeychainError {
            throw SecureStorageError.secretNotFound(identifier: identifier)
        }

        let blob = try EncryptedBlob.deserialize(from: serialized)
        let symmetricKey = try await keyManager.deriveSymmetricKey()

        do {
            let sealedBox = try blob.sealedBox()
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)

            guard let secret = String(data: decryptedData, encoding: .utf8) else {
                throw SecureStorageError.decryptionFailed(
                    underlying: NSError(domain: "SecretStore", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "Decrypted data is not valid UTF-8"
                    ])
                )
            }

            return secret
        } catch let error as SecureStorageError {
            throw error
        } catch {
            throw SecureStorageError.decryptionFailed(underlying: error)
        }
    }

    // MARK: - Delete

    /// Removes the encrypted secret for the given identifier.
    public func deleteSecret(identifier: String) throws {
        try KeychainHelper.delete(
            service: Self.keychainService,
            account: identifier
        )
    }

    // MARK: - Exists

    /// Returns true if an encrypted secret exists for the given identifier.
    public func hasSecret(identifier: String) -> Bool {
        KeychainHelper.exists(
            service: Self.keychainService,
            account: identifier
        )
    }

    // MARK: - Rotate

    /// Re-encrypts all secrets with a fresh enclave key.
    /// Call this if you suspect key compromise or as part of periodic rotation.
    ///
    /// - Parameter identifiers: The identifiers of secrets to re-encrypt.
    public func rotateKeys(identifiers: [String]) async throws {
        // 1. Decrypt all secrets with current key
        var decryptedSecrets: [(String, String)] = []
        for id in identifiers {
            let secret = try await retrieveSecret(identifier: id)
            decryptedSecrets.append((id, secret))
        }

        // 2. Generate new enclave key + salt
        try await keyManager.deleteAllKeys()
        try await keyManager.ensureKeysExist()

        // 3. Re-encrypt with new key
        for (id, secret) in decryptedSecrets {
            try await storeSecret(secret, identifier: id)
        }
    }
}