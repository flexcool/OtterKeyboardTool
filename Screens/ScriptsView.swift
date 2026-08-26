import SwiftUI
import CoreData

struct ScriptsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Script.order, ascending: true)],
        animation: .default)
    private var scripts: FetchedResults<Script>

    @State private var showAdd = false
    @State private var editTarget: Script?
    @State private var toast: String?

    var body: some View {
        NavigationStack {
            Group {
                if scripts.isEmpty {
                    VStack(spacing: 12) {
                        Text(TL("scripts_empty.tip1")).foregroundStyle(.secondary)
                        Button(TL("scripts_empty.tip2")) { showAdd = true }.font(.headline)
                    }
                } else {
                    List {
                        ForEach(scripts) { script in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(script.name ?? "").font(.headline)
                                    if script.isNetRequest {
                                        Label(TL("new_script.is_net_request"), systemImage: "network")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Button { runTest(script) } label: { Image(systemName: "play") }
                                    .buttonStyle(.borderless)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { editTarget = script }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .navigationTitle(TL("script.list_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { ScriptEditView() }
            .sheet(item: $editTarget) { ScriptEditView(script: $0) }
            .overlay(toastOverlay)
        }
    }

    private var toastOverlay: some View {
        Group {
            if let toast {
                Text(toast)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .transition(.opacity)
                    .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.toast = nil } }
            }
        }
    }

    private func runTest(_ script: Script) {
        let runner = ScriptRunner.shared
        let arg: String = script.isParams ? "" : ""
        runner.run(script.code ?? "", arg: arg.isEmpty ? nil : arg) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let candidates):
                    self.toast = candidates.joined(separator: " | ").prefix(120).description
                case .failure(let err):
                    self.toast = err.localizedDescription.prefix(120).description
                }
            }
        }
    }

    private func deleteItems(_ offsets: IndexSet) {
        for index in offsets { viewContext.delete(scripts[index]) }
        try? viewContext.save()
    }
}

struct ScriptEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var script: Script

    @State private var name: String
    @State private var code: String
    @State private var isParams: Bool
    @State private var isNetRequest: Bool
    @State private var testParam: String = ""
    @State private var testOutput: String = ""
    @State private var showNetHelp = false

    init(script: Script? = nil) {
        let s: Script
        if let script { s = script } else {
            s = Script(context: PersistenceController.shared.viewContext)
        }
        _script = ObservedObject(initialValue: s)
        _name = State(initialValue: script?.name ?? "")
        _code = State(initialValue: script?.code ?? ScriptRunner.template)
        _isParams = State(initialValue: script?.isParams ?? false)
        _isNetRequest = State(initialValue: script?.isNetRequest ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(TL("new_script.title")) {
                    TextField(TL("new_script.title"), text: $name)
                }
                Section {
                    Toggle(TL("new_script.is_params"), isOn: $isParams)
                    Toggle(TL("new_script.is_net_request"), isOn: $isNetRequest)
                }
                Section(TL("new_script.script")) {
                    TextEditor(text: $code)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 220)
                    Button(TL("new_script.run_test")) { runTest() }
                    if isParams {
                        TextField(TL("new_script.test_params"), text: $testParam)
                    }
                    if !testOutput.isEmpty {
                        Text(testOutput).font(.footnote).foregroundStyle(.secondary)
                    }
                    Button { showNetHelp = true } label: { Label(TL("new_script.is_net_request"), systemImage: "network") }
                }
            }
            .navigationTitle(script.name?.isEmpty == false ? script.name! : TL("new_script.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(TL("cancel")) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button(TL("save")) { save(); dismiss() } }
            }
            .sheet(isPresented: $showNetHelp) {
                ScrollView { Text(TL("script.net_help")).padding() }
                    .presentationDetents([.medium, .large])
                    .navigationTitle(TL("new_script.is_net_request"))
            }
        }
    }

    private func runTest() {
        ScriptRunner.shared.run(code, arg: isParams ? testParam : nil) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let c): testOutput = c.joined(separator: "\n")
                case .failure(let e): testOutput = e.localizedDescription
                }
            }
        }
    }

    private func save() {
        script.name = name.isEmpty ? TL("new_script.title") : name
        script.code = code
        script.isParams = isParams
        script.isNetRequest = isNetRequest
        script.createdAt = script.createdAt ?? Date()
        try? viewContext.save()
    }
}
