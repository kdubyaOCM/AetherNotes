import Foundation
import AetherNotesCoreModels

/// Actor-isolated in-memory NoteRepository. Used during Phase 01 before SwiftData is wired up.
/// All mutations are serialised through the actor, satisfying strict concurrency requirements.
public actor InMemoryNoteRepository: NoteRepository {
    private var notes: [NoteID: Note] = [:]

    public init() {}

    public func fetchAll() async throws -> [Note] {
        notes.values.sorted { $0.createdAt > $1.createdAt }
    }

    public func fetch(id: NoteID) async throws -> Note? {
        notes[id]
    }

    public func save(_ note: Note) async throws {
        notes[note.id] = note
    }

    public func delete(id: NoteID) async throws {
        notes.removeValue(forKey: id)
    }
}
