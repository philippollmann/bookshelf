//
//  UpdateProgressView.swift
//  bookshelf
//

import SwiftUI

/// Sheet to enter the page you are on.
struct UpdateProgressView<Model: UpdateProgressViewModel>: View {
    @State var viewModel: Model
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .largeTitle) private var pageNumberSize = CGFloat.pageNumberSize

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .spacing16) {
                    // - [26 of 320 pages] +  on one line, with large text the number goes on top
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: .spacing12) {
                            decreaseButton
                            pageNumber
                            increaseButton
                        }
                        VStack(spacing: .spacing12) {
                            pageNumber
                            HStack(spacing: .spacing24) {
                                decreaseButton
                                increaseButton
                            }
                        }
                    }

                    // The system slider reads its value as a percentage by default, we want the page.
                    // `step: 1` makes VoiceOver's swipe up/down change one page, not ten percent.
                    Slider(
                        value: Binding(get: { Double(viewModel.page) }, set: { viewModel.page = Int($0) }),
                        in: 0 ... Double(viewModel.pages),
                        step: 1
                    )
                    .accessibilityLabel("Page")
                    .accessibilityValue(String(localized: "\(viewModel.page) of \(viewModel.pages)"))

                    // Three chips side by side, below each other with large text
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: .spacing8) { quickAddButtons }
                        VStack(spacing: .spacing8) { quickAddButtons }
                    }

                    Text("Reaching the last page marks the book as finished.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, .spacing20)
            }
            .animationRespectingReduceMotion(value: viewModel.page)
            // A tick for every page, like a picker
            .hapticFeedback(on: viewModel.page, type: .selection)
            .navigationTitle("Update progress")
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
                }
            }
        }
        // Not a fixed height: with large text the content needs more room
        .presentationDetents([.medium, .large])
    }

    /// "26, of 320 pages" is read as one element
    private var pageNumber: some View {
        VStack {
            Text(viewModel.page, format: .number)
                .font(.system(size: pageNumberSize, weight: .bold))
                .contentTransitionRespectingReduceMotion()
            Text("of \(viewModel.pages) pages")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var decreaseButton: some View {
        stepButton("Previous page", systemImage: "minus", delta: -1)
    }

    private var increaseButton: some View {
        stepButton("Next page", systemImage: "plus", delta: 1)
    }

    /// Icon-only: the title is what VoiceOver reads.
    private func stepButton(_ title: LocalizedStringKey, systemImage: String, delta: Int) -> some View {
        Button(title, systemImage: systemImage) { viewModel.change(by: delta) }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            .labelStyle(.iconOnly)
    }

    @ViewBuilder
    private var quickAddButtons: some View {
        quickAdd("+10 pages") { viewModel.change(by: 10) }
        quickAdd("+25 pages") { viewModel.change(by: 25) }
        quickAdd("Last page") { viewModel.page = viewModel.pages }
    }

    private func quickAdd(_ title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: .minTapTarget)
                .background(Color.fieldBackground, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Color.appBackground
        .sheet(isPresented: .constant(true)) {
            UpdateProgressView(viewModel: UpdateProgressViewModelPreview())
        }
}

#Preview("Accessibility text size") {
    Color.appBackground
        .sheet(isPresented: .constant(true)) {
            UpdateProgressView(viewModel: UpdateProgressViewModelPreview())
                .dynamicTypeSize(.accessibility3)
        }
}
