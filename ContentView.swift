import SwiftUI

struct ContentView: View {
    @AppStorage(SettingsKeys.hasLaunched, store: SharedDefaults.store)
    private var hasLaunched = false

    var body: some View {
        if !hasLaunched {
            AddKeyboardView()
        } else {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ClipboardListView()
                .tabItem { Label(TL("bottom_bar.clipboard"), systemImage: "doc.on.clipboard") }
            PhraseSetsView()
                .tabItem { Label(TL("bottom_bar.phrase"), systemImage: "text.quote") }
            ScriptsView()
                .tabItem { Label(TL("bottom_bar.script"), systemImage: "terminal") }
            SettingsView()
                .tabItem { Label(TL("bottom_bar.setting"), systemImage: "gearshape") }
        }
    }
}
