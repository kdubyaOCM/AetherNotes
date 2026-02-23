import Foundation
import CryptoKit

/// A serializable container for AES-GCM encrypted data plus its nonce and tag.
/// Stored in Keychain as binary. Never contains plaintext secrets.
public struct EncryptedBlob: Codable, Sendable {

    /// Format version for forward/backward compatibility.
    /// Increment when changing the encryption scheme.
    public let formatVersion: UInt8

    /// AES-GCM nonce (12 bytes).
    public let nonce: Data

    /// AES-GCM ciphertext.
    public let ciphertext: Data

    /// AES-GCM authentication tag (16 bytes).
    public let tag: Data

    /// Current format version.
    public static let currentFormatVersion: UInt8 = 1

    public init(sealedBox: AES.GCM.SealedBox) {
        self.formatVersion = Self.currentFormatVersion
        self.nonce = Data(sealedBox.nonce)
        self.ciphertext = sealedBox.ciphertext
        self.tag = Data(sealedBox.tag)
    }

    /// Reconstruct a CryptoKit SealedBox from the stored components.
    public func sealedBox() throws -> AES.GCM.SealedBox {
        let cryptoNonce = try AES.GCM.Nonce(data: nonce)
        return try AES.GCM.SealedBox(
            nonce: cryptoNonce,
            ciphertext: ciphertext,
            tag: tag
        )
    }

    // MARK: - Serialization

    public func serialized() throws -> Data {
        try JSONEncoder().encode(self)
    }

    public static func deserialize(from data: Data) throws -> EncryptedBlob {
        let blob = try JSONDecoder().decode(EncryptedBlob.self, from: data)
        guard blob.formatVersion <= currentFormatVersion else {
            throw SecureStorageError.unsupportedFormatVersion(blob.formatVersion)
        }
        return blob
    }
}