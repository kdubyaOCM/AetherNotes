import Foundation
import AetherNotesRepositories
import AetherNotesSecurity

/// Lightweight dependency container. Holds repository and service abstractions.
/// Concrete types are injected at the app composition root (App entry point).
/// No third-party DI framework; plain struct composition.
public struct AppEnvironment: Sendable {
    public let noteRepository: any NoteRepository
    public let secretsStore: any SecretsStore

    public init(
        noteRepository: any NoteRepository,
        secretsStore: any SecretsStore
    ) {
        self.noteRepository = noteRepository
        self.secretsStore = secretsStore
    }

    /// Default composition for Phase 01: in-memory repository, no-op secrets store.
    /// Replace in Phase 02 with SwiftData repository and Keychain secrets store.
    public static func makeDefault() -> AppEnvironment {
        AppEnvironment(
            noteRepository: InMemoryNoteRepository(),
            secretsStore: NoopSecretsStore()
        )
    }
}
