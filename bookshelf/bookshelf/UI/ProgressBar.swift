//
//  ProgressBar.swift
//  bookshelf
//

import SwiftUI

/// A thin rounded progress bar in the accent color. `value` is between 0 and 1.
struct ProgressBar: View {
    let value: Double

    var body: some View {
        Capsule()
            .fill(Color.fieldBackground)
            .frame(height: .spacing8)
            .overlay(alignment: .leading) {
                GeometryReader { geometry in
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * min(max(value, 0), 1))
                        .animationRespectingReduceMotion(value: value)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Progress")
            .accessibilityValue(Text(value, format: .percent.precision(.fractionLength(0))))
    }
}

#Preview {
    ProgressBar(value: 0.34)
        .padding(.spacing16)
}
