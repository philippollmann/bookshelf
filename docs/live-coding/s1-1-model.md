# Live demo 1: modeling the shelf (tag `s1-1-model`)

**Session 1, after the Swift basics slides. About 25 min.**
Starts at `s1-0-start` (empty template). Ends at `s1-1-model`.

Goal: almost all the time goes into the **model**: a book, its reading status and its progress. The UI is only there to see the books: one line per book (title, author, percent) and an Add button. `read(pages:)` is shown in the temporary preview in step 4; in the UI it comes with the "+10" button in demo 2, together with text input, the book card and the grid. Rating and notes come later, with the detail screen.

Each step maps to one Swift basics slide. Type it, run or preview it, say the one sentence, move on. The full end state is the `s1-1-model` tag.

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

## Step 3: progress as a computed property (slide: struct, properties) ~4 min

```swift
    var progress: Double {
        guard pages > 0 else { return 0 }
        return Double(currentPage) / Double(pages)
    }
```

> Say: progress is **computed, not stored**. If we stored it, it could disagree with `currentPage`. `guard` = early exit, here against dividing by zero. Note the explicit `Double(...)`: Swift never converts number types silently.

## Step 4: a mutating method, value semantics (slide: struct vs class) ~6 min

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

**Value semantics live** (optional, 1 min). Show it in a temporary `#Preview` or `let _ =` and delete it afterwards. Don't commit it:

```swift
var hobbit = Book(title: "The Hobbit", author: "J.R.R. Tolkien", pages: 320)
var copy = hobbit
copy.read(pages: 50)
print(hobbit.currentPage, copy.currentPage) // 0 50, a copy, not a shared object
```

> Say: with a class, both would print 50. This is why SwiftUI loves structs.

**Optionals slide:** the model has no optional yet, on purpose. The first real one is the rating ("not rated yet" = `nil`) when we build the detail screen. If you want one now, show it in the same temporary preview: `Book.samples.first(where: { $0.status == .reading })` returns a `Book?`, then unwrap it with `if let`.

## Step 5: protocols and extensions (slide: Protocols and extensions) ~3 min

Make it `Identifiable` (SwiftUI's `List` and `ForEach` need it, and we already have `id`):

```swift
struct Book: Identifiable {
```

Sample data in an **extension** (same books as the Figma design, so the percentages match screen 1: Hobbit 8 %, Onyx Storm 34 %):

```swift
extension Book {
    static let samples: [Book] = [
        Book(title: "The Hobbit", author: "J.R.R. Tolkien", pages: 320, currentPage: 26, status: .reading),
        Book(title: "Onyx Storm", author: "Rebecca Yarros", pages: 544, currentPage: 185, status: .reading),
        Book(title: "Solaris", author: "Stanisław Lem", pages: 204),
        Book(title: "A Little Life", author: "Hanya Yanagihara", pages: 720),
        Book(title: "Dune", author: "Frank Herbert", pages: 412, currentPage: 412, status: .finished),
        Book(title: "Project Hail Mary", author: "Andy Weir", pages: 476, currentPage: 476, status: .finished),
    ]
}
```

> Say: an extension adds things to a type without touching its definition; here it keeps the test data away from the model. `static` = belongs to the type, not to one book.
>
> Tip: paste the samples rather than typing them.

## Step 6: just enough UI to see it (teaser for part 2) ~4 min

Replace `ContentView.swift`:

```swift
import SwiftUI

struct ContentView: View {
    @State private var books = Book.samples

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(books) { book in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                Text(book.author)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(book.progress, format: .percent.precision(.fractionLength(0)))
                        }
                    }
                }
                .padding()
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

> Say: don't worry about `@State` yet; that is exactly part 2. What matters now: the list shows our model, the percentages come from the computed `progress`, and tapping + adds a book that starts at 0 % with the defaults from step 2.

Why `ScrollView` and not `List`: `List` gives you swipe to delete, separators and the grouped iOS look for free, but it is hard to style. Our design is cards and a cover grid (demo 2), so a `ScrollView` with a `VStack` is the better fit.

## Wrap-up (1 min)

Bridge to part 2: "Right now, every new book is called *New book 7*. Next: a real form to type a book in, sections by status, and a proper book card."

## Questions students usually ask

- *Why not `class Book`?* Value semantics (step 4).
- *Why is `progress` not a `var` we set?* Step 3: derived data is never stored twice.
- *A book with 0 pages?* `progress` guards against it. Proper validation comes with the form in demo 2.
