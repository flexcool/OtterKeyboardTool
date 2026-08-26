import Foundation

/// Localized string lookup using the app/extension's Localizable.strings tables.
public func TL(_ key: String, _ comment: String = "") -> String {
    NSLocalizedString(key, comment: comment)
}
