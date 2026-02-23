import Foundation

/// Stub protocol for on-device transcription.
/// Full implementation uses an on-device ML framework (Phase 03).
/// No on-device ML framework references in Phase 01.
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
