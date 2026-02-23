import Foundation
import AetherNotesCoreModels
import AetherNotesRepositories

/// Fetches all Notes from the repository, sorted by creation date descending.
public struct ListNotesUseCase: Sendable {
    private let repository: any NoteRepository

    public init(repository: any NoteRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Note] {
        try await repository.fetchAll()
    }
}
