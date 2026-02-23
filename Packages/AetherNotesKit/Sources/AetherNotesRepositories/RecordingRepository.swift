import Foundation
import AetherNotesCoreModels

/// Persistence abstraction for Recording. Implementations must be Sendable (actor or struct).
public protocol RecordingRepository: Sendable {
    func fetchAll() async throws -> [Recording]
    func save(_ recording: Recording) async throws
    func delete(id: RecordingID) async throws
}
