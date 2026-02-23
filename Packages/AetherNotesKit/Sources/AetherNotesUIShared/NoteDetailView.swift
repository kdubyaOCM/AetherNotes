import SwiftUI
import AetherNotesCoreModels

/// Detail view for a single note. Read-only in Phase 01; editing arrives in Phase 04/06.
public struct NoteDetailView: View {
    let note: Note

    public init(note: Note) {
        self.note = note
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(note.title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(note.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider()
            Text(note.body.isEmpty ? "No content yet." : note.body)
                .font(.body)
            Spacer()
            RecordingStatusView()
        }
        .padding()
        .navigationTitle(note.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
