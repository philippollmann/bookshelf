//
//  Configuration.swift
//  bookshelf
//

import Foundation

/// Central place for URLs and the keys of everything stored in `UserDefaults` / `@AppStorage`.
/// Read configuration through this enum, never directly from `Bundle` or with string literals.
enum Configuration {
    // MARK: UserDefaults keys

    static let finishedBooksCountKey = "finishedBooksCount"
    static let lastReviewRequestVersionKey = "lastReviewRequestVersion"
    static let reminderEnabledKey = "reminderEnabled"

    // MARK: Launch arguments

    /// UI tests start the app with `-uiTesting`: an empty in-memory database, so every test starts clean.
    static let isUITesting = ProcessInfo.processInfo.arguments.contains("-uiTesting")

    // MARK: URLs

    /// Open Library: free, no API key needed.
    static let booksApiURL = URL(string: "https://openlibrary.org")!
    static let coversURL = URL(string: "https://covers.openlibrary.org")!

    /// How many results one search returns.
    static let searchLimit = 20

    // MARK: App info

    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
