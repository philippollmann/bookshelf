import SwiftUI

struct ContentView: View {
    @State private var books = Book.samples

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(books) { book in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                Text(book.author)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(book.progress, format: .percent.precision(.fractionLength(0)))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Library")
            .toolbar {
                Button("Add book", systemImage: "plus") {
                    books.append(Book(title: "New book \(books.count + 1)", author: "Unknown", pages: 200))
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
