//
//  CGFloat+Extension.swift
//  bookshelf
//

import Foundation

/// All spacing and corner radii in the app are multiples of 4 (4-point grid).
/// Use these constants instead of magic numbers: `.padding(.spacing16)`.
extension CGFloat {
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    static let spacing40: CGFloat = 40
    static let spacing48: CGFloat = 48

    static let cornerRadius4: CGFloat = 4
    static let cornerRadius8: CGFloat = 8
    static let cornerRadius12: CGFloat = 12
    static let cornerRadius16: CGFloat = 16
    static let cornerRadius24: CGFloat = 24
    static let cornerRadius32: CGFloat = 32

    /// Smallest size of anything you tap (Apple Human Interface Guidelines).
    static let minTapTarget: CGFloat = 44

    // MARK: Sizes of the book covers (they scale with the text size, see `@ScaledMetric`)

    /// Cover in the add-book form and the largest it may grow to.
    static let formCoverWidth: CGFloat = 128
    static let maxFormCoverWidth: CGFloat = 200
    /// Cover on the detail screen and the largest it may grow to.
    static let detailCoverWidth: CGFloat = 172
    static let maxCoverWidth: CGFloat = 240
    /// Small cover next to a search result.
    static let miniCoverWidth: CGFloat = 48
    static let miniCoverTitleSize: CGFloat = 7
    /// Width divided by height of every cover.
    static let coverAspectRatio: CGFloat = 2 / 3
    static let bookmarkWidth: CGFloat = 20
    static let bookmarkHeight: CGFloat = 40

    // MARK: Other sizes

    /// Colored gradient behind the cover on the detail screen.
    static let heroGradientHeight: CGFloat = 540
    static let progressCardMinHeight: CGFloat = 240
    static let pageNumberSize: CGFloat = 44
}
