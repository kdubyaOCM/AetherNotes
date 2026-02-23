import Foundation
import AetherNotesCoreModels

/// Stub protocol for the remote sync engine.
/// Will wrap the platform sync framework with state persistence, chunking, and retry policies.
/// Implementation is deferred to Phase 02 (Data Architecture and Sync).
/// No platform sync framework references in Phase 01.
public protocol SyncEngine: Sendable {
    func start() async throws
    func stop() async throws
}

/// No-op sync engine. Replaced in Phase 02.
public actor NoopSyncEngine: SyncEngine {
    public init() {}

    public func start() async throws {}
    public func stop() async throws {}
}
