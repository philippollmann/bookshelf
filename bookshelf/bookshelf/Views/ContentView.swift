import SwiftUI

struct ContentView: View {
    @State private var books = Book.samples
    @State private var title = ""
    @State private var author = ""
    @State private var pagesText = ""

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    private var pages: Int? {
        Int(pagesText)
    }

    private var canAdd: Bool {
        !title.isEmpty && !author.isEmpty && (pages ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    addForm

                    ForEach(ReadingStatus.allCases, id: \.self) { status in
                        let booksWithStatus = books.filter { $0.status == status }

                        if !booksWithStatus.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(status.title)
                                    .font(.title3.bold())

                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(booksWithStatus) { book in
                                        Button {
                                            read(book)
                                        } label: {
                                            BookCard(book: book)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Library")
        }
    }

    private var addForm: some View {
        VStack(spacing: 8) {
            TextField("Title", text: $title)
            TextField("Author", text: $author)
            TextField("Pages", text: $pagesText)
                .keyboardType(.numberPad)

            Button("Add book", action: addBook)
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(!canAdd)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .textFieldStyle(.roundedBorder)
    }

    private func addBook() {
        guard let pages else { return }

        books.append(Book(title: title, author: author, pages: pages))
        title = ""
        author = ""
        pagesText = ""
    }

    private func read(_ book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index].read(pages: 10)
    }
}

#Preview {
    ContentView()
}
