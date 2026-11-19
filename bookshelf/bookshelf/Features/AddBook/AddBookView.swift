//
//  AddBookView.swift
//  bookshelf
//

import PhotosUI
import SwiftUI

/// Sheet with a form for a new book. The search button opens `SearchBookView`; picking a result fills the form.
struct AddBookView<Model: AddBookViewModel>: View {
    @State var viewModel: Model
    @Environment(\.dismiss) private var dismiss

    /// Scales with the text size, but is capped so the form stays in reach.
    @ScaledMetric(relativeTo: .largeTitle) private var coverWidth = CGFloat.formCoverWidth

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .spacing12) {
                    coverPicker

                    FormField(title: "Title", text: $viewModel.title)
                    FormField(title: "Author", text: $viewModel.author)
                    FormField(title: "Pages", text: $viewModel.pagesText)
                        .keyboardType(.numberPad)

                    Text("Status")
                        .font(.headline)
                        .padding(.top, .spacing8)
                        .accessibilityAddTraits(.isHeader)

                    // Side by side if there is room, below each other with large text
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: .spacing8) { statusButtons }
                        VStack(alignment: .leading, spacing: .spacing8) { statusButtons }
                    }

                    Spacer.height(.spacing16)

                    Button {
                        viewModel.showSearch = true
                    } label: {
                        Label("Search Open Library", systemImage: "magnifyingglass")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)

                    Text("Cover and page count are filled in when you pick a book from the search.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(.horizontal, .spacing20)
                .padding(.top, .spacing16)
            }
            .background(Color.appBackground)
            .navigationTitle("Add book")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $viewModel.showSearch) {
                SearchBookView(viewModel: SearchBookViewModelImpl(), onSelect: viewModel.fill(with:))
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        if viewModel.save() {
                            AccessibilityNotification.Announcement.post("Book added")
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .photosPicker(isPresented: $viewModel.showPhotoPicker, selection: $viewModel.photoItem, matching: .images)
            .fullScreenCover(isPresented: $viewModel.showCamera) {
                CameraPicker { viewModel.useCamera($0) }
                    .ignoresSafeArea()
            }
            // Runs when a photo was picked (and once at the start, where `loadPhoto` returns right away)
            .task(id: viewModel.photoItem) { await viewModel.loadPhoto() }
            .hapticFeedback(on: viewModel.status, type: .selection)
            .errorHandler($viewModel.error)
        }
    }
}

extension AddBookView {
    /// Without a picked image this is the default cover, drawn live from title and author.
    private var coverPicker: some View {
        BookCover(
            title: viewModel.title.isEmpty ? String(localized: "Title") : viewModel.title,
            author: viewModel.author.isEmpty ? String(localized: "Author") : viewModel.author,
            coverURL: viewModel.coverURL,
            coverImageData: viewModel.coverImageData
        )
        .frame(width: min(coverWidth, .maxFormCoverWidth))
        // The menu button on the cover is the control, the cover is only a preview of the title and author fields
        .accessibilityHidden(true)
        // Like an avatar editor: a round button on the corner of the cover, half outside of it
        .overlay(alignment: .bottomTrailing) {
            coverMenu
                .offset(x: .spacing12, y: .spacing12)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, .spacing12)
    }

    private var coverMenu: some View {
        Menu {
            if viewModel.isCameraAvailable {
                Button("Take photo", systemImage: "camera") { viewModel.showCamera = true }
            }
            Button("Choose from library", systemImage: "photo.on.rectangle") { viewModel.showPhotoPicker = true }
            if viewModel.hasCustomCover {
                Button("Remove cover", systemImage: "trash", role: .destructive) { viewModel.removeCover() }
            }
        } label: {
            // Icon-only: the title is what VoiceOver reads
            Label("Change cover", systemImage: "camera.fill")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .controlSize(.large)
    }

    @ViewBuilder
    private var statusButtons: some View {
        ForEach([ReadingStatus.wantToRead, .reading, .finished], id: \.self) { option in
            Button {
                viewModel.status = option
            } label: {
                StatusChip(status: option, isSelected: viewModel.status == option, isLarge: true)
            }
            .buttonStyle(.plain)
            // The color alone must not carry the state: VoiceOver says "selected"
            .accessibilityAddTraits(viewModel.status == option ? .isSelected : [])
        }
    }
}

/// A text field with a small label above it, in a rounded gray container.
private struct FormField: View {
    let title: LocalizedStringKey
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
                // The label belongs to the text field below, don't read it twice
                .accessibilityHidden(true)
            TextField("", text: $text)
                .accessibilityLabel(title)
        }
        .padding(.horizontal, .spacing16)
        .padding(.vertical, .spacing12)
        .fieldBackground()
    }
}

#Preview {
    AddBookView(viewModel: AddBookViewModelPreview())
}

#Preview("Accessibility text size") {
    AddBookView(viewModel: AddBookViewModelPreview())
        .dynamicTypeSize(.accessibility3)
}
