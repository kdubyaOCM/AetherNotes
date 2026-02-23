import SwiftUI
import AetherNotesUseCases
import AetherNotesUIShared

@main
struct AetherNotesMacOSApp: App {
    private let environment = AppEnvironment.makeDefault()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                Text("Sidebar")
                    .frame(minWidth: 200)
            } detail: {
                NotesListView(environment: environment)
            }
        }
        .commands {
            CommandGroup(after: .newItem) {}
        }
    }
}
