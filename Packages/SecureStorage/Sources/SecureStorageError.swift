import Foundation

/// Errors raised by the SecureStorage package.
public enum SecureStorageError: Error, Sendable, LocalizedError {
    case enclaveNotAvailable
    case entropyGenerationFailed
    case keysNotInitialized
    case encryptionFailed(underlying: Error)
    case decryptionFailed(underlying: Error)
    case unsupportedFormatVersion(UInt8)
    case secretNotFound(identifier: String)

    public var errorDescription: String? {
        switch self {
        case .enclaveNotAvailable:
            "Secure Enclave is not available on this device."
        case .entropyGenerationFailed:
            "Failed to generate cryptographic random bytes."
        case .keysNotInitialized:
            "Encryption keys have not been initialized. Call ensureKeysExist() first."
        case .encryptionFailed(let error):
            "Encryption failed: \(error.localizedDescription)"
        case .decryptionFailed(let error):
            "Decryption failed: \(error.localizedDescription)"
        case .unsupportedFormatVersion(let version):
            "Unsupported encrypted blob format version: \(version)."
        case .secretNotFound(let id):
            "No secret found for identifier: \(id)."
        }
    }
}