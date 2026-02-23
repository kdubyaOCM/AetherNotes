import SwiftUI

/// Stub recording status banner. Full implementation arrives in Phase 03 (Audio Pipeline).
public struct RecordingStatusView: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "mic.slash")
                .foregroundStyle(.secondary)
            Text("Recording not available in Phase 01.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
