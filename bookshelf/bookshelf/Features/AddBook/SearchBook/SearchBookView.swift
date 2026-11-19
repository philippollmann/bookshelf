//
//  SearchBookView.swift
//  bookshelf
//

import SwiftUI

/// Searches Open Library. Tapping a result calls `onSelect`, the add-book form takes it from there.
struct SearchBookView<Model: SearchBookViewModel>: View {
    @State var viewModel: Model
    let onSelect: (BookSearchResult) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing16) {
                searchField

                if viewModel.isSearching {
                    // Skeleton with the fixtures, same shape as the real results
                    results(viewModel.displayResults)
                        .redacted(when: true, label: "Searching")
                } else if viewModel.hasSearched, viewModel.results.isEmpty {
                    ContentUnavailableView.search(text: viewModel.query)
                } else if viewModel.hasSearched {
                    results(viewModel.results)
                } else {
                    ContentUnavailableView(
                        "Search for a book",
                        systemImage: "magnifyingglass",
                        description: Text("Type a title or an author and tap search.")
                    )
                }
            }
            .padding(.horizontal, .spacing20)
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .errorHandler($viewModel.error)
        // The results appear without a screen change, so tell VoiceOver users that something happened
        .onChange(of: viewModel.results.count) { _, count in
            AccessibilityNotification.Announcement.post("\(count) books found")
        }
    }

    private var searchField: some View {
        HStack(spacing: .spacing8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.secondaryText)
                // Decorative: the text field next to it says what it is
                .accessibilityHidden(true)

            TextField("Title or author", text: $viewModel.query)
                .submitLabel(.search)
                .onSubmit { viewModel.search() }

            if !viewModel.query.isEmpty {
                Button("Clear", systemImage: "xmark.circle.fill") { viewModel.query = "" }
                    .labelStyle(.iconOnly)
                    .foregroundStyle(Color.secondaryText)
                    .frame(minWidth: .minTapTarget, minHeight: .minTapTarget)
            }
        }
        .padding(.horizontal, .spacing16)
        // A minimum, not a fixed height: with large text the field has to grow
        .frame(minHeight: .spacing48)
        .background(Color.cardBackground, in: .capsule)
        .cardShadow()
    }

    private func results(_ results: [BookSearchResult]) -> some View {
        VStack(alignment: .leading, spacing: .spacing8) {
            HStack {
                Text("Results")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text("Open Library")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
            }

            ForEach(results) { result in
                Button {
                    onSelect(result)
                } label: {
                    HStack(spacing: .spacing12) {
                        BookCoverMini(title: result.title, coverURL: result.coverURL)

                        VStack(alignment: .leading, spacing: .spacing4) {
                            Text(result.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            Text([result.author, result.year].compactMap { $0 }.joined(separator: " · "))
                                .font(.subheadline)
                                .foregroundStyle(Color.secondaryText)
                                .lineLimit(1)
                        }
                        .multilineTextAlignment(.leading)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                            .accessibilityHidden(true)
                    }
                    .padding(.vertical, .spacing8)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Fills in the form with this book")
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchBookView(viewModel: SearchBookViewModelPreview(), onSelect: { _ in })
    }
}

#Preview("Searching") {
    NavigationStack {
        SearchBookView(viewModel: SearchBookViewModelPreview(isSearching: true), onSelect: { _ in })
    }
}

#Preview("Accessibility text size") {
    NavigationStack {
        SearchBookView(viewModel: SearchBookViewModelPreview(), onSelect: { _ in })
    }
    .dynamicTypeSize(.accessibility3)
}
