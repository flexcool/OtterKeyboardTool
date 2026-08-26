import SwiftUI
import CoreData
import UIKit

struct ClipboardListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Clipboard.createdAt, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Clipboard>

    @State private var showAdd = false
    @State private var newText = ""
    @State private var showClearConfirm = false
    @State private var toast: String?

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyView
                } else {
                    List {
                        ForEach(items) { item in
                            row(item)
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .navigationTitle(TL("clipboard.list_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(TL("delete"), role: .destructive) { showClearConfirm = true }
                        .disabled(items.isEmpty)
                }
            }
            .sheet(isPresented: $showAdd) { addSheet }
            .alert(TL("clipboard.delete_all.tip"), isPresented: $showClearConfirm) {
                Button(TL("cancel"), role: .cancel) {}
                Button(TL("ok"), role: .destructive) { clearAll() }
            }
            .overlay(toastOverlay)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Text(TL("clipboard_empty.tip1")).foregroundStyle(.secondary)
            Button(TL("clipboard_empty.tip2")) { copyFromSystem() }
                .font(.headline)
        }
    }

    private func row(_ item: Clipboard) -> some View {
        HStack {
            Text(item.content ?? "")
                .lineLimit(3)
            Spacer()
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button { copy(item.content) } label: { Label(TL("pasted.tip"), systemImage: "doc.on.doc") }
            Button { saveAsPhrase(item.content) } label: { Label(TL("save.to_phrase"), systemImage: "text.badge.plus") }
            Button(role: .destructive) { delete(item) } label: { Label(TL("delete"), systemImage: "trash") }
        }
        .onTapGesture { copy(item.content) }
    }

    private var addSheet: some View {
        NavigationStack {
            Form {
                TextEditor(text: $newText)
                    .frame(minHeight: 160)
            }
            .navigationTitle(TL("new_clipboard.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(TL("cancel")) { showAdd = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(TL("save")) { addNew(); showAdd = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var toastOverlay: some View {
        Group {
            if let toast {
                Text(toast)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .transition(.opacity)
                    .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { self.toast = nil } }
            }
        }
    }

    // MARK: - Actions

    private func copy(_ text: String?) {
        guard let text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        toast = TL("pasted.tip")
    }

    private func copyFromSystem() {
        if let text = UIPasteboard.general.string, !text.isEmpty {
            addClipboard(text)
            toast = TL("pasted.tip")
        }
    }

    private func addClipboard(_ text: String) {
        let item = Clipboard(context: viewContext)
        item.content = text
        item.createdAt = Date()
        try? viewContext.save()
    }

    private func addNew() {
        guard !newText.isEmpty else { return }
        addClipboard(newText)
        newText = ""
    }

    private func saveAsPhrase(_ text: String?) {
        guard let text, !text.isEmpty else { return }
        // Insert into the default (first) phrase set, or a generic one.
        let ctx = viewContext
        let request = NSFetchRequest<PhraseSet>(entityName: "PhraseSet")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PhraseSet.order, ascending: true)]
        let set = (try? ctx.fetch(request))?.first ?? {
            let s = PhraseSet(context: ctx); s.name = TL("phrase_set.list_title"); s.createdAt = Date(); return s
        }()
        let phrase = Phrase(context: ctx)
        phrase.content = text
        phrase.createdAt = Date()
        phrase.set = set
        try? ctx.save()
        toast = TL("save.success")
    }

    private func delete(_ item: Clipboard) {
        viewContext.delete(item)
        try? viewContext.save()
    }

    private func deleteItems(_ offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(items[index])
        }
        try? viewContext.save()
    }

    private func clearAll() {
        for item in items { viewContext.delete(item) }
        try? viewContext.save()
    }
}
