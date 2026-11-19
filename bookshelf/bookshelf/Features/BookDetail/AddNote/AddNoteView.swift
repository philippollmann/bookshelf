//
//  AddNoteView.swift
//  bookshelf
//

import SwiftUI

/// Sheet to write a note.
struct AddNoteView<Model: AddNoteViewModel>: View {
    @State var viewModel: Model
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TextEditor(text: $viewModel.text)
                .focused($isFocused)
                .accessibilityLabel("Note")
                .scrollContentBackground(.hidden)
                .padding(.spacing12)
                .fieldBackground()
                .padding(.horizontal, .spacing20)
                .padding(.bottom, .spacing20)
                .navigationTitle("Add note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close) { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm) {
                            viewModel.save()
                            dismiss()
                        }
                        .disabled(viewModel.trimmedText.isEmpty)
                    }
                }
        }
        // With large text the editor needs more room than the medium sheet
        .presentationDetents([.medium, .large])
        .onAppear { isFocused = true }
    }
}

#Preview {
    Color.appBackground
        .sheet(isPresented: .constant(true)) {
            AddNoteView(viewModel: AddNoteViewModelPreview())
        }
}

#Preview("Accessibility text size") {
    Color.appBackground
        .sheet(isPresented: .constant(true)) {
            AddNoteView(viewModel: AddNoteViewModelPreview())
                .dynamicTypeSize(.accessibility3)
        }
}
