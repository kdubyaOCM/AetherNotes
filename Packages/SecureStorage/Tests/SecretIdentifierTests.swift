import Testing
@testable import SecureStorage

@Suite("SecretIdentifier")
struct SecretIdentifierTests {

    @Test("All identifiers have non-empty display names")
    func displayNames() {
        for id in SecretIdentifier.allCases {
            #expect(!id.displayName.isEmpty)
        }
    }

    @Test("Raw values are unique")
    func uniqueRawValues() {
        let rawValues = SecretIdentifier.allCases.map(\.rawValue)
        let uniqueValues = Set(rawValues)
        #expect(rawValues.count == uniqueValues.count)
    }

    @Test("Display names do not contain actual secret values")
    func displayNamesAreNotSecrets() {
        for id in SecretIdentifier.allCases {
            // Display names should be human-readable labels, not key patterns
            #expect(!id.displayName.hasPrefix("sk-"))
            #expect(!id.displayName.hasPrefix("key-"))
        }
    }
}