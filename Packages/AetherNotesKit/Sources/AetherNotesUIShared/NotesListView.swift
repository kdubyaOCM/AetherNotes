import SwiftUI
import AetherNotesCoreModels
import AetherNotesUseCases

/// Primary note list screen. Shared across iOS, iPadOS, macOS, watchOS.
/// Each platform wraps this view in its own navigation chrome.
public struct NotesListView: View {
    @State private var viewModel: NotesListViewModel

    public init(environment: AppEnvironment) {
        _viewModel = State(wrappedValue: NotesListViewModel(
            listNotes: ListNotesUseCase(repository: environment.noteRepository),
            createNote: CreateNoteUseCase(repository: environment.noteRepository)
        ))
    }

    public var body: some View {
        NavigationStack {
            List(viewModel.notes) { note in
                NavigationLink(destination: NoteDetailView(note: note)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(note.title)
                            .font(.headline)
                        Text(note.createdAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("AetherNotes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Note") {
                        Task { await viewModel.createDummyNote() }
                    }
                }
            }
            .task { await viewModel.load() }
            .overlay {
                if viewModel.notes.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "note.text",
                        description: Text("Tap New Note to create one.")
                    )
                }
            }
        }
    }
}
