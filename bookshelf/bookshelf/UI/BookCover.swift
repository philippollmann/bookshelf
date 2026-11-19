//
//  BookCover.swift
//  bookshelf
//

import SwiftUI

private extension Color {
    init(rgb red: Double, _ green: Double, _ blue: Double) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255)
    }
}

/// Gradient colors for covers without an image. The palette is picked from the title,
/// so a book always gets the same cover. These are decorative and not part of the app theme
/// (that lives in `Resources/Colors.xcassets`), so they stay in code.
struct CoverPalette {
    let start: Color
    let end: Color

    private static let all: [CoverPalette] = [
        CoverPalette(start: Color(rgb: 77, 128, 82), end: Color(rgb: 26, 56, 36)),
        CoverPalette(start: Color(rgb: 56, 56, 66), end: Color(rgb: 10, 10, 18)),
        CoverPalette(start: Color(rgb: 107, 140, 173), end: Color(rgb: 46, 66, 97)),
        CoverPalette(start: Color(rgb: 204, 140, 64), end: Color(rgb: 115, 64, 26)),
        CoverPalette(start: Color(rgb: 64, 77, 140), end: Color(rgb: 26, 31, 77)),
        CoverPalette(start: Color(rgb: 140, 77, 102), end: Color(rgb: 64, 26, 46)),
        CoverPalette(start: Color(rgb: 77, 128, 128), end: Color(rgb: 26, 64, 71)),
        CoverPalette(start: Color(rgb: 128, 115, 77), end: Color(rgb: 56, 46, 26)),
        CoverPalette(start: Color(rgb: 102, 102, 140), end: Color(rgb: 38, 38, 77)),
        CoverPalette(start: Color(rgb: 31, 31, 31), end: Color(rgb: 107, 36, 13)),
    ]

    static func palette(for title: String) -> CoverPalette {
        let sum = title.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        return all[sum % all.count]
    }

    var gradient: LinearGradient {
        LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}


struct BookCover: View {
    let title: String
    let author: String
    var coverURL: URL?
    /// JPEG data of a photo from the user. It wins over `coverURL`.
    var coverImageData: Data?
    var showsBookmark = false

    @Environment(\.isPlaceholder) private var isPlaceholder
    // The text on the cover follows the user's text size, like all other text
    @ScaledMetric(relativeTo: .title3) private var titleSize = Art.titleSize
    @ScaledMetric(relativeTo: .caption) private var authorSize = Art.authorSize

    /// Measures of the cover art from the Figma design. They are relative to `designWidth`
    /// and scaled with the real cover width, so they are the one place where plain numbers are fine.
    private enum Art {
        static let designWidth: CGFloat = 173
        static let titleSize: CGFloat = 22
        static let authorSize: CGFloat = 11
        static let circle = (size: CGFloat(110), x: CGFloat(30), y: CGFloat(44))
        static let ring = (size: CGFloat(150), x: CGFloat(12), y: CGFloat(24))
        static let line = (width: CGFloat(40), height: CGFloat(2), x: CGFloat(14), y: CGFloat(20))
    }

    var body: some View {
        Color.clear
            .aspectRatio(.coverAspectRatio, contentMode: .fit)
            .overlay { artwork }
            .overlay(alignment: .topTrailing) {
                if showsBookmark, !isPlaceholder {
                    UnevenRoundedRectangle(bottomLeadingRadius: .cornerRadius4, bottomTrailingRadius: .cornerRadius4)
                        .fill(Color.bookmark)
                        .frame(width: .bookmarkWidth, height: .bookmarkHeight)
                        .padding(.trailing, .spacing16)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadius8))
            .shadow(color: isPlaceholder ? .clear : .coverShadow, radius: .spacing8, y: .spacing8)
            // The cover is one image for VoiceOver: its text is drawn art, not separate elements
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(title), \(author)")
            .accessibilityAddTraits(.isImage)
    }

    /// Skeleton: a plain gray block. Otherwise the generated cover, with a photo or the remote cover on top.
    @ViewBuilder
    private var artwork: some View {
        if isPlaceholder {
            Rectangle().fill(Color.skeleton)
        } else {
            ZStack {
                generatedCover
                if let image = coverImageData.flatMap(CoverImageManager.shared.image(from:)) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let coverURL {
                    RemoteCoverImage(url: coverURL)
                }
            }
        }
    }

    private var generatedCover: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / Art.designWidth

            ZStack(alignment: .topLeading) {
                CoverPalette.palette(for: title).gradient

                Image("CoverArtCircle")
                    .resizable()
                    .frame(width: Art.circle.size * scale, height: Art.circle.size * scale)
                    .offset(x: Art.circle.x * scale, y: Art.circle.y * scale)
                Image("CoverArtRing")
                    .resizable()
                    .frame(width: Art.ring.size * scale, height: Art.ring.size * scale)
                    .offset(x: Art.ring.x * scale, y: Art.ring.y * scale)
                Rectangle()
                    .fill(Color.textOnFill.opacity(0.6))
                    .frame(width: Art.line.width * scale, height: Art.line.height * scale)
                    .offset(x: Art.line.x * scale, y: Art.line.y * scale)

                VStack(alignment: .leading, spacing: .spacing4 * scale) {
                    Spacer()
                    Text(title.uppercased())
                        .font(.system(size: titleSize * scale, weight: .bold))
                        .lineLimit(3)
                        .minimumScaleFactor(0.6)
                    Text(author.uppercased())
                        .font(.system(size: authorSize * scale, weight: .semibold))
                        .opacity(0.8)
                        .lineLimit(1)
                }
                .foregroundStyle(Color.textOnFill)
                .padding(.spacing16 * scale)
            }
        }
    }
}

extension BookCover {
    /// Books that are being read get the bookmark.
    init(book: Book) {
        self.init(
            title: book.title,
            author: book.author,
            coverURL: book.coverURL,
            coverImageData: book.coverImageData,
            showsBookmark: book.status == .reading
        )
    }
}

/// The small cover next to search results.
struct BookCoverMini: View {
    let title: String
    var coverURL: URL?

    /// Grows with the user's text size, so the cover keeps its proportion to the text next to it.
    @ScaledMetric(relativeTo: .headline) private var width = CGFloat.miniCoverWidth
    @ScaledMetric(relativeTo: .caption2) private var titleSize = CGFloat.miniCoverTitleSize
    @Environment(\.isPlaceholder) private var isPlaceholder

    var body: some View {
        RoundedRectangle(cornerRadius: .cornerRadius4)
            .fill(isPlaceholder ? AnyShapeStyle(Color.skeleton) : AnyShapeStyle(CoverPalette.palette(for: title).gradient))
            .frame(width: width, height: width / .coverAspectRatio)
            .overlay(alignment: .bottomLeading) {
                if !isPlaceholder {
                    Text(title.uppercased())
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundStyle(Color.textOnFill)
                        .lineLimit(2)
                        .padding(.spacing4)
                }
            }
            .overlay {
                if let coverURL, !isPlaceholder {
                    RemoteCoverImage(url: coverURL)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadius4))
            // Decorative: the title is always next to it as text
            .accessibilityHidden(true)
    }
}

/// The cover from Open Library. While it loads (or fails) the generated cover below stays visible.
private struct RemoteCoverImage: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            }
        }
    }
}

#Preview("Covers") {
    HStack(alignment: .top, spacing: .spacing16) {
        BookCover(title: "The Hobbit", author: "J.R.R. Tolkien", showsBookmark: true)
        BookCover(title: "Onyx Storm", author: "Rebecca Yarros")
        BookCoverMini(title: "Dune")
    }
    .padding(.spacing16)
}
