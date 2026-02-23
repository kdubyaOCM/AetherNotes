import Testing
import Foundation
@testable import SecureStorage

@Suite("KeychainHelper")
struct KeychainHelperTests {

    private let testService = "com.aethernotes.test.\(UUID().uuidString)"
    private let testAccount = "test-account"

    @Test("Save and load round-trip")
    func saveAndLoad() throws {
        let data = Data("test-data-\(UUID().uuidString)".utf8)

        try KeychainHelper.save(data: data, service: testService, account: testAccount)
        let loaded = try KeychainHelper.load(service: testService, account: testAccount)

        #expect(loaded == data)

        // Cleanup
        try KeychainHelper.delete(service: testService, account: testAccount)
    }

    @Test("Update existing item")
    func updateExisting() throws {
        let original = Data("original".utf8)
        let updated = Data("updated".utf8)

        try KeychainHelper.save(data: original, service: testService, account: testAccount)
        try KeychainHelper.save(data: updated, service: testService, account: testAccount)

        let loaded = try KeychainHelper.load(service: testService, account: testAccount)
        #expect(loaded == updated)

        try KeychainHelper.delete(service: testService, account: testAccount)
    }

    @Test("Load nonexistent throws itemNotFound")
    func loadNonexistent() throws {
        #expect(throws: KeychainHelper.KeychainError.self) {
            _ = try KeychainHelper.load(
                service: testService,
                account: "nonexistent-\(UUID().uuidString)"
            )
        }
    }

    @Test("Exists returns correct values")
    func existsCheck() throws {
        let account = "exists-test-\(UUID().uuidString)"

        #expect(!KeychainHelper.exists(service: testService, account: account))

        try KeychainHelper.save(
            data: Data("x".utf8),
            service: testService,
            account: account
        )
        #expect(KeychainHelper.exists(service: testService, account: account))

        try KeychainHelper.delete(service: testService, account: account)
        #expect(!KeychainHelper.exists(service: testService, account: account))
    }

    @Test("Delete nonexistent does not throw")
    func deleteNonexistent() throws {
        try KeychainHelper.delete(
            service: testService,
            account: "nonexistent-\(UUID().uuidString)"
        )
    }
}