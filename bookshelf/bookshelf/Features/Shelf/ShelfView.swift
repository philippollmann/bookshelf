//
//  ShelfView.swift
//  bookshelf
//

import SwiftUI

struct ShelfView<Model: ShelfViewModel>: View {
    @State var viewModel: Model
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// One column with the largest text sizes, so the percentages next to the covers stay readable.
    private var columns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: .spacing16), count: count)
    }

    var body: some View {
        let booksByStatus = viewModel.booksByStatus

        NavigationStack {
            Group {
                if let error = viewModel.error {
                    ContentUnavailableView {
                        Label("Couldn't load your books", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error.toCustomError().failureReason ?? "")
                    } actions: {
                        Button("Try again") { viewModel.load() }
                            .buttonStyle(.glassProminent)
                            .controlSize(.large)
                    }
                } else if !viewModel.isLoading, viewModel.books.isEmpty {
                    ContentUnavailableView {
                        Label("Your shelf is empty", systemImage: "books.vertical")
                    } description: {
                        Text("Add your first book to start your shelf.")
                    } actions: {
                        Button("Add book") { viewModel.sheet = .add }
                            .buttonStyle(.glassProminent)
                            .controlSize(.large)
                    }
                } else {
                    shelf(booksByStatus)
                        .redacted(when: viewModel.isLoading)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Library")
            .navigationSubtitle(subtitle(for: booksByStatus))
            .navigationDestination(for: Book.self) { book in
                BookDetailView(viewModel: BookDetailViewModelImpl(book: book))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gearshape") { viewModel.sheet = .settings }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add book", systemImage: "plus") { viewModel.sheet = .add }
                }
            }
            .sheet(item: $viewModel.sheet) { sheet in
                switch sheet {
                case .add:
                    AddBookView(viewModel: AddBookViewModelImpl())
                case .settings:
                    SettingsView(viewModel: SettingsViewModelImpl())
                }
            }
        }
        .task { viewModel.load() }
    }

    private func subtitle(for booksByStatus: [ReadingStatus: [Book]]) -> LocalizedStringKey {
        let reading = booksByStatus[.reading]?.count ?? 0
        let finished = booksByStatus[.finished]?.count ?? 0
        return "\(reading) reading · \(finished) finished"
    }

    private func shelf(_ booksByStatus: [ReadingStatus: [Book]]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing24) {
                ForEach(ReadingStatus.allCases, id: \.self) { status in
                    let books = booksByStatus[status] ?? []

                    if !books.isEmpty {
                        VStack(alignment: .leading, spacing: .spacing12) {
                            HStack(spacing: .spacing8) {
                                Text(status.title)
                                    .font(.title2.bold())
                                Text(books.count, format: .number)
                                    .font(.headline)
                                    .foregroundStyle(Color.secondaryText)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityAddTraits(.isHeader)

                            LazyVGrid(columns: columns, spacing: .spacing24) {
                                ForEach(books) { book in
                                    NavigationLink(value: book) {
                                        BookGridCard(book: book)
                                            .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .maxCoverWidth : .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, .spacing20)
            .padding(.bottom, .spacing24)
        }
    }
}

#Preview("Books") {
    ShelfView(viewModel: ShelfViewModelPreview())
}

#Preview("Accessibility text size") {
    ShelfView(viewModel: ShelfViewModelPreview())
        .dynamicTypeSize(.accessibility3)
}

#Preview("Dark mode, German") {
    ShelfView(viewModel: ShelfViewModelPreview())
        .preferredColorScheme(.dark)
        .environment(\.locale, Locale(identifier: "de"))
}

#Preview("Loading") {
    ShelfView(viewModel: ShelfViewModelPreview(isLoading: true))
}

#Preview("Loading, dark mode") {
    ShelfView(viewModel: ShelfViewModelPreview(isLoading: true))
        .preferredColorScheme(.dark)
}

#Preview("Load failed") {
    ShelfView(viewModel: ShelfViewModelPreview(error: CustomError.generic))
}

#Preview("Empty") {
    let viewModel = ShelfViewModelPreview()
    viewModel.books = []
    return ShelfView(viewModel: viewModel)
}
