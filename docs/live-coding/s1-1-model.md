# Live demo 1: modeling the shelf (tag `s1-1-model`)

**Session 1, after the Swift basics slides. About 25-30 min.**
Starts at `s1-0-start` (empty template). Ends at `s1-1-model`.

Goal: almost all the time goes into the **model**. The UI is only there to see that the model works: a list with progress bars, an Add button and a "Read 10 pages" button. Text input, the card and the grid come in demo 2.

Each step maps to one Swift basics slide. Type it, run or preview it, say the one sentence, move on. The full end state is at the bottom, to copy in if you get stuck.

---

## Step 1: the status as an enum (slide: Enums) ~4 min

New file `Book.swift`.

```swift
import Foundation

enum ReadingStatus: CaseIterable {
    case wantToRead
    case reading
    case finished
}
```

> Say: a book is in exactly one of three states. With a String, `"reading"` vs `"Reading"` would be a bug; the compiler can't check strings.

Add the display title as a **computed property** with `switch`:

```swift
    var title: String {
        switch self {
        case .wantToRead: "To read"
        case .reading: "Currently reading"
        case .finished: "Finished"
        }
    }
```

> Say: `switch` must be exhaustive. Add a 4th case live and show the error, then remove it. `CaseIterable` gives us `ReadingStatus.allCases`, which we use for the sections in demo 2.

## Step 2: the book as a struct, let vs var (slides: let/var, struct vs class) ~5 min

```swift
struct Book {
    let id = UUID()
    var title: String
    var author: String
    var pages: Int
    var currentPage = 0
    var status = ReadingStatus.wantToRead
}
```

> Say: `id` is `let` because it never changes; everything else can change. Type inference: `currentPage = 0` is an `Int`, no annotation needed. The defaults mean you only pass what matters: `Book(title:author:pages:)`, the memberwise initializer is free.

## Step 3: optionals (slide: Optionals) ~4 min

```swift
    var rating: Int?          // 1...5, nil = not rated yet
    var notes: [String] = []
```

> Say: "not rated yet" is a real state, so `nil` is honest. A rating of `0` would be a lie (and someone would compute an average with it).

(`summary` in step 6 shows `if let`.)

## Step 4: computed property for progress (slides: struct, properties) ~3 min

```swift
    var progress: Double {
        guard pages > 0 else { return 0 }
        return Double(currentPage) / Double(pages)
    }
```

> Say: progress is **computed, not stored**. If we stored it, it could disagree with `currentPage`. `guard` = early exit, here against dividing by zero. Note the explicit `Double(...)`: Swift never converts number types silently.

## Step 5: a mutating method, value semantics (slide: struct vs class) ~5 min

```swift
    mutating func read(pages count: Int) {
        currentPage = min(max(currentPage + count, 0), pages)

        if currentPage == pages {
            status = .finished
        } else if currentPage > 0 {
            status = .reading
        }
    }
```

> Say: the rules live in one place: the page is clamped to `0...pages`, and the last page makes the book finished. `mutating` because a struct method that changes the struct has to say so. Argument labels: `read(pages: 10)` reads like English; `count` is the name inside.

**Value semantics live** (optional, 1 min). Show it in `#Preview` or a temporary `let _ =` and delete it afterwards. Don't commit it:

```swift
var hobbit = Book(title: "The Hobbit", author: "J.R.R. Tolkien", pages: 320)
var copy = hobbit
copy.read(pages: 50)
print(hobbit.currentPage, copy.currentPage) // 0 50, a copy, not a shared object
```

> Say: with a class, both would print 50. This is why SwiftUI loves structs. (Session 2: SwiftData needs a class, and we'll talk about why.)

## Step 6: protocols and extensions (slide: Protocols and extensions) ~4 min

Make it `Identifiable` (SwiftUI's `List` and `ForEach` need it, and we already have `id`):

```swift
struct Book: Identifiable {
```

Add behaviour in an **extension**, plus `if let` for the optional:

```swift
extension Book {
    var summary: String {
        if let rating {
            "\(title) by \(author), \(rating) of 5"
        } else {
            "\(title) by \(author), not rated yet"
        }
    }
}
```

Sample data (same books as the Figma design, so screen 1 percentages match: Hobbit 8 %, Onyx Storm 34 %):

```swift
extension Book {
    static let samples: [Book] = [
        Book(title: "The Hobbit", author: "J.R.R. Tolkien", pages: 320, currentPage: 26, status: .reading),
        Book(title: "Onyx Storm", author: "Rebecca Yarros", pages: 544, currentPage: 185, status: .reading),
        Book(title: "Solaris", author: "Stanisław Lem", pages: 204),
        Book(title: "A Little Life", author: "Hanya Yanagihara", pages: 720),
        Book(title: "Dune", author: "Frank Herbert", pages: 412, currentPage: 412, status: .finished, rating: 5),
        Book(title: "Project Hail Mary", author: "Andy Weir", pages: 476, currentPage: 476, status: .finished, rating: 4),
    ]
}
```

> Tip: paste the samples rather than typing them. Nobody learns anything from watching you type six titles.

## Step 7: just enough UI to see it (teaser for part 2) ~5 min

Replace `ContentView.swift`:

```swift
import SwiftUI

struct ContentView: View {
    @State private var books = Book.samples

    var body: some View {
        NavigationStack {
            List {
                ForEach($books) { $book in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.title)
                            .font(.headline)
                        Text(book.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ProgressView(value: book.progress)
                            .tint(.orange)

                        HStack {
                            Text(book.status.title)
                            Spacer()
                            Text(book.progress, format: .percent.precision(.fractionLength(0)))
                                .monospacedDigit()
                        }
                        .font(.caption)

                        Button("Read 10 pages") {
                            book.read(pages: 10)
                        }
                        .buttonStyle(.bordered)
                        .disabled(book.status == .finished)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Library")
            .toolbar {
                Button("Add book", systemImage: "plus") {
                    books.append(Book(title: "New book \(books.count + 1)", author: "Unknown", pages: 200))
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
```

> Say: don't worry about `@State` and the `$` yet; that is exactly part 2. What matters now: tap "Read 10 pages" on The Hobbit, watch the bar and the percentage move, keep tapping on "New book 7" and watch the status go *To read → Currently reading → Finished*. **The UI has no logic; all the rules are in the model.**

`.buttonStyle(.bordered)` is not decoration: without it, a button inside a List row makes the whole row tappable.

## Wrap-up (1 min)

Commit, tag, push:

```bash
git add Bookshelf
git commit -m "Live demo 1: Book model with progress and reading status"
git tag s1-1-model
git push origin main --tags
```

Bridge to part 2: "Right now, every new book is called *New book 7*. Next: a real form to type a book in, sections by status, and a proper book card."

## Questions students usually ask

- *Why not `class Book`?* Value semantics (step 5). Session 2 comes back to it with SwiftData.
- *Why `Int?` and not `Int = 0`?* Step 3.
- *Why is `progress` not a `var` we set?* Step 4: derived data is never stored twice.
- *A book with 0 pages?* `progress` guards against it. Proper validation comes with the form in demo 2.
