import Foundation
import AetherNotesCoreModels

/// Stub protocol for the CloudKit sync engine.
/// Will wrap CKSyncEngine with state persistence, chunking, and retry policies.
/// Implementation is deferred to Phase 02 (Data Architecture and Sync).
/// No CloudKit references in Phase 01.
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
