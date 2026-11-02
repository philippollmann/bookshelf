import Foundation

enum ReadingStatus: CaseIterable {
    case wantToRead
    case reading
    case finished

    var title: String {
        switch self {
        case .wantToRead: "To read"
        case .reading: "Currently reading"
        case .finished: "Finished"
        }
    }
}

struct Book: Identifiable {
    let id = UUID()
    var title: String
    var author: String
    var pages: Int
    var currentPage = 0
    var status = ReadingStatus.wantToRead

    var progress: Double {
        guard pages > 0 else { return 0 }
        return Double(currentPage) / Double(pages)
    }

    mutating func read(pages count: Int) {
        currentPage = min(max(currentPage + count, 0), pages)

        if currentPage == pages {
            status = .finished
        } else if currentPage > 0 {
            status = .reading
        }
    }
}

extension Book {
    static let samples: [Book] = [
        Book(title: "The Hobbit", author: "J.R.R. Tolkien", pages: 320, currentPage: 26, status: .reading),
        Book(title: "Onyx Storm", author: "Rebecca Yarros", pages: 544, currentPage: 185, status: .reading),
        Book(title: "Solaris", author: "Stanisław Lem", pages: 204),
        Book(title: "A Little Life", author: "Hanya Yanagihara", pages: 720),
        Book(title: "Dune", author: "Frank Herbert", pages: 412, currentPage: 412, status: .finished),
        Book(title: "Project Hail Mary", author: "Andy Weir", pages: 476, currentPage: 476, status: .finished),
    ]
}
