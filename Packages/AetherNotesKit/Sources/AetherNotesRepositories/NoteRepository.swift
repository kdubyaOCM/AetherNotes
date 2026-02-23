import Foundation
import AetherNotesCoreModels

/// Persistence abstraction for Note. Implementations must be Sendable (actor or struct).
public protocol NoteRepository: Sendable {
    func fetchAll() async throws -> [Note]
    func fetch(id: NoteID) async throws -> Note?
    func save(_ note: Note) async throws
    func delete(id: NoteID) async throws
}
