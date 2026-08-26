import SwiftUI
import CoreData

struct PhraseSetsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PhraseSet.order, ascending: true)],
        animation: .default)
    private var sets: FetchedResults<PhraseSet>

    @State private var showAdd = false
    @State private var newName = ""

    var body: some View {
        NavigationStack {
            Group {
                if sets.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "text.quote").font(.largeTitle).foregroundStyle(.secondary)
                        Text(TL("phrase_set.list_title")).font(.headline)
                        Text(TL("phrase_empty.tip1") + " " + TL("phrase_empty.tip2"))
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(sets) { set in
                            NavigationLink {
                                PhraseSetDetailView(set: set)
                            } label: {
                                Label(set.name ?? "", systemImage: "folder")
                            }
                            .swipeActions {
                                Button(role: .destructive) { delete(set) } label: { Image(systemName: "trash") }
                            }
                        }
                    }
                }
            }
            .navigationTitle(TL("phrase_set.list_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { addSheet }
        }
    }

    private var addSheet: some View {
        NavigationStack {
            Form {
                TextField(TL("new_phrase_set.name"), text: $newName)
            }
            .navigationTitle(TL("new_phrase_set.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(TL("cancel")) { showAdd = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(TL("save")) { addSet(); showAdd = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func addSet() {
        let set = PhraseSet(context: viewContext)
        set.name = newName.isEmpty ? TL("phrase_set.list_title") : newName
        set.createdAt = Date()
        try? viewContext.save()
        newName = ""
    }

    private func delete(_ set: PhraseSet) {
        viewContext.delete(set)
        try? viewContext.save()
    }
}

struct PhraseSetDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var set: PhraseSet

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Phrase.createdAt, ascending: true)],
        animation: .default)
    private var phrases: FetchedResults<Phrase>

    @State private var showAdd = false
    @State private var newText = ""

    init(set: PhraseSet) {
        self._set = ObservedObject(initialValue: set)
        let request = NSFetchRequest<Phrase>(entityName: "Phrase")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.createdAt, ascending: true)]
        request.predicate = NSPredicate(format: "set == %@", set)
        self._phrases = FetchRequest(fetchRequest: request, animation: .default)
    }

    var body: some View {
        Group {
            if phrases.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.quote").font(.largeTitle).foregroundStyle(.secondary)
                    Text(TL("phrase_empty.tip1")).font(.footnote).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(phrases) { phrase in
                        Text(phrase.content ?? "")
                            .contextMenu {
                                Button { UIPasteboard.general.string = phrase.content; } label: { Label(TL("pasted.tip"), systemImage: "doc.on.doc") }
                                Button(role: .destructive) { delete(phrase) } label: { Label(TL("delete"), systemImage: "trash") }
                            }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .navigationTitle(set.name ?? "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAdd) { addSheet }
    }

    private var addSheet: some View {
        NavigationStack {
            Form { TextEditor(text: $newText).frame(minHeight: 160) }
            .navigationTitle(TL("new_phrase.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(TL("cancel")) { showAdd = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(TL("save")) { addPhrase(); showAdd = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func addPhrase() {
        guard !newText.isEmpty else { return }
        let phrase = Phrase(context: viewContext)
        phrase.content = newText
        phrase.createdAt = Date()
        phrase.set = set
        try? viewContext.save()
        newText = ""
    }

    private func delete(_ phrase: Phrase) {
        viewContext.delete(phrase)
        try? viewContext.save()
    }

    private func deleteItems(_ offsets: IndexSet) {
        for index in offsets { viewContext.delete(phrases[index]) }
        try? viewContext.save()
    }
}
