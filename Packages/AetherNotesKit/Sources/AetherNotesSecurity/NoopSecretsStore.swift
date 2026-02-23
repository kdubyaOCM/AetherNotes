import Foundation

/// Phase 01 stub. Satisfies the SecretsStore protocol with no-op behaviour.
/// Replaced by a real Secure Enclave + Keychain implementation in Phase 02.
public struct NoopSecretsStore: SecretsStore {
    public init() {}

    public func storeSecret(provider: String, keyID: String, ciphertextData: Data) async throws {
        // No-op: persistence deferred to Phase 02.
    }

    public func loadSecret(provider: String, keyID: String) async throws -> Data? {
        return nil
    }

    public func deleteSecret(provider: String, keyID: String) async throws {
        // No-op: Keychain deletion deferred to Phase 02.
    }
}
