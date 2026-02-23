import XCTest
@testable import AetherNotesCoreModels

final class NoteIDTests: XCTestCase {

    func testMakeProducesUniqueIDs() {
        let a = NoteID.make()
        let b = NoteID.make()
        XCTAssertNotEqual(a, b)
    }

    func testDescriptionContainsPrefix() {
        let id = NoteID.make()
        XCTAssertTrue(id.description.hasPrefix("note:"), "Expected 'note:' prefix, got: \(id.description)")
    }

    func testDescriptionContainsUUIDString() {
        let id = NoteID.make()
        XCTAssertTrue(id.description.contains(id.rawValue.uuidString))
    }

    func testEqualityBasedOnRawValue() {
        let uuid = UUID()
        let a = NoteID(rawValue: uuid)
        let b = NoteID(rawValue: uuid)
        XCTAssertEqual(a, b)
    }

    func testHashableConsistency() {
        let id = NoteID.make()
        var set = Set<NoteID>()
        set.insert(id)
        set.insert(id)
        XCTAssertEqual(set.count, 1)
    }

    func testCodingRoundtrip() throws {
        let id = NoteID.make()
        let data = try JSONEncoder().encode(id)
        let decoded = try JSONDecoder().decode(NoteID.self, from: data)
        XCTAssertEqual(id, decoded)
    }

    func testNoteEquality() {
        let id = NoteID.make()
        let timestamp = Date(timeIntervalSince1970: 1_234_567)
        let noteA = Note(id: id, title: "Hello", createdAt: timestamp, updatedAt: timestamp)
        let noteB = Note(id: id, title: "Hello", createdAt: timestamp, updatedAt: timestamp)
        XCTAssertEqual(noteA, noteB)
    }

    func testRecordingIDDescriptionPrefix() {
        let id = RecordingID.make()
        XCTAssertTrue(id.description.hasPrefix("recording:"), "Expected 'recording:' prefix, got: \(id.description)")
    }
}
