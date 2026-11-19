//
//  BookSearchResult.swift
//  bookshelf
//
//  Mirrors the JSON of the Open Library search 1:1. Computed helpers live in
//  `Extension/BookSearchResult+Extension.swift`. Becomes a `Book` once the user adds it.
//

import Foundation

struct BookSearchResponse: Decodable {
    let docs: [BookSearchResult]
}

struct BookSearchResult: Decodable, Identifiable {
    let key: String
    let title: String
    let authorName: [String]?
    let firstPublishYear: Int?
    let numberOfPagesMedian: Int?
    let coverId: Int?

    var id: String { key }

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case numberOfPagesMedian = "number_of_pages_median"
        case coverId = "cover_i"
    }
}
