import Foundation
import CoreData

/// Clipboard history item (shared between app and keyboard via App Group store).
@objc(Clipboard)
public class Clipboard: NSManagedObject {
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var order: Int32
}

@objc(Phrase)
public class Phrase: NSManagedObject {
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var set: PhraseSet?
}

@objc(PhraseSet)
public class PhraseSet: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var order: Int32
    @NSManaged public var phrases: NSSet?
}

@objc(Script)
public class Script: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var code: String?
    @NSManaged public var isParams: Bool
    @NSManaged public var isNetRequest: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var order: Int32
}
