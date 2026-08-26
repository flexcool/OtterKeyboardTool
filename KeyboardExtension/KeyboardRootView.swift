import SwiftUI

enum KeyboardTab: String, CaseIterable {
    case clipboard, phrase, script, setting

    var titleKey: String {
        switch self {
        case .clipboard: return "bottom_bar.clipboard"
        case .phrase: return "bottom_bar.phrase"
        case .script: return "bottom_bar.script"
        case .setting: return "bottom_bar.setting"
        }
    }
    var systemImage: String {
        switch self {
        case .clipboard: return "doc.on.clipboard"
        case .phrase: return "text.quote"
        case .script: return "terminal"
        case .setting: return "gearshape"
        }
    }
    var emoji: String {
        switch self {
        case .clipboard: return "📋"
        case .phrase: return "💬"
        case .script: return "📜"
        case .setting: return "⚙️"
        }
    }
}

struct KeyboardRootView: View {
    @EnvironmentObject private var engine: KeyboardEngine
    @AppStorage(SettingsKeys.menuOrder, store: SharedDefaults.store) private var orderRaw = ""
    @AppStorage(SettingsKeys.useEmoji, store: SharedDefaults.store) private var useEmoji = false
    @AppStorage("bigBoomEnabled", store: SharedDefaults.store) private var bigBoom = true

    @State private var selectedTab: KeyboardTab = .clipboard
    @State private var candidates: [String] = []
    @State private var explosion: ExplosionTarget?

    private var orderedTabs: [KeyboardTab] {
        let saved = orderRaw.split(separator: ",").compactMap { KeyboardTab(rawValue: String($0)) }
        let known = KeyboardTab.allCases
        let merged = (saved + known).filter { known.contains($0) }
        var seen = Set<KeyboardTab>()
        return merged.filter { seen.insert($0).inserted }
    }

    var body: some View {
        VStack(spacing: 0) {
            if !engine.hasFullAccess {
                fullAccessBanner
            }
            candidateBar
            panel
            tabBar
            keyRow
        }
        .background(Color(.systemBackground))
        .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        .overlay { if let target = explosion { explosionOverlay(target) }
    }

    private var fullAccessBanner: some View {
        Text(TL("fullaccess.tip"))
            .font(.caption2)
            .frame(maxWidth: .infinity)
            .padding(4)
            .background(Color(.secondarySystemBackground))
    }

    private var candidateBar: some View {
        Group {
            if !candidates.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(candidates, id: \.self) { c in
                            Button { engine.insert(c); candidates.removeAll() } label: {
                                Text(c).padding(.horizontal, 10).padding(.vertical, 6)
                                    .background(Color(.tertiarySystemBackground), in: Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                }
                .frame(height: 40)
                .background(Color(.secondarySystemBackground))
            }
        }
    }

    @ViewBuilder private var panel: some View {
        switch selectedTab {
        case .clipboard:
            ClipboardPanel(engine: engine, onLongPress: { item in
                if bigBoom { explosion = .clipboard(item) }
            }, onInsert: { engine.insert($0) })
        case .phrase:
            PhrasePanel(engine: engine, onLongPress: { item in
                if bigBoom { explosion = .phrase(item) }
            }, onInsert: { engine.insert($0) })
        case .script:
            ScriptPanel(engine: engine, candidates: $candidates)
        case .setting:
            KeyboardSettingPanel()
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(orderedTabs, id: \.self) { tab in
                Button {
                    selectedTab = tab
                    candidates.removeAll()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: tab.systemImage)
                        Text(TL(tab.titleKey)).font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
                }
            }
        }
        .background(Color(.secondarySystemBackground))
    }

    private var keyRow: some View {
        HStack(spacing: 0) {
            Button { engine.advance() } label: {
                Image(systemName: "globe").frame(maxWidth: .infinity).padding(.vertical, 12)
            }
            Button { engine.space() } label: {
                Text("空格").frame(maxWidth: .infinity).padding(.vertical, 12)
            }
            Button { engine.deleteBackward() } label: {
                Image(systemName: "delete.left").frame(maxWidth: .infinity).padding(.vertical, 12)
            }
            Button { engine.`return`() } label: {
                Image(systemName: "return").frame(maxWidth: .infinity).padding(.vertical, 12)
            }
        }
        .background(Color(.tertiarySystemBackground))
        .foregroundStyle(Color.primary)
    }

    private func explosionOverlay(_ target: ExplosionTarget) -> some View {
        ExplosionView(target: target) { inserted in
            engine.insert(inserted)
            explosion = nil
        } onDelete: {
            explosion = nil
        }
        .ignoresSafeArea()
    }
}

/// What the explosion (word segmentation) view is operating on.
enum ExplosionTarget: Identifiable {
    case clipboard(Clipboard)
    case phrase(Phrase)

    var id: String {
        switch self {
        case .clipboard(let c): return "clipboard:" + (c.content ?? "")
        case .phrase(let p): return "phrase:" + (p.content ?? "")
        }
    }
    var content: String { switch self { case .clipboard(let c): return c.content ?? ""; case .phrase(let p): return p.content ?? "" } }
}
