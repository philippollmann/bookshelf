//
//  View+Field.swift
//  bookshelf
//

import SwiftUI

extension View {
    /// The rounded gray container behind text fields and the note editor.
    func fieldBackground() -> some View {
        background(Color.fieldBackground, in: .rect(cornerRadius: .cornerRadius16))
    }
}
