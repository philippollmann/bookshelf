//
//  BookGridCard.swift
//  bookshelf
//

import SwiftUI

/// A cover for the library grid. Books that are being read show their progress below.
struct BookGridCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing8) {
            BookCover(book: book)

            if book.status == .reading {
                Text(book.progress, format: .percent.precision(.fractionLength(0)))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        // One element per book: "The Hobbit, J.R.R. Tolkien, 8 percent read". The role "button"
        // comes from the NavigationLink around it. The status is part of the value, because the
        // colored chip and the bookmark are not available to VoiceOver.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(book.title), \(book.author)")
        .accessibilityValue(book.status == .reading ? Text("\(book.progressPercent) percent read") : Text(book.status.chipTitle))
    }
}

#Preview {
    HStack(alignment: .top, spacing: .spacing16) {
        BookGridCard(book: Book.placeholder())
        BookGridCard(book: Book.placeholders()[2])
    }
    .padding(.spacing16)
}
