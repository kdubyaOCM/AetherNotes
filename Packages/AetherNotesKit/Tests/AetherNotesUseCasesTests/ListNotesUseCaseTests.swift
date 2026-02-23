import XCTest
@testable import AetherNotesUseCases
import AetherNotesRepositories
import AetherNotesCoreModels

final class ListNotesUseCaseTests: XCTestCase {

    func testEmptyRepositoryReturnsEmptyList() async throws {
        let repo = InMemoryNoteRepository()
        let useCase = ListNotesUseCase(repository: repo)

        let notes = try await useCase.execute()

        XCTAssertTrue(notes.isEmpty)
    }

    func testListReturnsAllSavedNotes() async throws {
        let repo = InMemoryNoteRepository()
        let create = CreateNoteUseCase(repository: repo)
        let list = ListNotesUseCase(repository: repo)

        _ = try await create.execute(title: "Note A")
        _ = try await create.execute(title: "Note B")
        _ = try await create.execute(title: "Note C")

        let notes = try await list.execute()

        XCTAssertEqual(notes.count, 3)
    }

    func testListReturnsMostRecentFirst() async throws {
        let repo = InMemoryNoteRepository()

        // Insert notes with known creation dates
        let earlier = Note(id: .make(), title: "Earlier", createdAt: Date(timeIntervalSinceNow: -100))
        let later   = Note(id: .make(), title: "Later",   createdAt: Date(timeIntervalSinceNow: -10))
        try await repo.save(earlier)
        try await repo.save(later)

        let useCase = ListNotesUseCase(repository: repo)
        let notes = try await useCase.execute()

        XCTAssertEqual(notes.first?.title, "Later")
        XCTAssertEqual(notes.last?.title, "Earlier")
    }
}
