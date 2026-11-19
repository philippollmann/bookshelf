//
//  SettingsView.swift
//  bookshelf
//

import SwiftUI

struct SettingsView<Model: SettingsViewModel>: View {
    @State var viewModel: Model
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Daily reading reminder", isOn: Binding(
                        get: { viewModel.reminderEnabled },
                        set: { enabled in Task { await viewModel.setReminder(enabled: enabled) } }
                    ))
                } footer: {
                    Text("A notification every evening at 8 pm.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
            .errorHandler($viewModel.error)
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModelPreview())
}

#Preview("Accessibility text size") {
    SettingsView(viewModel: SettingsViewModelPreview())
        .dynamicTypeSize(.accessibility3)
}
