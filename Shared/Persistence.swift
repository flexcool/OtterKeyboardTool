import Foundation
import CoreData

/// Shared configuration. NOTE: before running on a real device you must change
/// `appGroupID` to a group you own (e.g. `group.com.yourteam.OtterKeyboardTool`)
/// and update the App Group entitlement in BOTH targets accordingly.
public enum AppConfig {
    public static let appGroupID = "group.czk"
    public static let modelName = "OtterKeyboardTool"
    public static let urlScheme = "openotterkeyboard"
}

/// UserDefaults shared between the container app and the keyboard extension
/// through the App Group. All user-facing settings live here.
public enum SharedDefaults {
    public static let store: UserDefaults? = UserDefaults(suiteName: AppConfig.appGroupID)
}

/// Setting keys stored in the shared App Group UserDefaults.
public enum SettingsKeys {
    public static let autoSaveClipboard = "autoSaveClipboard"
    public static let isSound = "isSound"
    public static let isVibration = "isVibration"
    public static let useEmoji = "useEmoji"
    public static let keyboardHeightPortrait = "keyboardHeightPortrait"
    public static let keyboardHeightLandscape = "keyboardHeightLandscape"
    /// Comma separated tab order, e.g. "clipboard,phrase,script,setting".
    public static let menuOrder = "menuOrder"
    public static let hasLaunched = "hasLaunched"
}

/// CoreData stack backed by a store inside the App Group container so both the
/// app and the keyboard extension read/write the same data.
public final class PersistenceController: @unchecked Sendable {
    public static let shared = PersistenceController()

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: AppConfig.modelName)
        let description = container.persistentStoreDescriptions.first!

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else if let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppConfig.appGroupID) {
            let storeURL = groupURL.appendingPathComponent("\(AppConfig.modelName).sqlite")
            description.url = storeURL
            // Use DELETE journal mode for safer cross-process access.
            description.setOption(["journal_mode": "DELETE"] as NSDictionary,
                                  forKey: NSSQLitePragmasOption)
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                #if DEBUG
                print("CoreData load error: \(error)")
                #endif
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    public var viewContext: NSManagedObjectContext { container.viewContext }

    // MARK: - Convenience helpers

    public func newClipboardContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }
}

// MARK: - Clipboard repository

extension PersistenceController {
    /// Insert a clipboard entry, de-duplicating against the latest content.
    public func addClipboard(_ text: String) {
        let trimmed = text
        guard !trimmed.isEmpty else { return }
        let ctx = newClipboardContext()
        ctx.perform {
            let fetch = NSFetchRequest<Clipboard>(entityName: "Clipboard")
            fetch.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            fetch.fetchLimit = 1
            if let last = try? ctx.fetch(fetch), last.first?.content == trimmed {
                return
            }
            let item = Clipboard(context: ctx)
            item.content = trimmed
            item.createdAt = Date()
            try? ctx.save()
        }
    }

    public func recentClipboards(limit: Int = 200) -> [Clipboard] {
        let fetch = NSFetchRequest<Clipboard>(entityName: "Clipboard")
        fetch.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        fetch.fetchLimit = limit
        return (try? viewContext.fetch(fetch)) ?? []
    }

    public func deleteClipboard(_ object: Clipboard) {
        viewContext.delete(object)
        try? viewContext.save()
    }

    public func clearClipboards() {
        let items = recentClipboards(limit: 10000)
        for item in items { viewContext.delete(item) }
        try? viewContext.save()
    }
}
