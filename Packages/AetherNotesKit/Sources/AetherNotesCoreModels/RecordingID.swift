import Foundation

/// Stable, typed identifier for a Recording.
public struct RecordingID: Hashable, Equatable, Sendable, Codable, CustomStringConvertible {
    public let rawValue: UUID

    public init(rawValue: UUID = UUID()) {
        self.rawValue = rawValue
    }

    public static func make() -> RecordingID {
        RecordingID(rawValue: UUID())
    }

    public var description: String { "recording:\(rawValue.uuidString)" }
}
