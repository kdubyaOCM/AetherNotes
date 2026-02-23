import Foundation

/// A single work item in the durable queue.
///
/// Each item is serialised as an individual JSON file on disk so that
/// a crash can never corrupt more than one item.
public struct QueueItem: Codable, Identifiable, Sendable {
    /// Unique identifier for the item.
    public let id: UUID
    /// Timestamp when the item was first enqueued.
    public let createdAt: Date
    /// Number of delivery attempts (starts at 0).
    public private(set) var attempts: Int
    /// Opaque payload (kept small — typically < 256 KB on watchOS).
    public let payload: Data
    /// Application-defined type discriminator (e.g. "note.create").
    public let kind: String
    /// If non-nil, the item should not be retried before this date.
    public var retryAfter: Date?

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        attempts: Int = 0,
        payload: Data,
        kind: String,
        retryAfter: Date? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.attempts = attempts
        self.payload = payload
        self.kind = kind
        self.retryAfter = retryAfter
    }

    // MARK: - Internal mutating helpers

    /// Increment the attempt counter.
    mutating func incrementAttempts() {
        attempts += 1
    }
}
