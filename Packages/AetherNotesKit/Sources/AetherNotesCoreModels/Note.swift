import Foundation

/// Core domain model for a note. Value type; SwiftData @Model wrapping deferred to Phase 02.
public struct Note: Equatable, Hashable, Sendable, Identifiable, Codable {
    public let id: NoteID
    public var title: String
    public var body: String
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: NoteID = .make(),
        title: String,
        body: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
