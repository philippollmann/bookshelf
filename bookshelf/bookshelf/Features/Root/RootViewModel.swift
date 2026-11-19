//
//  RootViewModel.swift
//  bookshelf
//

import Foundation
import Observation

protocol RootViewModel: AnyObject, Observable {
    var shouldRequestReview: Bool { get }

    func didRequestReview()
}

@Observable
final class RootViewModelImpl: RootViewModel {
    var shouldRequestReview: Bool {
        ratingManager.shouldRequestReview
    }

    private let ratingManager = RatingManager.shared

    func didRequestReview() {
        ratingManager.didRequestReview()
    }
}

@Observable
final class RootViewModelPreview: RootViewModel {
    var shouldRequestReview = false

    func didRequestReview() {}
}
