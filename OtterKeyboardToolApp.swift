import SwiftUI

@main
struct OtterKeyboardToolApp: App {
    @AppStorage(SettingsKeys.hasLaunched, store: SharedDefaults.store)
    private var hasLaunched = false

    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.viewContext)
                .onAppear { hasLaunched = true }
        }
    }
}
