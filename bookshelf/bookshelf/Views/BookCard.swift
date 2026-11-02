import SwiftUI

struct BookCard: View {
    let book: Book

    private let colors: [Color] = [.blue, .green, .indigo, .brown, .teal, .red, .orange, .purple]

    private var color: Color {
        let number = book.title.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return colors[number % colors.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.gradient)
                .aspectRatio(2 / 3, contentMode: .fit)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(book.title.uppercased())
                            .font(.headline)
                            .lineLimit(3)
                        Text(book.author.uppercased())
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .padding(10)
                }

            if book.status == .reading {
                Text(book.progress, format: .percent.precision(.fractionLength(0)))
                    .font(.caption.bold())
            }
        }
    }
}

#Preview {
    BookCard(book: Book.samples[0])
        .frame(width: 170)
        .padding()
}

#Preview("Long title, large text") {
    BookCard(book: Book(title: "The Hitchhiker's Guide to the Galaxy", author: "Douglas Adams", pages: 224, currentPage: 40, status: .reading))
        .frame(width: 170)
        .padding()
        .dynamicTypeSize(.accessibility2)
}
