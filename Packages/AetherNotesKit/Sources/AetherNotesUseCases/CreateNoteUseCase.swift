import Foundation
import AetherNotesCoreModels
import AetherNotesRepositories

/// Creates a new Note and persists it via the repository.
public struct CreateNoteUseCase: Sendable {
    private let repository: any NoteRepository

    public init(repository: any NoteRepository) {
        self.repository = repository
    }

    @discardableResult
    public func execute(title: String, body: String = "") async throws -> Note {
        let note = Note(title: title, body: body)
        try await repository.save(note)
        return note
    }
}
