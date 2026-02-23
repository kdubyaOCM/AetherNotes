import Foundation
import AetherNotesCoreModels

/// Stub protocol for audio capture.
/// Full implementation uses AVFoundation with file streaming and bounded ring buffers (Phase 03).
/// Must NOT accumulate recordings in RAM — that constraint is enforced in Phase 03.
/// No AVFoundation import in Phase 01; this module compiles on all platforms.
public protocol AudioCapture: Sendable {
    func begin() async throws -> RecordingHandle
    func finish(handle: RecordingHandle) async throws
    func cancel(handle: RecordingHandle) async throws
}

/// No-op audio capture. Replaced in Phase 03.
public actor NoopAudioCapture: AudioCapture {
    public init() {}

    public func begin() async throws -> RecordingHandle { RecordingHandle() }
    public func finish(handle: RecordingHandle) async throws {}
    public func cancel(handle: RecordingHandle) async throws {}
}
