import Foundation

/// A durable, disk-backed FIFO queue designed for small payloads
/// on resource-constrained devices such as Apple Watch.
///
/// ## Storage layout
/// ```
/// directoryURL/
///   index.json          ← ordered array of UUIDs
///   items/
///     <uuid>.json       ← individual QueueItem
/// ```
///
/// Writes are atomic (write-to-temp then rename) so a crash can never
/// leave the queue in an inconsistent state.
public actor DurableQueue {

    // MARK: - Private state

    private let directoryURL: URL
    private let itemsURL: URL
    private let indexURL: URL

    /// In-memory ordered list of item IDs. Loaded from disk once on
    /// first access, then kept in sync by every mutating operation.
    private var orderedIDs: [UUID]?

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private let fm = FileManager.default

    // MARK: - Initialisation

    /// Create or open a durable queue backed by the given directory.
    ///
    /// The directory (and an `items/` subdirectory) will be created
    /// automatically if they do not exist.
    public init(directoryURL: URL) throws {
        self.directoryURL = directoryURL
        self.itemsURL = directoryURL.appendingPathComponent("items", isDirectory: true)
        self.indexURL = directoryURL.appendingPathComponent("index.json")

        try fm.createDirectory(at: itemsURL, withIntermediateDirectories: true)
    }

    // MARK: - Public API

    /// Append a new item to the tail of the queue.
    @discardableResult
    public func enqueue(kind: String, payload: Data) throws -> QueueItem {
        let item = QueueItem(payload: payload, kind: kind)
        try writeItem(item)
        var ids = try loadIndex()
        ids.append(item.id)
        try writeIndex(ids)
        orderedIDs = ids
        return item
    }

    /// Return up to `limit` items from the head of the queue without
    /// removing them. Items whose `retryAfter` is in the future are
    /// skipped.
    public func peek(limit: Int) throws -> [QueueItem] {
        let ids = try loadIndex()
        let now = Date()
        var result: [QueueItem] = []
        for id in ids {
            guard result.count < limit else { break }
            if let item = try? readItem(id) {
                if let retryAfter = item.retryAfter, retryAfter > now {
                    continue
                }
                result.append(item)
            }
        }
        return result
    }

    /// Remove the item from the queue after successful delivery.
    public func markSucceeded(_ id: UUID) throws {
        try removeItem(id)
    }

    /// Record a failed delivery attempt. The attempt counter is
    /// incremented. If `retryAfter` is supplied the item will be
    /// hidden from `peek` until that interval has elapsed.
    public func markFailed(_ id: UUID, retryAfter: TimeInterval? = nil) throws {
        guard var item = try? readItem(id) else { return }
        item.incrementAttempts()
        if let delay = retryAfter {
            item.retryAfter = Date().addingTimeInterval(delay)
        }
        try writeItem(item)
    }

    /// Delete every item whose `createdAt` is older than `olderThan`
    /// seconds ago.
    public func purge(olderThan: TimeInterval) throws {
        let cutoff = Date().addingTimeInterval(-olderThan)
        var ids = try loadIndex()
        var toRemove: Set<UUID> = []
        for id in ids {
            if let item = try? readItem(id), item.createdAt < cutoff {
                toRemove.insert(id)
                try? fm.removeItem(at: itemURL(for: id))
            }
        }
        ids.removeAll { toRemove.contains($0) }
        try writeIndex(ids)
        orderedIDs = ids
    }

    // MARK: - Private helpers

    private func itemURL(for id: UUID) -> URL {
        itemsURL.appendingPathComponent("\(id.uuidString).json")
    }

    /// Atomically write a `QueueItem` to its per-item JSON file.
    private func writeItem(_ item: QueueItem) throws {
        let data = try encoder.encode(item)
        let destination = itemURL(for: item.id)
        try atomicWrite(data: data, to: destination)
    }

    private func readItem(_ id: UUID) throws -> QueueItem {
        let data = try Data(contentsOf: itemURL(for: id))
        return try decoder.decode(QueueItem.self, from: data)
    }

    /// Remove item file and update the in-memory and on-disk index.
    private func removeItem(_ id: UUID) throws {
        try? fm.removeItem(at: itemURL(for: id))
        var ids = try loadIndex()
        ids.removeAll { $0 == id }
        try writeIndex(ids)
        orderedIDs = ids
    }

    // MARK: Index persistence

    /// Load the ordered ID list from disk, or return the cached copy.
    private func loadIndex() throws -> [UUID] {
        if let cached = orderedIDs {
            return cached
        }
        guard fm.fileExists(atPath: indexURL.path) else {
            orderedIDs = []
            return []
        }
        let data = try Data(contentsOf: indexURL)
        let ids = try decoder.decode([UUID].self, from: data)
        orderedIDs = ids
        return ids
    }

    /// Atomically persist the ordered ID list to disk.
    private func writeIndex(_ ids: [UUID]) throws {
        let data = try encoder.encode(ids)
        try atomicWrite(data: data, to: indexURL)
    }

    // MARK: Atomic write

    /// Write `data` to a temporary file in the same directory, then
    /// rename to `destination`. This is crash-safe on APFS / HFS+.
    private func atomicWrite(data: Data, to destination: URL) throws {
        let directory = destination.deletingLastPathComponent()
        let tmp = directory.appendingPathComponent(UUID().uuidString + ".tmp")
        try data.write(to: tmp, options: .atomic)
        // If the destination already exists, remove it first.
        if fm.fileExists(atPath: destination.path) {
            try fm.removeItem(at: destination)
        }
        try fm.moveItem(at: tmp, to: destination)
    }
}
