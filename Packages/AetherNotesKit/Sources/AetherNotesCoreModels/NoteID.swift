import Foundation

/// Stable, typed identifier for a Note.
public struct NoteID: Hashable, Equatable, Sendable, Codable, CustomStringConvertible {
    public let rawValue: UUID

    public init(rawValue: UUID = UUID()) {
        self.rawValue = rawValue
    }

    public static func make() -> NoteID {
        NoteID(rawValue: UUID())
    }

    public var description: String { "note:\(rawValue.uuidString)" }
}
