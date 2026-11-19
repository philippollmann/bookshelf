//
//  AddNoteViewModel.swift
//  bookshelf
//

import Foundation
import Observation

protocol AddNoteViewModel: AnyObject, Observable {
    var text: String { get set }

    func save()
}

extension AddNoteViewModel {
    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Hands the note to `onSave`; the book detail screen owns the data and stores it.
@Observable
final class AddNoteViewModelImpl: AddNoteViewModel {
    var text = ""

    private let onSave: (String) -> Void

    init(onSave: @escaping (String) -> Void) {
        self.onSave = onSave
    }

    func save() {
        onSave(trimmedText)
    }
}

@Observable
final class AddNoteViewModelPreview: AddNoteViewModel {
    var text = "Loved the slow start in the Shire."

    func save() {}
}
