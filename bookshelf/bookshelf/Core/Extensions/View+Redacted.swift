//
//  View+Redacted.swift
//  bookshelf
//

import SwiftUI

extension View {
    /// Skeleton loading: while `isLoading` the view shows its (placeholder) data as gray blocks.
    /// Feed it fixtures (`Book.placeholders()`), so the skeleton has the same shape as the real content.
    ///
    /// The skeleton is not interactive, and VoiceOver hears one "Loading" instead of fake titles.
    func redacted(when isLoading: Bool, label: LocalizedStringKey = "Loading") -> some View {
        redacted(reason: isLoading ? .placeholder : [])
            .allowsHitTesting(!isLoading)
            .accessibilityHidden(isLoading)
            .overlay {
                if isLoading {
                    Color.clear
                        .accessibilityElement()
                        .accessibilityLabel(label)
                        .allowsHitTesting(false)
                }
            }
    }
}

extension EnvironmentValues {
    /// True while a parent shows this view as a skeleton (`redacted(when:)`).
    var isPlaceholder: Bool {
        redactionReasons.contains(.placeholder)
    }
}
