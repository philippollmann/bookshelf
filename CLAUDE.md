# CLAUDE.md

Guidance for Claude Code (and other AI assistants) when working in this repository.

## What this is

Bookshelf is a small iOS reference app (SwiftUI, SwiftData, Swift 6, iOS 26). It exists to show **how a professional iOS app is structured**. When you build a feature in a student project, copy the structure you see here. Keep the app small: every file should teach one thing.

You track books you read, search for new ones online (Open Library API, no key needed), keep notes and log your reading progress.

## Commands

```bash
open bookshelf/bookshelf.xcodeproj

xcodebuild -project bookshelf/bookshelf.xcodeproj -scheme bookshelf \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

The source folder is a synchronized group: new files in `bookshelf/bookshelf/` show up in Xcode automatically, no project editing needed.

## Architecture

Data flows in one direction:

```
View -> ViewModel -> Repository -> Api (network) / SwiftData
```

The structure follows our other apps (Palino, Ahoi): one folder per feature with View and ViewModel, a `Data/` layer, a `Model/` split into `Manual`, `Extension` and `Placeholder`, and colors in an asset catalog.

| Layer | Folder | Job |
| --- | --- | --- |
| **Api** | `Data/<Source>/` | `enum BookApi: BaseTargetType`. Only describes endpoints (path, method, parameters). No state, no logic. Lives next to its repository. |
| **Repository** | `Data/<Source>/` | Singleton (`static let shared`). Owns one data source, holds state. `BookRepository` (`Data/Books/`) = SwiftData, `BookSearchRepository` (`Data/Search/`) = network. |
| **ViewModel** | `Features/<Feature>/` | All state and user actions of a screen. Talks to repositories and managers, never to the network or database directly. |
| **View** | `Features/<Feature>/` | SwiftUI only. Knows the ViewModel *protocol*, nothing else. |
| **Model** | `Model/` | `Manual/`: hand-written models (`Book` and `Note` are SwiftData `@Model`, `BookSearchResult` mirrors the JSON, no `Dto` suffix). `Extension/`: computed helpers (`X+Extension.swift`). `Placeholder/`: preview data, one `X+Placeholder.swift` per type. The same data fills the skeleton while loading. |
| **Core** | `Core/` | Networking, error handling, extensions. Feature-independent. |
| **UI** | `UI/` | Reusable views (`BookCover`, `StatusChip`, ...). |
| **Utils** | `Utils/` | `Configuration`, managers for cross-cutting concerns, all singletons (`RatingManager`, `NotificationPermissionManager`, `CoverImageManager` for picked and photographed covers). |
| **Resources** | `Resources/` | `Colors.xcassets`, `Assets.xcassets`, `Localizable.xcstrings`. |

### Features and ViewModels

- One folder per feature with `XView.swift` and `XViewModel.swift`. A screen that only one parent opens (a sheet, a pushed detail) lives **inside the parent's folder**: `AddBook/SearchBook/`, `BookDetail/AddNote/`, `BookDetail/UpdateProgress/`. It still gets its own View and ViewModel.
- **Every view with data has a ViewModel, and all its variables live there**: input text, selection, loading flags, which sheet is open (`var sheet: ShelfSheet?`). The view keeps only what comes from the system (`@Environment(\.dismiss)`, `dynamicTypeSize`, `reduceMotion`) and pure view mechanics (`@FocusState`, `@ScaledMetric`). A view without any data (a plain row, a label) needs no ViewModel.
- Helpers that every implementation shares (`canSave`, `fill(with:)`) go into a protocol extension, so `Impl` and `Preview` don't duplicate them.
- ViewModels with actions that can fail conform to `ErrorReporting` and wrap the throwing call in `attempt { try repository.delete(book) }`: it sets `error` and returns `false` on failure, so there is no hand-written `do/catch` per action.

### ViewModel pattern (the most important rule)

Every screen has three types in one `*ViewModel.swift` file, always protocol, `Impl` and `Preview`:

```swift
protocol ShelfViewModel: AnyObject, Observable { ... }   // what the view needs
@Observable final class ShelfViewModelImpl: ShelfViewModel { ... }      // real: uses repositories
@Observable final class ShelfViewModelPreview: ShelfViewModel { ... }   // fake: static data
```

The view is generic over the protocol, so previews run without network or database:

```swift
struct ShelfView<Model: ShelfViewModel>: View {
    @State var viewModel: Model
}
#Preview { ShelfView(viewModel: ShelfViewModelPreview()) }
// production: ShelfView(viewModel: ShelfViewModelImpl())
```

### Networking

`Api -> NetworkingProvider -> Repository`. A new endpoint:
1. Add a case to the `*Api` enum (`path`, `method`, `task`).
2. Add a `Decodable` model in `Model/Manual/` that mirrors the JSON (named after the thing, no `Dto` suffix) and put computed helpers in `Model/Extension/`. We skip a separate domain type and mapper on purpose to keep the app small; add one when the JSON and what the app needs drift apart.
3. Call `provider.request(.yourCase)` in a repository and return the decoded model.

### Errors

Repositories and the provider throw anything. ViewModels store it in `var error: Error?`. Views attach `.errorHandler($viewModel.error)`, which turns it into a `CustomError` (`Error.toCustomError()`) and shows an alert. Add new user-facing error cases to `CustomError`.

### Storage

- Books: SwiftData, only `BookRepository` touches the `ModelContext`. It reloads `books` after every change; ViewModels expose `repository.books`. We deliberately do **not** use `@Query` in views, so previews and tests don't need a database (`BookRepository(inMemory: true)` exists for tests).
- Secrets (API keys, tokens) belong into the keychain, never into `UserDefaults` or source code. This app needs none; the Open Library API is public.
- Simple flags: `@AppStorage`/`UserDefaults`, with the key defined in `Configuration`.

### Localization

English (source) and German via the String Catalog `Resources/Localizable.xcstrings`. Use literals in SwiftUI (`Text("Library")`) and `String(localized: "...")` elsewhere, `LocalizedStringResource` for enum titles. Add the German translation in the catalog for every new string.

## Design

The look follows the Figma design of the course (warm off-white background, orange accent, gradient book covers, glass buttons).

- **4-point grid:** every spacing and corner radius is a multiple of 4. Use the constants from `Core/Extensions/CGFloat+Extension.swift` (`.padding(.spacing16)`, `.cornerRadius8`) and `Spacer.height(.spacing8)` / `Spacer.width(...)` from `Spacer+Extension.swift`. No magic numbers.
- **Colors:** no hardcoded colors in views. Every theme color is a color set in `Resources/Colors.xcassets` (grouped `Background`, `Text`, `Status`, `Shadow`, plus `AccentColor`) with a light and a dark variant, used through the generated symbols: `Color.appBackground`, `Color.cardBackground`, `Color.accentText`, `Color.secondaryText` (use it instead of `.secondary`, which is too light), `Color.fieldBackground`, `Color.skeleton`, `.statusReadingBackground`. Shadows use `.cardShadow()`. The orange accent is `Color.accentColor` / `.tint`. A new color means a new color set, not `Color(red:...)`. Only the decorative cover gradients and art measures in `UI/BookCover.swift` stay in code. Sizes are constants in `CGFloat+Extension.swift` (`.maxCoverWidth`, `.heroGradientHeight`), not literals in views.
- **Buttons:** use the system Liquid Glass styles: `.buttonStyle(.glass)`, `.glassProminent`, and toolbar roles `Button(role: .close)` / `Button(role: .confirm)`. Don't draw your own.
- **Reusable UI** goes into `UI/` (`BookCover`, `BookGridCard`, `StatusChip`, `ProgressBar`), each with a `#Preview`.

## Loading, empty and error states

Every screen that shows loaded data has all three, built from what we already have:

- **Loading:** a skeleton. The ViewModel has `isLoading` and returns the fixtures (`Book.placeholders()`) meanwhile; the view applies `.redacted(when: viewModel.isLoading)` (`Core/Extensions/View+Redacted.swift`). Reusable views read `@Environment(\.isPlaceholder)` to draw gray blocks instead of art.
- **Empty:** a `ContentUnavailableView` that says what to do next, with an action button where there is one.
- **Error:** an alert via `.errorHandler` for actions. For a screen that could not load at all, a `ContentUnavailableView` with "Try again" (`ShelfView`: its `error` only comes from loading, so it has no alert). Destructive actions ask first (`confirmationDialog`).

## Accessibility

Accessibility is a requirement for every view, not an extra. Read `docs/accessibility.md` for the why, the tools and where each technique lives in this repo. For every new or changed view:

- **Name, role, value:** icon-only buttons and custom drawings get `accessibilityLabel` (and `accessibilityValue`, traits). Use `.isHeader` for headings, `.isSelected` for selected pills.
- **Group, hide, don't repeat:** one element per row/card (`accessibilityElement(children: .ignore)` + label/value, or `.combine`). Decorative images and captions that duplicate text get `accessibilityHidden(true)`.
- **Dynamic Type:** no fixed heights for text. Use system text styles, `@ScaledMetric` for sizes next to text, `ViewThatFits` or `dynamicTypeSize.isAccessibilitySize` to adapt layouts. Add a `#Preview("Accessibility text size")` with `.dynamicTypeSize(.accessibility3)`.
- **Touch targets:** at least 44 pt (`.minTapTarget`), as a `minHeight`, never a fixed height. **Contrast:** 4.5:1 for small text (use `Color.accentText`, not the brand orange, for orange text). Never use color alone.
- **Haptics:** `.hapticFeedback(on: value, type:)` (`Core/Extensions/View+Haptic.swift`, the same modifier as in Palino) plays when a ViewModel value changes: `.notification(.success)` for a saved result, `.selection` for ticks. Never the only signal.
- **Automated audit:** `bookshelfUITests/AccessibilityUITests.swift` runs `performAccessibilityAudit` on every screen and checks the VoiceOver labels. Add a test for each new screen. The app starts with `-uiTesting` (in-memory database).
- **Motion:** every animation goes through `animationRespectingReduceMotion(value:)` (`Core/Extensions/View+Motion.swift`), including animations an AI generates for you. **Actions:** if something is only reachable by long press or context menu, add `accessibilityAction(named:)`.
- **Changes VoiceOver can't see:** post `AccessibilityNotification.Announcement.post("Saved")` (`Core/Extensions/AccessibilityNotification+Extension.swift`) after results appear or an action completes, and only when it worked (ViewModel actions return `Bool`).
- **Status is never only a color:** put it into the accessibility value (`BookGridCard`), and give every `Slider` a `step` so VoiceOver changes one unit at a time.
- Accessibility strings are localized like any other string (en + de in `Localizable.xcstrings`). A skeleton is hidden from VoiceOver and announced as one "Loading".

## Conventions

- Swift 6, default main-actor isolation, `async/await`, `@Observable`. No Combine, no third-party packages.
- Naming: `XView`, `XViewModel`/`Impl`/`Preview`, `XRepository`, `XApi`, `XManager`. API models are named after the thing (`BookSearchResult`), without a `Dto` suffix. Preview data is `X.placeholder()` / `X.placeholders()` in `Model/Placeholder/X+Placeholder.swift`.
- Every View has a `#Preview` using the Preview ViewModel.
- Keep files small and comments short and useful: explain *why*, not *what*.

## Adding a feature (recipe)

1. `Features/<Name>/<Name>ViewModel.swift`: protocol, `Impl`, `Preview`. All state of the screen lives here.
2. `Features/<Name>/<Name>View.swift`: generic view plus preview. (A screen opened by only one parent goes into that parent's folder.)
3. New data? Extend or add a repository in `Data/` (and an `*Api` case if it comes from the network), plus a `Model/Placeholder/` file for previews.
4. Strings into `Localizable.xcstrings` (en + de), colors into `Colors.xcassets`.
5. Build, check the preview and the simulator.

## Don'ts

- No network or SwiftData calls in views or ViewModels.
- No `@State` for data in views: it belongs in the ViewModel.
- No hardcoded colors: use `Colors.xcassets`.
- No business logic in the `*Api` enums.
- No force unwraps on data that comes from outside (API, user input).
