//
//  Book+Placeholder.swift
//  bookshelf
//
//  Sample data for previews and for the skeleton while loading (`ShelfViewModel.displayBooks`).
//  Not inserted into any database.
//

extension Book {
    /// The fixtures shown as a skeleton. Created once, so the ids stay the same between renders.
    @MainActor static let skeleton = placeholders()

    static func placeholder() -> Book {
        let book = Book(title: "The Hobbit", author: "J.R.R. Tolkien", pages: 320, currentPage: 26, status: .reading)
        book.notes = [Note.placeholder()]
        return book
    }

    static func placeholders() -> [Book] {
        [
            placeholder(),
            Book(title: "Onyx Storm", author: "Rebecca Yarros", pages: 544, currentPage: 185, status: .reading),
            Book(title: "Solaris", author: "Stanisław Lem", pages: 204),
            Book(title: "Dune", author: "Frank Herbert", pages: 412, currentPage: 412, status: .finished),
        ]
    }
}
