import XCTest
@testable import AetherNotesUseCases
import AetherNotesRepositories
import AetherNotesCoreModels

final class CreateNoteUseCaseTests: XCTestCase {

    func testCreatedNoteHasCorrectTitle() async throws {
        let repo = InMemoryNoteRepository()
        let useCase = CreateNoteUseCase(repository: repo)

        let note = try await useCase.execute(title: "My First Note")

        XCTAssertEqual(note.title, "My First Note")
    }

    func testCreatedNoteHasCorrectBody() async throws {
        let repo = InMemoryNoteRepository()
        let useCase = CreateNoteUseCase(repository: repo)

        let note = try await useCase.execute(title: "T", body: "Body content")

        XCTAssertEqual(note.body, "Body content")
    }

    func testCreatedNoteIsPersisted() async throws {
        let repo = InMemoryNoteRepository()
        let createUseCase = CreateNoteUseCase(repository: repo)
        let listUseCase = ListNotesUseCase(repository: repo)

        let created = try await createUseCase.execute(title: "Persisted Note")
        let notes = try await listUseCase.execute()

        XCTAssertTrue(notes.contains(where: { $0.id == created.id }))
    }

    func testDefaultBodyIsEmpty() async throws {
        let repo = InMemoryNoteRepository()
        let useCase = CreateNoteUseCase(repository: repo)

        let note = try await useCase.execute(title: "No Body")

        XCTAssertEqual(note.body, "")
    }
}
