import Testing
import CryptoKit
@testable import SecureStorage

@Suite("EncryptedBlob")
struct EncryptedBlobTests {

    @Test("Round-trip serialization preserves data")
    func roundTripSerialization() throws {
        let key = SymmetricKey(size: .bits256)
        let plaintext = Data("test-api-key-12345".utf8)
        let sealedBox = try AES.GCM.seal(plaintext, using: key)
        let blob = EncryptedBlob(sealedBox: sealedBox)

        let serialized = try blob.serialized()
        let restored = try EncryptedBlob.deserialize(from: serialized)

        #expect(restored.formatVersion == EncryptedBlob.currentFormatVersion)
        #expect(restored.nonce == blob.nonce)
        #expect(restored.ciphertext == blob.ciphertext)
        #expect(restored.tag == blob.tag)
    }

    @Test("Decryption with correct key succeeds")
    func decryptionSucceeds() throws {
        let key = SymmetricKey(size: .bits256)
        let plaintext = Data("sk-secret-value".utf8)
        let sealedBox = try AES.GCM.seal(plaintext, using: key)
        let blob = EncryptedBlob(sealedBox: sealedBox)

        let serialized = try blob.serialized()
        let restored = try EncryptedBlob.deserialize(from: serialized)
        let restoredBox = try restored.sealedBox()
        let decrypted = try AES.GCM.open(restoredBox, using: key)

        #expect(decrypted == plaintext)
    }

    @Test("Decryption with wrong key fails")
    func decryptionWithWrongKeyFails() throws {
        let correctKey = SymmetricKey(size: .bits256)
        let wrongKey = SymmetricKey(size: .bits256)
        let plaintext = Data("sk-secret".utf8)
        let sealedBox = try AES.GCM.seal(plaintext, using: correctKey)
        let blob = EncryptedBlob(sealedBox: sealedBox)

        let serialized = try blob.serialized()
        let restored = try EncryptedBlob.deserialize(from: serialized)
        let restoredBox = try restored.sealedBox()

        #expect(throws: (any Error).self) {
            _ = try AES.GCM.open(restoredBox, using: wrongKey)
        }
    }

    @Test("Format version is current")
    func formatVersion() throws {
        let key = SymmetricKey(size: .bits256)
        let sealedBox = try AES.GCM.seal(Data("x".utf8), using: key)
        let blob = EncryptedBlob(sealedBox: sealedBox)

        #expect(blob.formatVersion == 1)
    }

    @Test("Each encryption produces unique nonce")
    func uniqueNonces() throws {
        let key = SymmetricKey(size: .bits256)
        let plaintext = Data("same-input".utf8)

        let blob1 = EncryptedBlob(sealedBox: try AES.GCM.seal(plaintext, using: key))
        let blob2 = EncryptedBlob(sealedBox: try AES.GCM.seal(plaintext, using: key))

        // AES.GCM.seal generates a random nonce each time
        #expect(blob1.nonce != blob2.nonce)
    }
}