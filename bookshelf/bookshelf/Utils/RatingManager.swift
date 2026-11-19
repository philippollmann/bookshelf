//
//  RatingManager.swift
//  bookshelf
//

import Foundation
import Observation
import SwiftUI

/// Decides when to ask for an App Store rating: after the third finished book, once per app version.
/// The manager only *decides*, `RootView` observes `shouldRequestReview` and shows the system dialog.
@MainActor
@Observable
final class RatingManager {
    static let shared = RatingManager()

    private(set) var shouldRequestReview = false

    @ObservationIgnored @AppStorage(Configuration.finishedBooksCountKey) private var finishedBooks = 0
    @ObservationIgnored @AppStorage(Configuration.lastReviewRequestVersionKey) private var lastReviewRequestVersion = ""

    private let finishedBooksThreshold = 3

    private init() {}

    /// Call whenever the user finishes a book.
    func bookFinished() {
        finishedBooks += 1

        if finishedBooks >= finishedBooksThreshold, lastReviewRequestVersion != Configuration.appVersion {
            shouldRequestReview = true
        }
    }

    /// Call after the review dialog was requested.
    func didRequestReview() {
        shouldRequestReview = false
        lastReviewRequestVersion = Configuration.appVersion
    }
}
