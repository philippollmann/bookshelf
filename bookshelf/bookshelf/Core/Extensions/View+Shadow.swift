//
//  View+Shadow.swift
//  bookshelf
//

import SwiftUI

extension View {
    /// The soft shadow under cards and the search field. The color lives in `Colors.xcassets`.
    func cardShadow() -> some View {
        shadow(color: .cardShadow, radius: .spacing16, y: .spacing4)
    }
}
