import Foundation
import CryptoKit

/// Manages the Secure Enclave key pair used to derive symmetric encryption keys.
///
/// Architecture:
/// 1. Generate a Secure Enclave P-256 KeyAgreement private key on first launch.
/// 2. Store its data representation in the Keychain (the actual private key
///    never leaves the enclave; the data representation is an opaque handle).
/// 3. Generate and store a per-device ephemeral public key and salt alongside it.
/// 4. Derive a symmetric key via ECDH key agreement + HKDF.
/// 5. Use that symmetric key for AES-GCM encryption of API keys.
///
/// On devices without Secure Enclave, falls back to a CryptoKit P256 key
/// stored in Keychain (less secure but functional).
public actor EnclaveKeyManager {

    // MARK: - Constants

    private static let keychainService = "com.aethernotes.secureenclave"
    private static let enclaveKeyAccount = "enclave-key-data"
    private static let ephemeralKeyAccount = "ephemeral-public-key"
    private static let saltAccount = "derivation-salt"
    private static let saltLength = 32
    private static let hkdfInfo = Data("AetherNotes-APIKey-Encryption".utf8)

    // MARK: - State

    /// Whether the Secure Enclave is available on this device.
    public let isEnclaveAvailable: Bool

    public init() {
        self.isEnclaveAvailable = SecureEnclave.isAvailable
    }

    // MARK: - Public API

    /// Ensures the enclave key, ephemeral key, and salt exist.
    /// Call once at app launch (idempotent).
    public func ensureKeysExist() throws {
        if !keysExist() {
            try generateAndStoreKeys()
        }
    }

    /// Derives the symmetric key used for AES-GCM encryption.
    /// This performs ECDH key agreement + HKDF each time it is called.
    /// The symmetric key is never persisted.
    public func deriveSymmetricKey() throws -> SymmetricKey {
        let salt = try loadSalt()

        if isEnclaveAvailable {
            return try deriveWithEnclave(salt: salt)
        } else {
            return try deriveWithSoftwareKey(salt: salt)
        }
    }

    /// Removes all managed keys from Keychain. User must re-enter API keys
    /// after this operation.
    public func deleteAllKeys() throws {
        try KeychainHelper.delete(
            service: Self.keychainService,
            account: Self.enclaveKeyAccount
        )
        try KeychainHelper.delete(
            service: Self.keychainService,
            account: Self.ephemeralKeyAccount
        )
        try KeychainHelper.delete(
            service: Self.keychainService,
            account: Self.saltAccount
        )
    }

    // MARK: - Key Generation

    private func keysExist() -> Bool {
        KeychainHelper.exists(service: Self.keychainService, account: Self.enclaveKeyAccount)
            && KeychainHelper.exists(service: Self.keychainService, account: Self.ephemeralKeyAccount)
            && KeychainHelper.exists(service: Self.keychainService, account: Self.saltAccount)
    }

    private func generateAndStoreKeys() throws {
        // 1. Generate salt
        var saltBytes = [UInt8](repeating: 0, count: Self.saltLength)
        let saltStatus = SecRandomCopyBytes(kSecRandomDefault, saltBytes.count, &saltBytes)
        guard saltStatus == errSecSuccess else {
            throw SecureStorageError.entropyGenerationFailed
        }
        let salt = Data(saltBytes)

        // 2. Generate the primary key and an ephemeral key for key agreement
        let ephemeralKey = P256.KeyAgreement.PrivateKey()
        let ephemeralPublicKeyData = ephemeralKey.publicKey.compactRepresentation
            ?? ephemeralKey.publicKey.x963Representation

        if isEnclaveAvailable {
            // Generate Secure Enclave key
            let enclaveKey = try SecureEnclave.P256.KeyAgreement.PrivateKey()
            let enclaveKeyData = enclaveKey.dataRepresentation

            try KeychainHelper.save(
                data: enclaveKeyData,
                service: Self.keychainService,
                account: Self.enclaveKeyAccount
            )
        } else {
            // Fallback: software P256 key
            let softwareKey = P256.KeyAgreement.PrivateKey()
            let softwareKeyData = softwareKey.rawRepresentation

            try KeychainHelper.save(
                data: softwareKeyData,
                service: Self.keychainService,
                account: Self.enclaveKeyAccount
            )
        }

        // 3. Store ephemeral private key (used as the "other side" of ECDH)
        try KeychainHelper.save(
            data: ephemeralKey.rawRepresentation,
            service: Self.keychainService,
            account: Self.ephemeralKeyAccount
        )

        // 4. Store salt
        try KeychainHelper.save(
            data: salt,
            service: Self.keychainService,
            account: Self.saltAccount
        )
    }

    // MARK: - Key Derivation (Secure Enclave)

    private func deriveWithEnclave(salt: Data) throws -> SymmetricKey {
        let enclaveKeyData = try KeychainHelper.load(
            service: Self.keychainService,
            account: Self.enclaveKeyAccount
        )
        let ephemeralKeyData = try KeychainHelper.load(
            service: Self.keychainService,
            account: Self.ephemeralKeyAccount
        )

        // Restore the enclave key from its opaque data representation
        let enclaveKey = try SecureEnclave.P256.KeyAgreement.PrivateKey(
            dataRepresentation: enclaveKeyData
        )
        // Restore ephemeral key to get its public key for ECDH
        let ephemeralKey = try P256.KeyAgreement.PrivateKey(
            rawRepresentation: ephemeralKeyData
        )

        // Perform ECDH: enclave private × ephemeral public
        let sharedSecret = try enclaveKey.sharedSecretFromKeyAgreement(
            with: ephemeralKey.publicKey
        )

        // Derive a 256-bit symmetric key via HKDF
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: salt,
            sharedInfo: Self.hkdfInfo,
            outputByteCount: 32
        )

        return symmetricKey
    }

    // MARK: - Key Derivation (Fallback, no Secure Enclave)

    private func deriveWithSoftwareKey(salt: Data) throws -> SymmetricKey {
        let softwareKeyData = try KeychainHelper.load(
            service: Self.keychainService,
            account: Self.enclaveKeyAccount
        )
        let ephemeralKeyData = try KeychainHelper.load(
            service: Self.keychainService,
            account: Self.ephemeralKeyAccount
        )

        let softwareKey = try P256.KeyAgreement.PrivateKey(
            rawRepresentation: softwareKeyData
        )
        let ephemeralKey = try P256.KeyAgreement.PrivateKey(
            rawRepresentation: ephemeralKeyData
        )

        let sharedSecret = try softwareKey.sharedSecretFromKeyAgreement(
            with: ephemeralKey.publicKey
        )

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: salt,
            sharedInfo: Self.hkdfInfo,
            outputByteCount: 32
        )

        return symmetricKey
    }

    // MARK: - Salt

    private func loadSalt() throws -> Data {
        try KeychainHelper.load(
            service: Self.keychainService,
            account: Self.saltAccount
        )
    }
}