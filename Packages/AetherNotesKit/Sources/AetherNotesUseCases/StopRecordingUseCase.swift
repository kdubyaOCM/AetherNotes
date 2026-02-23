import Foundation
import AetherNotesCoreModels

/// Stops a recording session and returns a Recording domain model.
/// Audio finalisation and transcription trigger are deferred to Phase 03.
public struct StopRecordingUseCase: Sendable {
    public init() {}

    /// Stub: closes the handle and returns a zero-duration Recording.
    public func execute(handle: RecordingHandle) async throws -> Recording {
        Recording(id: handle.id)
    }
}
