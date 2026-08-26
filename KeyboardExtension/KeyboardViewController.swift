import UIKit
import SwiftUI

/// Bridges the custom keyboard UI to the system text input proxy.
final class KeyboardEngine: ObservableObject {
    weak var proxy: UITextDocumentProxy?
    weak var viewController: UIInputViewController?

    var hasFullAccess: Bool { viewController?.hasFullAccess ?? false }

    func insert(_ text: String) {
        guard !text.isEmpty else { return }
        proxy?.insertText(text)
    }

    func deleteBackward() { proxy?.deleteBackward() }

    func space() { proxy?.insertText(" ") }
    func `return`() { proxy?.insertText("\n") }
    func advance() { viewController?.advanceToNextInputMode() }

    var selectedText: String? { proxy?.selectedText }

    /// Copy the given text to the system clipboard (requires full access).
    func copyToSystem(_ text: String) {
        UIPasteboard.general.string = text
    }
}

final class KeyboardViewController: UIInputViewController {
    private var hosting: UIHostingController<KeyboardRootView>!
    private let engine = KeyboardEngine()
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        engine.proxy = textDocumentProxy
        engine.viewController = self

        let root = KeyboardRootView().environmentObject(engine)
        hosting = UIHostingController(rootView: root)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)
        hosting.view.backgroundColor = .clear

        heightConstraint = view.heightAnchor.constraint(equalToConstant: defaultHeight)
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            heightConstraint!
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        maybeAutoSaveClipboard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeight()
    }

    private var defaultHeight: CGFloat {
        let store = SharedDefaults.store
        return CGFloat(store?.double(forKey: SettingsKeys.keyboardHeightPortrait) ?? 260)
    }

    private func updateHeight() {
        let isLandscape = view.bounds.width > view.bounds.height
        let key = isLandscape ? SettingsKeys.keyboardHeightLandscape : SettingsKeys.keyboardHeightPortrait
        let h = CGFloat(SharedDefaults.store?.double(forKey: key) ?? (isLandscape ? 220 : 260))
        heightConstraint?.constant = h
    }

    private func maybeAutoSaveClipboard() {
        guard let store = SharedDefaults.store,
              store.bool(forKey: SettingsKeys.autoSaveClipboard),
              hasFullAccess,
              let text = UIPasteboard.general.string, !text.isEmpty else { return }
        PersistenceController.shared.addClipboard(text)
    }
}
