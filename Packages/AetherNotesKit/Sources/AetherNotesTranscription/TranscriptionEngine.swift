import Foundation

/// Stub protocol for on-device transcription.
/// Full implementation uses WhisperKit / Core ML (Phase 03).
/// No WhisperKit references in Phase 01.
public protocol TranscriptionEngine: Sendable {
    /// Transcribe the audio file at `fileURL`. Returns the transcript text.
    func transcribe(fileURL: URL) async throws -> String
}

/// No-op transcription engine. Returns empty string. Replaced in Phase 03.
public struct NoopTranscriptionEngine: TranscriptionEngine {
    public init() {}

    public func transcribe(fileURL: URL) async throws -> String {
        return ""
    }
}
