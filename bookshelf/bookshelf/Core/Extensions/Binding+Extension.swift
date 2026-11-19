//
//  Binding+Extension.swift
//  bookshelf
//

import SwiftUI

extension Binding {
    /// `true` while the optional has a value; setting it to `false` clears the value.
    /// For dialogs and alerts that are shown for an optional item.
    func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        Binding<Bool>(
            get: { wrappedValue != nil },
            set: { if !$0 { wrappedValue = nil } }
        )
    }
}
