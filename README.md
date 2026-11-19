# Bookshelf

A small iOS app that serves as a **reference for app architecture**: SwiftUI, SwiftData, a repository-based data layer, protocol-based ViewModels, a networking layer and manager singletons. Built for the iOS Advanced course. Read it, run it, copy the structure into your own app.

Track the books you read, search for new ones online (Open Library), log your reading progress and keep notes. English and German.

## Run it

1. Open `bookshelf/bookshelf.xcodeproj` (Xcode 26, iOS 26 simulator).
2. Run the `bookshelf` scheme.

No API key is needed, the Open Library search is public.

## Where to look

```
bookshelf/bookshelf/
├── BookshelfApp.swift   entry point
├── Features/       one folder per screen: View + ViewModel (protocol, Impl, Preview)
│   ├── Root/  Shelf/  Settings/
│   ├── AddBook/        SearchBook/ lives inside, only AddBook opens it
│   └── BookDetail/     AddNote/ and UpdateProgress/ live inside
├── Data/           per data source: Books/ (BookRepository, SwiftData),
│                   Search/ (BookApi endpoints + BookSearchRepository, network)
├── Model/          Manual/ (Book, Note, search response) · Extension/ · Placeholder/ (preview data)
├── Core/           Networking, Error, Extensions (4-point-grid spacing)
├── UI/             reusable views: BookCover, BookGridCard, StatusChip, ProgressBar
├── Utils/          Configuration, RatingManager, NotificationPermissionManager
└── Resources/      Colors.xcassets, Assets.xcassets, Localizable.xcstrings (English + German)
```

Data flow: `View -> ViewModel -> Repository -> Api (network) / SwiftData`.

**Accessibility** is a focus of this project: see [docs/accessibility.md](docs/accessibility.md) for what to think about, Apple's resources, how to test (previews, Accessibility Inspector, VoiceOver) and where each technique is used in the code.

Start reading at `Features/Shelf/ShelfView.swift` and follow it down to `BookRepository`. Add a book with the search (`AddBook`) and follow it through `BookSearchRepository`, `BookApi` and `NetworkingProvider`.

## Use it with an AI assistant

`CLAUDE.md` describes the architecture and a step-by-step recipe for adding a feature. Point your assistant at this repo (or paste the file) and ask it to build features in the same structure.
