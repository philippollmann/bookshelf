//
//  Note.swift
//  bookshelf
//

import Foundation
import SwiftData

/// A personal note about a book. Belongs to exactly one `Book` (see the relationship there).
@Model
final class Note {
    var text: String
    var createdAt: Date

    init(text: String, createdAt: Date = .now) {
        self.text = text
        self.createdAt = createdAt
    }
}
