//
//  Book+Extension.swift
//  bookshelf
//

extension Book {
    /// Whole percent for VoiceOver ("8 percent read"), the screen uses the `.percent` format style.
    var progressPercent: Int {
        Int(progress * 100)
    }
}
