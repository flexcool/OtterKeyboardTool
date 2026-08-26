import SwiftUI
import CoreData

/// "Explosion" word-segmentation view shown on long-press of a clipboard/phrase
/// item. The text is split into tappable segments; selecting a range builds the
/// string to insert, and the item can also be deleted.
struct ExplosionView: View {
    let target: ExplosionTarget
    let onInsert: (String) -> Void
    let onDelete: () -> Void

    @State private var selected = Set<Int>()

    private let segments: [String]

    init(target: ExplosionTarget, onInsert: @escaping (String) -> Void, onDelete: @escaping () -> Void) {
        self.target = target
        self.onInsert = onInsert
        self.onDelete = onDelete
        self.segments = ExplosionView.segment(target.content)
    }

    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay(alignment: .center) {
                VStack(spacing: 14) {
                    Text(TL("big_boom")).font(.headline)
                    ScrollView {
                        FlowLayout(spacing: 8) {
                            ForEach(Array(segments.enumerated()), id: \.0) { index, seg in
                                Text(seg)
                                    .padding(.horizontal, 12).padding(.vertical, 8)
                                    .background(
                                        selected.contains(index)
                                        ? Color.accentColor.opacity(0.25)
                                        : Color(.tertiarySystemBackground),
                                        in: RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(selected.contains(index) ? Color.accentColor : .clear))
                                    .onTapGesture {
                                        if selected.contains(index) { selected.remove(index) }
                                        else { selected.insert(index) }
                                    }
                            }
                        }
                        .padding(12)
                    }
                    .frame(maxHeight: 220)

                    HStack(spacing: 12) {
                        Button(TL("cancel")) { onDelete() }
                            .foregroundStyle(.secondary)
                        if target.canDelete {
                            Button(TL("delete")) { deleteItem(); onDelete() }
                                .foregroundStyle(.red)
                        }
                        Spacer()
                        Button(TL("boom.input")) { commit() }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal, 12)
                }
                .padding()
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
                .padding(24)
            }
            .onTapGesture { onDelete() }
    }

    private func commit() {
        let text: String
        if selected.isEmpty {
            text = target.content
        } else {
            text = selected.sorted().map { segments[$0] }.joined()
        }
        onInsert(text)
    }

    private func deleteItem() {
        switch target {
        case .clipboard(let c): PersistenceController.shared.deleteClipboard(c)
        case .phrase(let p):
            let ctx = p.managedObjectContext ?? PersistenceController.shared.viewContext
            ctx.delete(p)
            try? ctx.save()
        }
    }

    static func segment(_ text: String) -> [String] {
        var result: [String] = []
        var buf = ""
        for ch in text {
            if ch.isASCII && (ch.isLetter || ch.isNumber) {
                buf.append(ch)
            } else {
                if !buf.isEmpty { result.append(buf); buf = "" }
                result.append(String(ch))
            }
        }
        if !buf.isEmpty { result.append(buf) }
        return result.filter { !$0.isEmpty }
    }
}

extension ExplosionTarget {
    var canDelete: Bool {
        switch self {
        case .clipboard: return true
        case .phrase: return true
        }
    }
}

/// Simple left-to-right wrapping layout.
struct FlowLayout: Layout {
    let spacing: CGFloat
    init(spacing: CGFloat = 8) { self.spacing = spacing }
    func sizeThatFits(in proposal: ProposedViewSize, for subviews: Subviews, with cache: inout ()) -> CGSize {
        let rows = layout(proposal.width ?? .infinity, subviews)
        return CGSize(width: proposal.width ?? .infinity, height: rows.height)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, with cache: inout ()) {
        let rows = layout(bounds.width, subviews)
        var y = bounds.minY
        for row in rows.rows {
            var x = bounds.minX
            for index in row {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += rows.rowHeight + spacing
        }
    }
    private func layout(_ maxWidth: CGFloat, _ subviews: Subviews) -> (rows: [[Int]], rowHeight: CGFloat, height: CGFloat) {
        var rows: [[Int]] = [[]]
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0
        for (i, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            rowHeight = max(rowHeight, size.height)
            if x + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append(i)
            x += size.width + spacing
        }
        let height = CGFloat(rows.count) * rowHeight + CGFloat(max(0, rows.count - 1)) * spacing
        return (rows, rowHeight, height)
    }
}
