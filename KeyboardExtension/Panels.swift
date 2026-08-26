import SwiftUI
import CoreData
import UIKit

// MARK: - Clipboard panel

struct ClipboardPanel: View {
    let engine: KeyboardEngine
    let onLongPress: (Clipboard) -> Void
    let onInsert: (String) -> Void

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Clipboard.createdAt, ascending: false)])
    private var items: FetchedResults<Clipboard>

    @State private var showClear = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(TL("clipboard.list_title")).font(.caption.bold())
                Spacer()
                Button(TL("delete")) { showClear = true }
                    .font(.caption).foregroundStyle(.red)
            }
            .padding(.horizontal, 10).padding(.vertical, 4)

            if items.isEmpty {
                Spacer()
                Text(TL("clipboard_empty.tip1") + " " + TL("clipboard_empty.tip2"))
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(items) { item in
                        Text(item.content ?? "")
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture { onInsert(item.content ?? "") }
                            .onLongPressGesture { onLongPress(item) }
                    }
                    .onDelete { offsets in
                        for i in offsets { PersistenceController.shared.deleteClipboard(items[i]) }
                    }
                }
                .listStyle(.plain)
            }
        }
        .alert(TL("clipboard.delete_all.tip"), isPresented: $showClear) {
            Button(TL("cancel"), role: .cancel) {}
            Button(TL("ok"), role: .destructive) { PersistenceController.shared.clearClipboards() }
        }
    }
}

// MARK: - Phrase panel

struct PhrasePanel: View {
    let engine: KeyboardEngine
    let onLongPress: (Phrase) -> Void
    let onInsert: (String) -> Void

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseSet.order, ascending: true)])
    private var sets: FetchedResults<PhraseSet>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Phrase.createdAt, ascending: true)])
    private var phrases: FetchedResults<Phrase>

    @State private var selectedSetID: NSManagedObjectID?

    private var currentSet: PhraseSet? {
        if let id = selectedSetID, let found = sets.first(where: { $0.objectID == id }) { return found }
        return sets.first
    }

    var body: some View {
        VStack(spacing: 0) {
            if sets.isEmpty {
                Spacer()
                Text(TL("phrase_empty.tip1") + " " + TL("phrase_empty.tip2"))
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            } else {
                Picker(TL("phrase_set.list_title"), selection: $selectedSetID) {
                    ForEach(sets) { set in
                        Text(set.name ?? "").tag(set.objectID as NSManagedObjectID?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .onAppear { if selectedSetID == nil { selectedSetID = sets.first?.objectID } }

                let set = currentSet
                let filtered = phrases.filter { $0.set == set }
                if filtered.isEmpty {
                    Spacer()
                    Text(TL("phrase_empty.tip1")).font(.caption).foregroundStyle(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(filtered) { phrase in
                            Text(phrase.content ?? "")
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture { onInsert(phrase.content ?? "") }
                                .onLongPressGesture { onLongPress(phrase) }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Script panel

struct ScriptPanel: View {
    let engine: KeyboardEngine
    @Binding var candidates: [String]

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Script.order, ascending: true)])
    private var scripts: FetchedResults<Script>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Clipboard.createdAt, ascending: false)])
    private var clipboards: FetchedResults<Clipboard>

    @State private var paramScript: Script?
    @State private var toast: String?

    var body: some View {
        VStack(spacing: 0) {
            if scripts.isEmpty {
                Spacer()
                Text(TL("scripts_empty.tip1") + " " + TL("scripts_empty.tip2"))
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(scripts) { script in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(script.name ?? "").font(.subheadline.bold())
                                if script.isNetRequest {
                                    Label(TL("new_script.is_net_request"), systemImage: "network")
                                        .font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { run(script) }
                    }
                }
                .listStyle(.plain)
            }
        }
        .sheet(item: $paramScript) { script in
            NavigationStack {
                List {
                    if let sel = engine.selectedText, !sel.isEmpty {
                        Button(TL("script.choose_params.tip") + ": " + sel.prefix(20)) {
                            execute(script, arg: sel)
                        }
                    }
                    ForEach(clipboards) { c in
                        Button(c.content ?? "") { execute(script, arg: c.content ?? "") }
                    }
                }
                .navigationTitle(script.name ?? "")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button(TL("cancel")) { paramScript = nil } }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .overlay(toastOverlay)
    }

    private var toastOverlay: some View {
        Group {
            if let toast {
                Text(toast).font(.caption).padding(8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .transition(.opacity)
                    .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.toast = nil } }
            }
        }
    }

    private func run(_ script: Script) {
        if script.isParams {
            paramScript = script
        } else {
            execute(script, arg: nil)
        }
    }

    private func execute(_ script: Script, arg: String?) {
        paramScript = nil
        ScriptRunner.shared.run(script.code ?? "", arg: arg) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    if list.isEmpty {
                        self.toast = TL("pasted.tip")
                    } else if list.count == 1 {
                        self.engine.insert(list[0])
                        self.toast = TL("pasted.tip")
                    } else {
                        self.candidates = list
                        self.toast = nil
                    }
                case .failure(let err):
                    self.toast = err.localizedDescription
                }
            }
        }
    }
}

// MARK: - Setting panel (inside keyboard)

struct KeyboardSettingPanel: View {
    @AppStorage(SettingsKeys.autoSaveClipboard, store: SharedDefaults.store) private var autoSave = false
    @AppStorage(SettingsKeys.useEmoji, store: SharedDefaults.store) private var useEmoji = false
    @AppStorage(SettingsKeys.isSound, store: SharedDefaults.store) private var isSound = true
    @AppStorage(SettingsKeys.isVibration, store: SharedDefaults.store) private var isVibration = true
    @AppStorage("bigBoomEnabled", store: SharedDefaults.store) private var bigBoom = true

    var body: some View {
        Form {
            Section(TL("setting.keyboard")) {
                Toggle(TL("setting.section.auto_save"), isOn: $autoSave)
                Toggle(TL("setting.section.big_boom"), isOn: $bigBoom)
                Toggle(TL("setting.section.is_emoji"), isOn: $useEmoji)
            }
            Section(TL("setting.is_sound.is_sound")) {
                Toggle(TL("setting.is_sound.is_sound"), isOn: $isSound)
                Toggle(TL("setting.is_sound.is_vibration"), isOn: $isVibration)
            }
            Section {
                Button(TL("setting.section.jump_to_setting")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
            Section {
                Text(TL("data_in_app_and_keyboard.tip")).font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
