//
//  BookSearchRepository.swift
//  bookshelf
//

import Foundation

/// Finds books online. Calls the `BookApi` and returns the decoded models.
/// Nothing outside of the data layer knows about URLs or JSON.
@MainActor
final class BookSearchRepository {
    static let shared = BookSearchRepository()

    private let provider = NetworkingProvider<BookApi>()

    private init() {}

    func search(query: String) async throws -> [BookSearchResult] {
        let response: BookSearchResponse = try await provider.request(.search(query: query))
        return response.docs
    }
}
