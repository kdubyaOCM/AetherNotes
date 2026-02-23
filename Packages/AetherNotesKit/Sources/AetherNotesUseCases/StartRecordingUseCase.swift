import Foundation
import AetherNotesCoreModels

/// Starts a recording session. Returns an opaque handle.
/// Audio capture implementation is deferred to Phase 03 (AetherNotesAudio / AVFoundation).
public struct StartRecordingUseCase: Sendable {
    public init() {}

    /// Stub: returns a handle with a new RecordingID. No audio is captured in Phase 01.
    public func execute() async throws -> RecordingHandle {
        RecordingHandle()
    }
}
