import Foundation

/// Errors produced by SecretsStore operations.
public enum SecretsStoreError: Error, Sendable {
    case notFound
    case storeFailed(String)
    case deleteFailed(String)
}

/// Protocol for encrypted secret storage. Implementations use Secure Enclave + Keychain (Phase 02).
/// All methods are async to allow Keychain calls off the main thread without blocking.
public protocol SecretsStore: Sendable {
    /// Persist ciphertext for a given (provider, keyID) pair.
    func storeSecret(provider: String, keyID: String, ciphertextData: Data) async throws
    /// Retrieve ciphertext for a given (provider, keyID) pair, or nil if absent.
    func loadSecret(provider: String, keyID: String) async throws -> Data?
    /// Remove the entry for a given (provider, keyID) pair.
    func deleteSecret(provider: String, keyID: String) async throws
}
