//
//  AccessibilityNotification+Extension.swift
//  bookshelf
//

import SwiftUI

extension AccessibilityNotification.Announcement {
    /// VoiceOver doesn't see visual changes. After an action without an obvious result, say what happened.
    /// Call it only when the action worked.
    static func post(_ message: String.LocalizationValue) {
        AccessibilityNotification.Announcement(String(localized: message)).post()
    }
}
