//
//  BookDetailViewModel.swift
//  bookshelf
//

import Foundation
import Observation

enum BookDetailSheet: Identifiable {
    case updateProgress
    case addNote

    var id: Self { self }
}

protocol BookDetailViewModel: AnyObject, Observable, ErrorReporting {
    var book: Book { get }
    var sheet: BookDetailSheet? { get set }
    var isConfirmingRemoval: Bool { get set }
    var noteToDelete: Note? { get set }
    var error: Error? { get set }

    /// The actions return `true` if they worked, so the view only announces success.
    @discardableResult func setCurrentPage(_ page: Int) -> Bool
    @discardableResult func delete() -> Bool
    @discardableResult func addNote(_ text: String) -> Bool
    func deleteNote(_ note: Note)
}

extension BookDetailViewModel {
    @discardableResult
    func finish() -> Bool {
        setCurrentPage(book.pages)
    }
}

@Observable
final class BookDetailViewModelImpl: BookDetailViewModel {
    let book: Book
    var sheet: BookDetailSheet?
    var isConfirmingRemoval = false
    var noteToDelete: Note?
    var error: Error?

    private let repository = BookRepository.shared
    private let ratingManager = RatingManager.shared

    init(book: Book) {
        self.book = book
    }

    func setCurrentPage(_ page: Int) -> Bool {
        let wasFinished = book.status == .finished
        book.read(pages: page - book.currentPage)

        guard attempt({ try repository.save() }) else { return false }

        // The view model connects the pieces: a finished book is a good moment for a rating.
        if !wasFinished, book.status == .finished {
            ratingManager.bookFinished()
        }
        return true
    }

    func delete() -> Bool {
        attempt { try repository.delete(book) }
    }

    func addNote(_ text: String) -> Bool {
        attempt { try repository.addNote(text, to: book) }
    }

    func deleteNote(_ note: Note) {
        attempt { try repository.delete(note) }
    }
}

@Observable
final class BookDetailViewModelPreview: BookDetailViewModel {
    let book = Book.placeholder()
    var sheet: BookDetailSheet?
    var isConfirmingRemoval = false
    var noteToDelete: Note?
    var error: Error?

    func setCurrentPage(_ page: Int) -> Bool {
        book.read(pages: page - book.currentPage)
        return true
    }

    func delete() -> Bool {
        true
    }

    func addNote(_ text: String) -> Bool {
        book.notes.append(Note(text: text))
        return true
    }

    func deleteNote(_ note: Note) {
        book.notes.removeAll { $0 === note }
    }
}
