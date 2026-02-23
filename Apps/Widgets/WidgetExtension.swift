import WidgetKit
import SwiftUI

/// Phase 01 WidgetKit scaffold. Full widget content and Live Activity arrive in Phase 05+.
/// No package imports needed: widget shows static placeholder only.

struct PlaceholderEntry: TimelineEntry {
    let date: Date
}

struct PlaceholderTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PlaceholderEntry {
        PlaceholderEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (PlaceholderEntry) -> Void) {
        completion(PlaceholderEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<PlaceholderEntry>) -> Void) {
        completion(Timeline(entries: [PlaceholderEntry(date: Date())], policy: .never))
    }
}

struct AetherNotesWidgetView: View {
    let entry: PlaceholderEntry

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "note.text")
                .font(.title2)
            Text("AetherNotes")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct AetherNotesWidget: Widget {
    let kind = "AetherNotesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlaceholderTimelineProvider()) { entry in
            AetherNotesWidgetView(entry: entry)
        }
        .configurationDisplayName("AetherNotes")
        .description("Your notes at a glance. Phase 01 placeholder.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct AetherNotesWidgetBundle: WidgetBundle {
    var body: some Widget {
        AetherNotesWidget()
    }
}
