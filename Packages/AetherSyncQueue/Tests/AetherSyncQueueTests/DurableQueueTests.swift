import Foundation
import Testing
@testable import AetherSyncQueue

// MARK: - DurableQueueTests

@Suite("DurableQueue")
struct DurableQueueTests {

    // MARK: Helpers

    /// Create a fresh temporary directory for each test.
    private func makeTempDirectory() throws -> URL {
        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("AetherSyncQueueTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    // MARK: - Enqueue 100 items, restart, assert ordering

    @Test("enqueue 100 items, restart queue, ordering preserved")
    func enqueueAndRestart() async throws {
        let dir = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        // Phase 1: enqueue 100 items in a first queue instance.
        var expectedIDs: [UUID] = []
        do {
            let queue = try DurableQueue(directoryURL: dir)
            for i in 0..<100 {
                let item = try await queue.enqueue(
                    kind: "test.item",
                    payload: Data("payload-\(i)".utf8)
                )
                expectedIDs.append(item.id)
            }
        }

        // Phase 2: create a brand-new instance pointing at the same
        // directory (simulates app / extension restart).
        let queue2 = try DurableQueue(directoryURL: dir)
        let items = try await queue2.peek(limit: 200)

        #expect(items.count == 100)
        let retrievedIDs = items.map(\.id)
        #expect(retrievedIDs == expectedIDs)
    }

    // MARK: - Failure and retry increments attempts

    @Test("markFailed increments attempts counter")
    func failureIncrementsAttempts() async throws {
        let dir = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        let queue = try DurableQueue(directoryURL: dir)
        let item = try await queue.enqueue(kind: "sync.push", payload: Data("x".utf8))

        #expect(item.attempts == 0)

        // Fail it twice.
        try await queue.markFailed(item.id, retryAfter: nil)
        try await queue.markFailed(item.id, retryAfter: nil)

        let peeked = try await queue.peek(limit: 1)
        #expect(peeked.count == 1)
        #expect(peeked[0].attempts == 2)
    }

    @Test("markFailed with retryAfter hides item from peek")
    func retryAfterHidesItem() async throws {
        let dir = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        let queue = try DurableQueue(directoryURL: dir)
        let item = try await queue.enqueue(kind: "sync.push", payload: Data("y".utf8))

        // Fail with a large retry window so it is hidden from peek.
        try await queue.markFailed(item.id, retryAfter: 3600)

        let peeked = try await queue.peek(limit: 10)
        #expect(peeked.isEmpty)
    }

    // MARK: - Purge

    @Test("purge removes items older than threshold")
    func purgeWorks() async throws {
        let dir = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        let queue = try DurableQueue(directoryURL: dir)

        // Enqueue two items.
        _ = try await queue.enqueue(kind: "old", payload: Data("a".utf8))
        _ = try await queue.enqueue(kind: "new", payload: Data("b".utf8))

        // Purge items older than 0 seconds (everything).
        try await queue.purge(olderThan: 0)

        let remaining = try await queue.peek(limit: 10)
        #expect(remaining.isEmpty)
    }

    @Test("purge keeps recent items")
    func purgeKeepsRecent() async throws {
        let dir = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        let queue = try DurableQueue(directoryURL: dir)

        _ = try await queue.enqueue(kind: "keep", payload: Data("keep".utf8))

        // Purge items older than 1 hour — our freshly enqueued item
        // should survive.
        try await queue.purge(olderThan: 3600)

        let remaining = try await queue.peek(limit: 10)
        #expect(remaining.count == 1)
    }

    // MARK: - markSucceeded

    @Test("markSucceeded removes the item from the queue")
    func markSucceeded() async throws {
        let dir = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        let queue = try DurableQueue(directoryURL: dir)
        let item = try await queue.enqueue(kind: "done", payload: Data("z".utf8))

        try await queue.markSucceeded(item.id)

        let peeked = try await queue.peek(limit: 10)
        #expect(peeked.isEmpty)
    }
}
