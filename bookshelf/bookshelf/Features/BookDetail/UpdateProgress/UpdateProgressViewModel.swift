//
//  UpdateProgressViewModel.swift
//  bookshelf
//

import Foundation
import Observation

protocol UpdateProgressViewModel: AnyObject, Observable {
    var page: Int { get set }
    var pages: Int { get }

    func save()
}

extension UpdateProgressViewModel {
    func change(by delta: Int) {
        page = min(max(page + delta, 0), pages)
    }
}

/// Hands the chosen page to `onSave`; the book detail screen owns the data and stores it.
@Observable
final class UpdateProgressViewModelImpl: UpdateProgressViewModel {
    var page: Int
    let pages: Int

    private let onSave: (Int) -> Void

    init(currentPage: Int, pages: Int, onSave: @escaping (Int) -> Void) {
        page = currentPage
        self.pages = pages
        self.onSave = onSave
    }

    func save() {
        onSave(page)
    }
}

@Observable
final class UpdateProgressViewModelPreview: UpdateProgressViewModel {
    var page = 26
    let pages = 320

    func save() {}
}
