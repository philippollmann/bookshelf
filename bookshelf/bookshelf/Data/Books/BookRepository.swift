//
//  BookRepository.swift
//  bookshelf
//

import Foundation
import Observation
import SwiftData

/// Owns the books and notes stored on this device (SwiftData). The only place that touches the `ModelContext`.
///
/// ViewModels read `books` and call the functions below. The array is reloaded after every
/// change, so everything that observes it updates automatically.
@MainActor
@Observable
final class BookRepository {
    static let shared = BookRepository(inMemory: Configuration.isUITesting)

    private(set) var books: [Book] = []

    /// The container must be kept alive: a `ModelContext` does not retain it.
    private let container: ModelContainer
    private var context: ModelContext {
        container.mainContext
    }

    /// `inMemory` is for previews and tests, so they never touch the real database.
    init(inMemory: Bool = false) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        // If the database cannot be opened there is nothing the app can show, so crashing is the honest option
        // swiftlint:disable:next force_try
        container = try! ModelContainer(for: Book.self, Note.self, configurations: configuration)
    }

    func fetchBooks() throws {
        let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.addedAt, order: .reverse)])
        books = try context.fetch(descriptor)
    }

    func add(title: String, author: String, pages: Int, status: ReadingStatus, coverURL: URL? = nil, coverImageData: Data? = nil, externalId: String? = nil) throws {
        let currentPage = status == .finished ? pages : 0
        let book = Book(title: title, author: author, pages: pages, currentPage: currentPage, status: status, coverURL: coverURL, coverImageData: coverImageData, externalId: externalId)
        context.insert(book)
        try save()
    }

    func delete(_ book: Book) throws {
        context.delete(book)
        try save()
    }

    func addNote(_ text: String, to book: Book) throws {
        book.notes.append(Note(text: text))
        try save()
    }

    func delete(_ note: Note) throws {
        context.delete(note)
        try save()
    }

    /// Call after changing a property of a book (e.g. `book.read(pages:)`).
    func save() throws {
        try context.save()
        try fetchBooks()
    }
}
