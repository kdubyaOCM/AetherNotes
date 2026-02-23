import XCTest
@testable import AetherNotesSecurity

final class NoopSecretsStoreTests: XCTestCase {

    private let store = NoopSecretsStore()

    func testLoadReturnsNilForAnyKey() async throws {
        let result = try await store.loadSecret(provider: "openai", keyID: "default")
        XCTAssertNil(result)
    }

    func testStoreDoesNotThrow() async throws {
        let data = Data("test-ciphertext".utf8)
        try await store.storeSecret(provider: "openai", keyID: "default", ciphertextData: data)
        // No assertion needed — just confirm it doesn't throw.
    }

    func testDeleteDoesNotThrow() async throws {
        try await store.deleteSecret(provider: "openai", keyID: "default")
        // No assertion needed — just confirm it doesn't throw.
    }

    func testLoadAfterStoreStillReturnsNil() async throws {
        // Noop store never persists; load must still return nil after a store call.
        let data = Data("secret".utf8)
        try await store.storeSecret(provider: "openai", keyID: "k1", ciphertextData: data)
        let result = try await store.loadSecret(provider: "openai", keyID: "k1")
        XCTAssertNil(result, "NoopSecretsStore must not persist data across calls.")
    }
}
