//
//  Book.swift
//  bookshelf
//

import Foundation
import SwiftData

enum ReadingStatus: String, Codable, CaseIterable {
    case reading
    case wantToRead
    case finished

    var title: LocalizedStringResource {
        switch self {
        case .reading: "Currently reading"
        case .wantToRead: "To read"
        case .finished: "Finished"
        }
    }
}

/// A book on the shelf. Stored with SwiftData, only the `BookRepository` writes it.
@Model
final class Book {
    var title: String
    var author: String
    var pages: Int
    var currentPage: Int
    var status: ReadingStatus
    var coverURL: URL?
    /// A photo the user picked or took. Wins over `coverURL`. Kept outside the database file because it is big.
    @Attribute(.externalStorage) var coverImageData: Data?
    /// Id of the Open Library work, `nil` for books added manually.
    var externalId: String?
    var addedAt: Date
    /// Deleting a book deletes its notes as well.
    @Relationship(deleteRule: .cascade) var notes: [Note] = []

    init(
        title: String,
        author: String,
        pages: Int,
        currentPage: Int = 0,
        status: ReadingStatus = .wantToRead,
        coverURL: URL? = nil,
        coverImageData: Data? = nil,
        externalId: String? = nil,
        addedAt: Date = .now
    ) {
        self.title = title
        self.author = author
        self.pages = pages
        self.currentPage = currentPage
        self.status = status
        self.coverURL = coverURL
        self.coverImageData = coverImageData
        self.externalId = externalId
        self.addedAt = addedAt
    }

    /// Newest note first.
    var sortedNotes: [Note] {
        notes.sorted { $0.createdAt > $1.createdAt }
    }

    var progress: Double {
        guard pages > 0 else { return 0 }
        return Double(currentPage) / Double(pages)
    }

    func read(pages count: Int) {
        currentPage = min(max(currentPage + count, 0), pages)

        if currentPage == pages {
            status = .finished
        } else if currentPage > 0 {
            status = .reading
        } else {
            status = .wantToRead
        }
    }
}

