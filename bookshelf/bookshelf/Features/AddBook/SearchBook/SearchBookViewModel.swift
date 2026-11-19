//
//  SearchBookViewModel.swift
//  bookshelf
//

import Foundation
import Observation

protocol SearchBookViewModel: AnyObject, Observable {
    var query: String { get set }
    var results: [BookSearchResult] { get }
    var isSearching: Bool { get }
    var hasSearched: Bool { get }
    var error: Error? { get set }

    /// Starts a search. A search that is still running is cancelled, so old results never replace newer ones.
    func search()
}

extension SearchBookViewModel {
    /// While searching, the fixtures fill the list as a skeleton (the view redacts them).
    var displayResults: [BookSearchResult] {
        isSearching ? BookSearchResult.skeleton : results
    }
}

@Observable
final class SearchBookViewModelImpl: SearchBookViewModel {
    var query = ""
    private(set) var results: [BookSearchResult] = []
    private(set) var isSearching = false
    private(set) var hasSearched = false
    var error: Error?

    private let repository = BookSearchRepository.shared
    private var searchTask: Task<Void, Never>?

    func search() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else { return }

        searchTask?.cancel()
        isSearching = true
        // weak: leaving the screen must not keep the ViewModel alive until the request is done
        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let found = try await repository.search(query: trimmedQuery)
                guard !Task.isCancelled else { return }
                results = found
                hasSearched = true
            } catch {
                // A cancelled search is replaced by a newer one, that is not an error
                guard !Task.isCancelled else { return }
                self.error = error
            }
            isSearching = false
        }
    }
}

@Observable
final class SearchBookViewModelPreview: SearchBookViewModel {
    var query = "Dune"
    var results = BookSearchResult.placeholders()
    var isSearching: Bool
    var hasSearched = true
    var error: Error?

    init(isSearching: Bool = false) {
        self.isSearching = isSearching
    }

    func search() {}
}
