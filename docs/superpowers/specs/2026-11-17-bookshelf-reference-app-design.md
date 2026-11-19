# Bookshelf reference app: design

## Intent and why

Bookshelf was going to be built live in the iOS Advanced course. The students build their own app in the lecture anyway, so a second half-built app is pointless. Instead Bookshelf is finished once, up front, and handed to the students as a **small, readable reference of the architecture taught in the slides**.

Two readers: students (who read it) and their AI assistants (which get pointed at it and should reproduce the same structure in the student's own app). So the repo needs to be small enough to understand in one sitting, and it needs a `CLAUDE.md` that states the patterns and a recipe for adding a feature.

The architecture is the one used in Palino (`palino-ios`) and the Ahoi Kapptn apps: **Service (API) -> Repository -> ViewModel -> View**, plus **Managers** (singletons for cross-cutting concerns). Palino is the author's own project, so its code may be copied.

## Goals

- Show every layer once, end to end, with one realistic feature (search a book online, add it to the shelf, track reading progress).
- Same shapes as Palino: `enum XApi: BaseTargetType`, repository singletons with `static let shared`, ViewModel as `protocol` + `Impl` + `Preview`, previews that run without network or database.
- Show SwiftData as the local source of truth, the keychain for a secret, and a manager singleton.
- Ship a `CLAUDE.md` (adapted from Palino's / meimarie's) and a student-facing `README.md`.

## Non-goals and anti-goals

- No third-party dependencies (no Moya, Kingfisher, R.swift, Firebase). `AsyncImage` for covers.
- No Combine. Swift 6, iOS 26, async/await, `@Observable`.
- No auth, token refresh, multipart upload, localization tooling, analytics.
- No TipKit (dropped for now).
- No test target in v1 (the course adds tests in session 4). The protocol-based ViewModels must make tests easy later.
- No company-internal information anywhere (no Ahoi Kapptn or Palino hostnames, keys, process notes). Anti-goal: the project turning into a showcase of everything; every file must earn its place.

## Approaches considered

**Networking layer**
- A. Port Palino's Combine-based `NetworkingProvider` as is (about 400 lines after stripping auth/multipart). Identical to production, but teaches Combine and is long.
- B. **Chosen.** Same public shape (`NetworkTargetType`/`BaseTargetType`, `NetworkTask`, `CustomError`, per-feature `*Api` enum), rewritten on async/await, about 150 lines.

**Where SwiftData sits**
- `@Query` directly in views: nicest SwiftUI, but bypasses the ViewModel protocol, so previews would need a model container.
- **Chosen:** repository owns the `ModelContext`; ViewModels read from the repository. Preview ViewModels hold plain sample data.

## Architecture

```
View  ->  ViewModel (protocol, Impl, Preview)  ->  Repository (shared singleton, @Observable)
                                                      |-> SwiftData (ModelContext)      [BookRepository]
                                                      |-> NetworkingProvider<BookApi>   [BookSearchRepository]
Managers (shared singletons): KeyChain, RatingManager, NotificationPermissionManager
```

- **Service = Api.** Naming follows Palino: `Services/BookApi.swift` containing `enum BookApi: BaseTargetType` with `path`, `method`, `task`, `headers`. (Ahoi apps also call these `*Service`; the Api suffix is used here, the folder is `Services/`.)
- **Repositories** are `@MainActor @Observable` singletons. They call the Api, map DTOs to domain models at the repository boundary (`BookDto -> BookSearchResult`), and expose state.
- **ViewModels**: `protocol XViewModel: AnyObject, Observable`, `XViewModelImpl` (talks to repositories), `XViewModelPreview` (static sample data). Views take the protocol, so previews inject the Preview implementation. The exact view-side wiring follows Palino's `HomeView` / `HomeViewModel`.
- **Errors**: `CustomError` plus an `.errorHandler($error)` view modifier, as in Palino.

### Model
- `Book` becomes a SwiftData `@Model` class: title, author, pages, currentPage, status, coverURL, externalId, addedAt. Existing behavior (`progress`, `read(pages:)`, status derivation) stays. `ReadingStatus` becomes `Codable`.
- `BookSearchResult` is a plain struct produced by the mapper from `BookDto` (Google Books volume).

### API
Google Books Volumes API: `GET https://www.googleapis.com/books/v1/volumes?q=<query>&maxResults=20`. It works without a key (low quota); with a key the provider appends `&key=`. Covers come from `imageLinks.thumbnail` (upgrade `http` to `https`).

### Screens
1. **Shelf**: existing grid, sections by status.
2. **Add book**: search field and results (via `BookSearchRepository`); tap adds to the shelf. The existing manual form stays as "enter manually".
3. **Book detail**: progress and "+ pages" logging; finishing a book informs `RatingManager`.
4. **Settings**: reading-reminder toggle (`NotificationPermissionManager`, local notification) and an optional Google Books API key field (stored in `KeyChain`).

### Managers
- `KeyChain`: copied from Palino (`Keys` enum, `save`/`load`/`delete`), only the keys used here.
- `RatingManager`: singleton; counts finished books, requests an App Store review via SwiftUI `requestReview` after 3 finished books, never more than once per version.
- `NotificationPermissionManager`: copied from Palino, trimmed.

### Folder layout (inside `bookshelf/bookshelf/`)
```
App/ (MyApp, RootView)    Core/ (Networking, Error, Extensions)    Services/    Repositories/
Model/                    Features/ (Shelf, AddBook, BookDetail, Settings: View + ViewModel each)
Managers/                 UI/ (BookCard, ...)
```
Plus `CLAUDE.md` and `README.md` at the repo root.

## Constraints
- Xcode 26.6, iOS 26 deployment target, Swift 6, default MainActor isolation (as in the existing project).
- Must build and previews must render without network.
- Reference sources to port from: `palino-ios/Palino/Core/Networking`, `Core/Error`, `Utils/Keychain.swift`, `Utils/NotificationPermissionManager.swift`, `Data/Library/*`, `Features/BookDetail/BookDetailViewModel.swift`; CLAUDE.md style from `meimarie-ios/CLAUDE.md` and `palino-ios/CLAUDE.md`.

## Calls made by the author of this doc (not discussed with the user)
- Google Books instead of Open Library, because Open Library needs no key and the keychain would then protect nothing.
- Two repositories (`BookRepository` for SwiftData, `BookSearchRepository` for the API) so each repository owns exactly one data source.
- `@Observable` singletons instead of Palino's `ObservableObject`/`@Published`, because Combine is dropped.
- `RatingManager` uses `requestReview` instead of Ahoi's custom rating dialog.
- Settings screen exists mainly to host the two manager demos.
- Work happens on a new branch `reference-app`; the `docs/live-coding/*` and `docs/setup-guide.md` files are left as they are for now (they describe the old live-coding plan and will be stale).

## Decisions after review (user feedback while building)
- The user opted out of further questions ("just build it") and asked for **English and German** (String Catalog `Localizable.xcstrings`) and to keep it **not too complicated**.
- Simplifications applied: `NetworkTask` has three cases, no plugin protocol, no `ErrorResponse`; `CustomError` has four cases.
- The Google Books key is optional; the Keychain wrapper and the settings field stay as the one keychain example. They can be removed without touching the rest.
- The branch `reference-app` was cut from the working state of `session-1-demo-2` including its uncommitted edits. SwiftData changes reach the ViewModels through the observable `books` array of `BookRepository`, reloaded after every write.
- Palino sources live in `/Users/philippollmann/Repositories/Work/Palino/palino-ios`.

## Update: Figma design, notes, Open Library
- **Look:** follows the Figma design `Bookshelf (iOS Advanced)`: warm background, orange accent (`AccentColor`), gradient covers, Liquid Glass buttons, 4-point grid via `Spacer.height/width` and `.spacingN` (ported from the Ahoi starter template).
- **Flow:** both Library toolbar buttons open the Add Book sheet (magnifier opens it on the search). Tapping a search result fills the form, the check button saves.
- **Notes:** `Note` is a second SwiftData model (`Book.notes`, cascade delete). Notes are added in a sheet and deleted via context menu.
- **API changed from Google Books to Open Library:** Google Books without a key shares one anonymous daily quota that was already exhausted (HTTP 429), so it is unusable in a classroom. Open Library needs no key. Consequently the keychain wrapper and the API-key setting were removed (`KeyChain` is gone; `CLAUDE.md` still states the rule that secrets belong in the keychain).
- Skipped from the design: the "Continue" bar, the finish confetti (Rive), "finished this year" (we show total finished).

## Left to the builder
File-level details, exact view-to-ViewModel wiring (follow Palino), sample data, icons and styling, the wording of `CLAUDE.md` and `README.md`, build and preview verification.
