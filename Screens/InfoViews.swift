import SwiftUI
import UIKit

// MARK: - Add keyboard guide

struct AddKeyboardView: View {
    @AppStorage(SettingsKeys.hasLaunched, store: SharedDefaults.store) private var hasLaunched = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "keyboard").font(.system(size: 64)).foregroundStyle(.tint)
                Text(TL("add_keyboard.title")).font(.title2.bold())
                Text(TL("add_keyboard.intro"))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                Button(TL("button.add_keyboard.title")) { openSettings() }
                    .buttonStyle(.borderedProminent)
                Button(TL("button.into_app.title")) { hasLaunched = true }
                    .buttonStyle(.bordered)
            }
            .navigationTitle(TL("app_display_name"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(TL("button.next_setp.title")) { hasLaunched = true }
                }
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - About

struct AboutView: View {
    private let version = Bundle.main.infoDictionary?.["CFBundleShortVersionString"] as? String ?? "1.2"
    private let build = Bundle.main.infoDictionary?.["CFBundleVersion"] as? String ?? "3"

    var body: some View {
        Form {
            Section(TL("about.version")) {
                LabeledContent(TL("about.version"), value: "\(version) (\(build))")
            }
            Section {
                Link(TL("about.contact_me"), destination: URL(string: "mailto:wongjun@qq.com")!)
                Link(TL("about.feedback"), destination: URL(string: "mailto:wongjun@qq.com")!)
            }
        }
        .navigationTitle(TL("setting.section.about"))
    }
}

// MARK: - Release notes

struct ReleaseNotesView: View {
    private let notes: [(version: String, key: String)] = [
        ("1.2", "release_note.1.2"),
        ("1.1.1", "release_note.1.1.1"),
        ("1.1", "release_note.1.1"),
        ("1.0.1", "release_note.1.0.1")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(notes, id: \.version) { note in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("v" + note.version).font(.headline
                        )
                        Text(TL(note.key)).font(.callout).foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(TL("setting.section.release_notes"))
    }
}

// MARK: - Q & A

struct QAView: View {
    private let pairs: [(q: String, a: String)] = [
        ("script.introduce.question_1", "script.introduce.answer_1"),
        ("script.introduce.question_2", "script.introduce.answer_2"),
        ("script.introduce.question_3", "script.introduce.answer_3"),
        ("script.introduce.question_4", "script.introduce.answer_4"),
        ("script.introduce.question_5", "script.introduce.answer_5")
    ]

    var body: some View {
        List {
            ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                Section {
                    Text(TL(pair.a)).font(.callout)
                } header: {
                    Text(TL(pair.q)).textCase(.none).font(.subheadline.bold())
                }
            }
        }
        .navigationTitle(TL("setting.section.q&a"))
    }
}
