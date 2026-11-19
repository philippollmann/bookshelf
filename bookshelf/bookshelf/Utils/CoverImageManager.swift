//
//  CoverImageManager.swift
//  bookshelf
//

import ImageIO
import PhotosUI
import SwiftUI
import UIKit

/// Turns a picked or photographed image into small JPEG data that is stored with the book,
/// and decodes stored covers for display. Cross-cutting concern, so it is a singleton manager like `RatingManager`.
@MainActor
final class CoverImageManager {
    static let shared = CoverImageManager()

    /// Longest side in pixels, for storing and for showing. The biggest cover (`maxCoverWidth` * 1.5 at 3x)
    /// needs about this much, and it keeps the database small.
    private nonisolated static let maxDimension: CGFloat = 1080

    /// Decoded covers by their data. Decoding a JPEG on every render would make the grid stutter.
    private let cache = NSCache<NSData, UIImage>()

    private init() {}

    /// The simulator and some iPads have no camera: the view hides "Take photo" then.
    var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    /// The cover as an image, decoded at display size and cached.
    func image(from data: Data) -> UIImage? {
        let key = data as NSData
        if let cached = cache.object(forKey: key) { return cached }

        guard let image = Self.thumbnail(from: data) else { return nil }
        cache.setObject(image, forKey: key)
        return image
    }

    func coverData(from item: PhotosPickerItem) async throws -> Data {
        guard let raw = try await item.loadTransferable(type: Data.self),
              let data = await Self.encode(raw)
        else { throw CustomError.invalidImage }
        return data
    }

    func coverData(from image: UIImage) -> Data? {
        let longestSide = max(image.size.width, image.size.height) * image.scale
        let ratio = min(1, Self.maxDimension / longestSide)
        let size = CGSize(width: image.size.width * image.scale * ratio, height: image.size.height * image.scale * ratio)

        // Redrawing also applies the camera's orientation, so the photo is never rotated
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: 0.8)
    }

    /// Off the main thread: a photo of 12 megapixels takes a while to scale and encode.
    @concurrent
    private nonisolated static func encode(_ raw: Data) async -> Data? {
        thumbnail(from: raw)?.jpegData(compressionQuality: 0.8)
    }

    /// ImageIO scales while decoding, so the full-size bitmap never exists. It also applies the orientation.
    private nonisolated static func thumbnail(from data: Data) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
        else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
