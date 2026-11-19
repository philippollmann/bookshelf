//
//  BookDetailView.swift
//  bookshelf
//

import SwiftUI

struct BookDetailView<Model: BookDetailViewModel>: View {
    @State var viewModel: Model
    @Environment(\.dismiss) private var dismiss

    /// Scales with the text size, but is capped so the cover never fills the whole screen.
    @ScaledMetric(relativeTo: .largeTitle) private var coverWidth = CGFloat.detailCoverWidth

    var body: some View {
        let book = viewModel.book

        ScrollView {
            VStack(spacing: .spacing8) {
                BookCover(book: book)
                    .frame(width: min(coverWidth, .maxCoverWidth))
                    .padding(.top, .spacing16)
                    // The title and author are right below as text, so VoiceOver doesn't need the cover too
                    .accessibilityHidden(true)

                Spacer.height(.spacing8)

                Text(book.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)

                StatusChip(status: book.status)
                    .padding(.top, .spacing8)
                    .accessibilityLabel("Status: \(String(localized: book.status.chipTitle))")

                progressCard(for: book)
                    .padding(.top, .spacing24)
            }
            .padding(.horizontal, .spacing20)
        }
        .background {
            ZStack(alignment: .top) {
                Color.appBackground
                LinearGradient(
                    colors: [CoverPalette.palette(for: book.title).start.opacity(0.75), Color.appBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: .heroGradientHeight)
            }
            .ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("More", systemImage: "ellipsis") {
                    Button("Remove from shelf", systemImage: "trash", role: .destructive) {
                        viewModel.isConfirmingRemoval = true
                    }
                }
            }
        }
        .sheet(item: $viewModel.sheet) { sheet in
            switch sheet {
            case .updateProgress:
                UpdateProgressView(viewModel: UpdateProgressViewModelImpl(currentPage: book.currentPage, pages: book.pages) { page in
                    if viewModel.setCurrentPage(page) {
                        AccessibilityNotification.Announcement.post("Progress saved")
                    }
                })
            case .addNote:
                AddNoteView(viewModel: AddNoteViewModelImpl { text in
                    if viewModel.addNote(text) {
                        AccessibilityNotification.Announcement.post("Note added")
                    }
                })
            }
        }
        // Deleting can't be undone, so ask first
        .confirmationDialog("Remove this book?", isPresented: $viewModel.isConfirmingRemoval, titleVisibility: .visible) {
            Button("Remove from shelf", role: .destructive) {
                if viewModel.delete() {
                    AccessibilityNotification.Announcement.post("Removed from shelf")
                    dismiss()
                }
            }
        } message: {
            Text("Its notes are deleted as well.")
        }
        .confirmationDialog("Delete this note?", isPresented: $viewModel.noteToDelete.isPresent(), titleVisibility: .visible, presenting: viewModel.noteToDelete) { note in
            Button("Delete note", role: .destructive) {
                viewModel.deleteNote(note)
                AccessibilityNotification.Announcement.post("Note deleted")
            }
        }
        .errorHandler($viewModel.error)
        // Saved progress and added notes feel like a small success
        .hapticFeedback(on: book.currentPage, type: .notification(.success))
        .hapticFeedback(on: book.notes.count, type: .notification(.success))
    }

    private func progressCard(for book: Book) -> some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            progress(for: book)
            actions
            notes(for: book)
        }
        .padding(.spacing24)
        .frame(maxWidth: .infinity, minHeight: .progressCardMinHeight, alignment: .topLeading)
        .background(Color.cardBackground, in: .rect(cornerRadius: .cornerRadius32))
        .cardShadow()
    }

    /// Title, percent, bar and page count are read as one element: "Progress, 20 percent, 120 of 608 pages".
    private func progress(for book: Book) -> some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            // Next to each other if they fit, below each other with large text
            ViewThatFits(in: .horizontal) {
                HStack {
                    Text("Progress")
                    Spacer()
                    Text(book.progress, format: .percent.precision(.fractionLength(0)))
                }
                VStack(alignment: .leading) {
                    Text("Progress")
                    Text(book.progress, format: .percent.precision(.fractionLength(0)))
                }
            }
            .font(.title3.weight(.semibold))

            ProgressBar(value: book.progress)

            Text("\(book.currentPage) of \(book.pages) pages")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue(String(localized: "\(book.progressPercent) percent, \(book.currentPage) of \(book.pages) pages"))
    }

    /// Side by side if there is room, below each other with large text sizes (`ViewThatFits`).
    private var actions: some View {
        let buttons = Group {
            Button {
                viewModel.sheet = .updateProgress
            } label: {
                Text("Update progress")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)

            Button("Finished") {
                if viewModel.finish() {
                    AccessibilityNotification.Announcement.post("Marked as finished")
                }
            }
            .buttonStyle(.glass)
        }

        return ViewThatFits(in: .horizontal) {
            HStack(spacing: .spacing12) { buttons }
            VStack(spacing: .spacing12) { buttons }
        }
        .controlSize(.large)
    }

    private var notesTitle: some View {
        Text("Notes")
            .font(.title3.weight(.semibold))
            .accessibilityAddTraits(.isHeader)
    }

    private func notes(for book: Book) -> some View {
        let addNoteButton = Button {
            viewModel.sheet = .addNote
        } label: {
            Text("+ Add note")
                .font(.callout.weight(.semibold))
                .foregroundStyle(Color.accentText)
                // at least 44 pt high to tap (Apple HIG)
                .frame(minHeight: .minTapTarget)
        }
        // VoiceOver should say "Add note", not "plus Add note"
        .accessibilityLabel("Add note")

        return VStack(alignment: .leading, spacing: .spacing12) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    notesTitle
                    Spacer()
                    addNoteButton
                }
                VStack(alignment: .leading) {
                    notesTitle
                    addNoteButton
                }
            }

            if book.notes.isEmpty {
                Text("No notes yet.")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }

            ForEach(book.sortedNotes) { note in
                Text(note.text)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contextMenu {
                        Button("Delete note", systemImage: "trash", role: .destructive) {
                            viewModel.noteToDelete = note
                        }
                    }
                    // A context menu is hard to reach with VoiceOver, a custom action shows up in the actions rotor
                    .accessibilityAction(named: "Delete note") {
                        viewModel.noteToDelete = note
                    }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BookDetailView(viewModel: BookDetailViewModelPreview())
    }
}

#Preview("Accessibility text size") {
    NavigationStack {
        BookDetailView(viewModel: BookDetailViewModelPreview())
    }
    .dynamicTypeSize(.accessibility3)
}
