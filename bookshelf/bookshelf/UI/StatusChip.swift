//
//  StatusChip.swift
//  bookshelf
//

import SwiftUI

extension ReadingStatus {
    var chipTitle: LocalizedStringResource {
        switch self {
        case .wantToRead: "Want to read"
        case .reading: "Reading"
        case .finished: "Finished"
        }
    }

    fileprivate var chipColors: (background: Color, text: Color, selectedBackground: Color) {
        switch self {
        case .wantToRead:
            (.statusWantToReadBackground, .statusWantToReadText, .statusWantToReadSelected)
        case .reading:
            (.statusReadingBackground, .statusReadingText, .statusReadingSelected)
        case .finished:
            (.statusFinishedBackground, .statusFinishedText, .statusFinishedSelected)
        }
    }
}

/// A colored pill with the reading status. `isSelected` is used when the pills act as a picker.
/// A picker pill is `isLarge`: the pill itself is at least 44 pt high, so what you see is what you can tap.
struct StatusChip: View {
    let status: ReadingStatus
    var isSelected = false
    var isLarge = false

    var body: some View {
        let colors = status.chipColors

        Text(status.chipTitle)
            .font((isLarge ? Font.subheadline : .footnote).weight(.semibold))
            .foregroundStyle(isSelected ? Color.textOnFill : colors.text)
            .padding(.horizontal, .spacing12)
            .padding(.vertical, .spacing4)
            // A minimum, not a fixed height: with large text the pill has to grow
            .frame(maxWidth: isLarge ? .infinity : nil, minHeight: isLarge ? .minTapTarget : nil)
            .background(isSelected ? colors.selectedBackground : colors.background, in: Capsule())
    }
}

#Preview {
    VStack(spacing: .spacing8) {
        HStack {
            ForEach(ReadingStatus.allCases, id: \.self) { StatusChip(status: $0) }
        }
        HStack {
            ForEach(ReadingStatus.allCases, id: \.self) { StatusChip(status: $0, isSelected: true, isLarge: true) }
        }
    }
    .padding(.spacing16)
}

#Preview("Dark mode") {
    VStack(spacing: .spacing8) {
        HStack {
            ForEach(ReadingStatus.allCases, id: \.self) { StatusChip(status: $0) }
        }
        HStack {
            ForEach(ReadingStatus.allCases, id: \.self) { StatusChip(status: $0, isSelected: true) }
        }
    }
    .padding(.spacing16)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
