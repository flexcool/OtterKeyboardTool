import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKeys.autoSaveClipboard, store: SharedDefaults.store) private var autoSave = false
    @AppStorage("bigBoomEnabled", store: SharedDefaults.store) private var bigBoom = true
    @AppStorage(SettingsKeys.useEmoji, store: SharedDefaults.store) private var useEmoji = false
    @AppStorage(SettingsKeys.isSound, store: SharedDefaults.store) private var isSound = true
    @AppStorage(SettingsKeys.isVibration, store: SharedDefaults.store) private var isVibration = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(TL("setting.section.about")) { AboutView() }
                    NavigationLink(TL("setting.section.release_notes")) { ReleaseNotesView() }
                    NavigationLink(TL("setting.section.q&a")) { QAView() }
                }
                Section(TL("setting.keyboard")) {
                    Toggle(TL("setting.section.auto_save"), isOn: $autoSave)
                    Toggle(TL("setting.section.big_boom"), isOn: $bigBoom)
                    Toggle(TL("setting.section.is_emoji"), isOn: $useEmoji)
                    NavigationLink(TL("setting.keyboard_order.title")) { KeyboardHeightView() }
                    NavigationLink(TL("setting.menu_order.title")) { MenuOrderView() }
                }
                Section(TL("setting.is_sound.is_sound")) {
                    Toggle(TL("setting.is_sound.is_sound"), isOn: $isSound)
                    Toggle(TL("setting.is_sound.is_vibration"), isOn: $isVibration)
                }
                Section {
                    Button(TL("setting.section.jump_to_setting")) { openSystemSettings() }
                }
            }
            .navigationTitle(TL("bottom_bar.setting"))
        }
    }

    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct KeyboardHeightView: View {
    @AppStorage(SettingsKeys.keyboardHeightPortrait, store: SharedDefaults.store) private var portrait = 260.0
    @AppStorage(SettingsKeys.keyboardHeightLandscape, store: SharedDefaults.store) private var landscape = 220.0

    var body: some View {
        Form {
            Section(TL("keyboard.height.portrait")) {
                Slider(value: $portrait, in: 180...420, step: 10) { Text("") }
                Text("\(Int(portrait)) pt").foregroundStyle(.secondary)
            }
            Section(TL("keyboard.height.landscape")) {
                Slider(value: $landscape, in: 160...380, step: 10) { Text("") }
                Text("\(Int(landscape)) pt").foregroundStyle(.secondary)
            }
        }
        .navigationTitle(TL("setting.keyboard_order.title"))
    }
}

struct MenuOrderView: View {
    @AppStorage(SettingsKeys.menuOrder, store: SharedDefaults.store) private var orderRaw = ""

    private let allTabs: [(id: String, title: String)] = [
        ("clipboard", "bottom_bar.clipboard"),
        ("phrase", "bottom_bar.phrase"),
        ("script", "bottom_bar.script"),
        ("setting", "bottom_bar.setting")
    ]

    private var ordered: [String] {
        let saved = orderRaw.split(separator: ",").map(String.init)
        let known = allTabs.map(\.id)
        let merged = (saved + known).filter { known.contains($0) }
        return Array(NSOrderedSet(array: merged).array as? [String] ?? merged).filter { known.contains($0) }
    }

    var body: some View {
        Form {
            Section(footer: Text(TL("setting.menu_order.title"))) {
                List {
                    ForEach(ordered, id: \.self) { id in
                        if let tab = allTabs.first(where: { $0.id == id }) {
                            Label(TL(tab.title), systemImage: "line.horizontal.3")
                        }
                    }
                    .onMove { from, to in
                        var arr = ordered
                        arr.move(fromOffsets: from, toOffset: to)
                        orderRaw = arr.joined(separator: ",")
                    }
                }
            }
        }
        .navigationTitle(TL("setting.menu_order.title"))
        .toolbar { EditButton() }
    }
}
