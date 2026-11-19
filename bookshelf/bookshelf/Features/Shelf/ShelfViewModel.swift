//
//  ShelfViewModel.swift
//  bookshelf
//

import Foundation
import Observation

enum ShelfSheet: Identifiable {
    case add
    case settings

    var id: Self { self }
}

/// The interface the view depends on. The view never sees repositories, only this protocol.
protocol ShelfViewModel: AnyObject, Observable {
    var books: [Book] { get }
    var isLoading: Bool { get }
    var sheet: ShelfSheet? { get set }
    /// Set if the books could not be read from the database. The Library has no other action that can fail,
    /// so the view shows this as its own state with a retry instead of an alert.
    var error: Error? { get }

    func load()
}

extension ShelfViewModel {
    /// While loading, the fixtures fill the screen as a skeleton (the view redacts them).
    var displayBooks: [Book] {
        isLoading ? Book.skeleton : books
    }

    /// One pass over the books. The view calls it once per render and reads all sections from the result.
    var booksByStatus: [ReadingStatus: [Book]] {
        Dictionary(grouping: displayBooks, by: \.status)
    }
}

/// The real implementation: talks to the repository.
@Observable
final class ShelfViewModelImpl: ShelfViewModel {
    var books: [Book] {
        repository.books
    }

    private(set) var isLoading = true
    var sheet: ShelfSheet?
    private(set) var error: Error?

    private let repository = BookRepository.shared

    func load() {
        defer { isLoading = false }
        do {
            try repository.fetchBooks()
            error = nil
        } catch {
            self.error = error
        }
    }
}

/// Fixed data for previews: no database, no network.
@Observable
final class ShelfViewModelPreview: ShelfViewModel {
    var books = Book.placeholders()
    var isLoading: Bool
    var sheet: ShelfSheet?
    var error: Error?

    init(isLoading: Bool = false, error: Error? = nil) {
        self.isLoading = isLoading
        self.error = error
    }

    func load() {}
}
