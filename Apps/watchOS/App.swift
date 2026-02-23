import SwiftUI
import AetherNotesUseCases
import AetherNotesUIShared

@main
struct AetherNotesWatchOSApp: App {
    private let environment = AppEnvironment.makeDefault()

    var body: some Scene {
        WindowGroup {
            NotesListView(environment: environment)
        }
    }
}
