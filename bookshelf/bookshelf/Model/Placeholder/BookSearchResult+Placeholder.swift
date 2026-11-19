//
//  BookSearchResult+Placeholder.swift
//  bookshelf
//

extension BookSearchResult {
    /// The fixtures shown as a skeleton while searching.
    static let skeleton = placeholders()

    static func placeholder(
        key: String = "/works/OL1W",
        title: String = "Dune",
        year: Int = 1965,
        pages: Int = 412
    ) -> BookSearchResult {
        BookSearchResult(
            key: key,
            title: title,
            authorName: ["Frank Herbert"],
            firstPublishYear: year,
            numberOfPagesMedian: pages,
            coverId: nil
        )
    }

    static func placeholders() -> [BookSearchResult] {
        [
            placeholder(),
            placeholder(key: "/works/OL2W", title: "Dune Messiah", year: 1969, pages: 256),
            placeholder(key: "/works/OL3W", title: "Children of Dune", year: 1976, pages: 444),
        ]
    }
}
