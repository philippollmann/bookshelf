//
//  BookSearchResult+Extension.swift
//  bookshelf
//

import Foundation

extension BookSearchResult {
    var author: String {
        authorName?.joined(separator: ", ") ?? String(localized: "Unknown author")
    }

    var pages: Int {
        numberOfPagesMedian ?? 0
    }

    var year: String? {
        firstPublishYear.map { String($0) }
    }

    var coverURL: URL? {
        coverId.map { Configuration.coversURL.appendingPathComponent("b/id/\($0)-M.jpg") }
    }
}
