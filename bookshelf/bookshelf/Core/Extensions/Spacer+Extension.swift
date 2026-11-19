//
//  Spacer+Extension.swift
//  bookshelf
//

import SwiftUI

extension Spacer {
    /// A fixed-width spacer, e.g. `Spacer.width(.spacing8)`.
    static func width(_ width: CGFloat) -> some View {
        Spacer()
            .frame(width: width)
    }

    /// A fixed-height spacer, e.g. `Spacer.height(.spacing16)`.
    static func height(_ height: CGFloat) -> some View {
        Spacer()
            .frame(height: height)
    }
}
