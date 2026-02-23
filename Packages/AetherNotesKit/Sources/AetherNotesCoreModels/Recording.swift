import Foundation

/// Core domain model for a recorded audio session. Value type; SwiftData wrapping deferred to Phase 02.
public struct Recording: Equatable, Hashable, Sendable, Identifiable, Codable {
    public let id: RecordingID
    public var noteID: NoteID?
    public var durationSeconds: Double
    public var createdAt: Date

    public init(
        id: RecordingID = .make(),
        noteID: NoteID? = nil,
        durationSeconds: Double = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.noteID = noteID
        self.durationSeconds = durationSeconds
        self.createdAt = createdAt
    }
}
