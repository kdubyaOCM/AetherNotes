import Foundation
import AetherNotesCoreModels
import AetherNotesUseCases

/// ViewModel for NotesListView.
/// @MainActor because it owns UI state. Heavy work crosses into actor-isolated repositories via await.
@Observable
@MainActor
final class NotesListViewModel {
    var notes: [Note] = []
    var isLoading = false

    private let listNotes: ListNotesUseCase
    private let createNote: CreateNoteUseCase

    init(listNotes: ListNotesUseCase, createNote: CreateNoteUseCase) {
        self.listNotes = listNotes
        self.createNote = createNote
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            notes = try await listNotes.execute()
        } catch {
            // Phase 01: errors surfaced in Phase 04 (error handling layer).
        }
    }

    func createDummyNote() async {
        do {
            let formatter = Date.FormatStyle().hour().minute().second()
            _ = try await createNote.execute(title: "Note \(Date.now.formatted(formatter))")
            await load()
        } catch {}
    }
}
