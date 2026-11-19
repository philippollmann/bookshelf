//
//  AddBookViewModel.swift
//  bookshelf
//

import Foundation
import Observation
import PhotosUI
import SwiftUI
import UIKit

protocol AddBookViewModel: AnyObject, Observable, ErrorReporting {
    var title: String { get set }
    var author: String { get set }
    var pagesText: String { get set }
    var status: ReadingStatus { get set }
    var coverURL: URL? { get set }
    var coverImageData: Data? { get set }
    var photoItem: PhotosPickerItem? { get set }
    var showPhotoPicker: Bool { get set }
    var showCamera: Bool { get set }
    var isCameraAvailable: Bool { get }
    var externalId: String? { get set }
    var showSearch: Bool { get set }
    var error: Error? { get set }

    /// Reads the photo picked in the library into `coverImageData`.
    func loadPhoto() async

    /// Takes the image from the camera sheet.
    func useCamera(_ image: UIImage)

    /// Returns `true` if the book was added, so the view can close itself.
    func save() -> Bool
}

extension AddBookViewModel {
    var pages: Int? {
        Int(pagesText)
    }

    var canSave: Bool {
        !title.isEmpty && !author.isEmpty && (pages ?? 0) > 0
    }

    /// Called when the user picks a result in the search: fills the form and goes back to it.
    func fill(with result: BookSearchResult) {
        title = result.title
        author = result.author
        pagesText = result.pages > 0 ? String(result.pages) : ""
        coverURL = result.coverURL
        coverImageData = nil
        externalId = result.id
        showSearch = false
    }

    var hasCustomCover: Bool {
        coverImageData != nil || coverURL != nil
    }

    /// Back to the generated default cover, which follows title and author live.
    func removeCover() {
        coverURL = nil
        coverImageData = nil
        photoItem = nil
    }
}

@Observable
final class AddBookViewModelImpl: AddBookViewModel {
    var title = ""
    var author = ""
    var pagesText = ""
    var status = ReadingStatus.wantToRead
    var coverURL: URL?
    var coverImageData: Data?
    var photoItem: PhotosPickerItem?
    var showPhotoPicker = false
    var showCamera = false
    var externalId: String?
    var showSearch = false
    var error: Error?

    var isCameraAvailable: Bool {
        coverImageManager.isCameraAvailable
    }

    private let repository = BookRepository.shared
    private let coverImageManager = CoverImageManager.shared

    func loadPhoto() async {
        guard let photoItem else { return }

        do {
            coverImageData = try await coverImageManager.coverData(from: photoItem)
            coverURL = nil
        } catch {
            self.error = error
        }
    }

    func useCamera(_ image: UIImage) {
        coverImageData = coverImageManager.coverData(from: image)
        coverURL = nil
    }

    func save() -> Bool {
        guard let pages else { return false }

        return attempt {
            try repository.add(title: title, author: author, pages: pages, status: status, coverURL: coverURL, coverImageData: coverImageData, externalId: externalId)
        }
    }
}

@Observable
final class AddBookViewModelPreview: AddBookViewModel {
    var title = "Dune"
    var author = "Frank Herbert"
    var pagesText = "412"
    var status = ReadingStatus.wantToRead
    var coverURL: URL?
    var coverImageData: Data?
    var photoItem: PhotosPickerItem?
    var showPhotoPicker = false
    var showCamera = false
    var isCameraAvailable = true
    var externalId: String?
    var showSearch = false
    var error: Error?

    func loadPhoto() async {}

    func useCamera(_ image: UIImage) {}

    func save() -> Bool {
        true
    }
}
