import Foundation

/// An opaque handle representing an in-progress recording session.
/// Audio state is managed by AetherNotesAudio. This type carries identity only
/// and is safe to pass across actor boundaries.
public struct RecordingHandle: Sendable {
    public let id: RecordingID

    public init(id: RecordingID = .make()) {
        self.id = id
    }
}
