# Live demo 2: the shelf (tag `s1-2-shelf`)

**Session 1, after the SwiftUI basics and layout slides. About 40-50 min.**
Starts at `s1-1-model`. Ends at `s1-2-shelf`.

Goal: type in a new book, see the books in sections by status, as cover cards in a two-column grid (Figma screen 1). Tapping a cover reads 10 pages, so the books move between sections. Along the way the project gets folders.

If time runs short, step 5 (grid) can move to the start of session 2.

---

## Step 1: folders (slide: Xcode tour) ~3 min

In Xcode, create the groups `Models` and `Views`, move `Book.swift` into `Models` and `ContentView.swift` into `Views`. `MyApp.swift` stays at the top.

> Say: folders are for people, the compiler doesn't care. The project uses synchronized folders, so a file you drop into a folder in Finder shows up in Xcode.

## Step 2: a form with @State and bindings (slide: @State and bindings) ~10 min

In `ContentView`, add the state for the form next to `books`:

```swift
@State private var title = ""
@State private var author = ""
@State private var pagesText = ""
```

Inside the `VStack` in the `ScrollView`, before the books:

```swift
VStack(spacing: 8) {
    TextField("Title", text: $title)
    TextField("Author", text: $author)
    TextField("Pages", text: $pagesText)
        .keyboardType(.numberPad)

    Button("Add book", action: addBook)
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .frame(maxWidth: .infinity, alignment: .trailing)
}
.textFieldStyle(.roundedBorder)
```

And the function:

```swift
private func addBook() {
    guard let pages = Int(pagesText) else { return }

    books.append(Book(title: title, author: author, pages: pages))
    title = ""
    author = ""
    pagesText = ""
}
```

Delete the old toolbar `+` button: the form replaces it.

> Say: `@State` = this view owns the value; when it changes, SwiftUI redraws. `$title` is a **binding**: the text field doesn't get a copy, it gets read *and write* access to our state. Type something, and it's in `title`.
>
> `Int(pagesText)` returns an `Int?`: "abc" is not a number, so the result can be `nil`. That's the optional from the slides, for real. `guard let` unwraps it or leaves the function.

Run it, add a book, and show that it appears in the list.

## Step 3: only allow valid input (slide: computed properties, again) ~4 min

```swift
private var pages: Int? {
    Int(pagesText)
}

private var canAdd: Bool {
    !title.isEmpty && !author.isEmpty && (pages ?? 0) > 0
}
```

On the button: `.disabled(!canAdd)`. In `addBook`, `guard let pages else { return }` now uses the computed `pages`.

> Say: same rule as `progress` in demo 1: `canAdd` is derived from the state, never stored. `?? 0` is nil coalescing: "if there is no number, use 0". This is also what makes a book with 0 pages impossible.

Then pull the form out of `body` into its own property to keep `body` short:

```swift
private var addForm: some View {
    VStack(spacing: 8) { ... }   // the VStack from step 2
}
```

and in `body` just write `addForm`.

## Step 4: sections by status (slides: List and ForEach) ~8 min

First change the order of the cases in `ReadingStatus` so "Currently reading" comes first, like in Figma:

```swift
case reading
case wantToRead
case finished
```

> Say: `allCases` follows the order in which the cases are written.

Replace the old `ForEach(books)` with one section per status:

```swift
ForEach(ReadingStatus.allCases, id: \.self) { status in
    let booksWithStatus = books.filter { $0.status == status }

    if !booksWithStatus.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
            Text(status.title)
                .font(.title3.bold())

            ForEach(booksWithStatus) { book in
                // the HStack row from demo 1, for now
            }
        }
    }
}
```

> Say: we never store "the books that are being read" separately. The sections are computed from the one `books` array every time. One source of truth. `id: \.self` works because a simple enum is automatically `Hashable`.

## Step 5: BookCard and the grid (slides: layout, subviews, grids) ~12 min

New file `Views/BookCard.swift`. Build it up live: first only the `RoundedRectangle` with `.aspectRatio(2 / 3, contentMode: .fit)`, then the overlay with the title, then the percent below.

```swift
import SwiftUI

struct BookCard: View {
    let book: Book

    private let colors: [Color] = [.blue, .green, .indigo, .brown, .teal, .red, .orange, .purple]

    private var color: Color {
        let number = book.title.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return colors[number % colors.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.gradient)
                .aspectRatio(2 / 3, contentMode: .fit)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(book.title.uppercased())
                            .font(.headline)
                            .lineLimit(3)
                        Text(book.author.uppercased())
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .padding(10)
                }

            if book.status == .reading {
                Text(book.progress, format: .percent.precision(.fractionLength(0)))
                    .font(.caption.bold())
            }
        }
    }
}

#Preview {
    BookCard(book: Book.samples[0])
        .frame(width: 170)
        .padding()
}

#Preview("Long title, large text") {
    BookCard(book: Book(title: "The Hitchhiker's Guide to the Galaxy", author: "Douglas Adams", pages: 224, currentPage: 40, status: .reading))
        .frame(width: 170)
        .padding()
        .dynamicTypeSize(.accessibility2)
}
```

> Say (layout): the parent proposes a width (170 in the preview, half the screen in the grid), the rectangle takes the width and computes its height from the 2:3 ratio. The overlay doesn't change the size; it's drawn on top. Show the second preview: long title and large text, that's why there is a `lineLimit`.
>
> The colour is just "the same title always gets the same colour" until we have real covers from Open Library.

In `ContentView`, add the columns:

```swift
private let columns = [
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16),
]
```

and replace the inner `ForEach(booksWithStatus)` with the grid:

```swift
LazyVGrid(columns: columns, spacing: 16) {
    ForEach(booksWithStatus) { book in
        BookCard(book: book)
    }
}
```

Set the padding of the outer `VStack` to `.padding(.horizontal, 20)` and its spacing to `24`.

> Say: two flexible columns share the width; each gets half minus the spacing. *Lazy* = cards are only created when they scroll into view.

## Step 6: tap a cover to read 10 pages ~5 min

```swift
private func read(_ book: Book) {
    guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
    books[index].read(pages: 10)
}
```

Wrap the card in a button:

```swift
Button {
    read(book)
} label: {
    BookCard(book: book)
}
.buttonStyle(.plain)
```

> Say: `book` inside the `ForEach` is a **copy** (struct!), so changing it would change nothing. We find the book in the array by its `id` and change it there. Tap Solaris a few times: it moves from *To read* to *Currently reading*, and when it is finished, to *Finished*. All of that comes from the model rules in demo 1.
>
> Bridge to session 2: this function and `addBook` are logic sitting in a view. In session 2 they move into a view model, and the tap opens a detail view instead.

## Wrap-up

What we did: state and bindings, a validated form, sections derived from one array, a reusable card, a grid. The finished code is the tag `s1-2-shelf`; the compare link `s1-1-model...s1-2-shelf` shows exactly what changed.

## Questions students usually ask

- *Why `pagesText` as a String and not an Int?* A text field edits text. `TextField(value:format:)` exists, but it only updates the value when you press return, and the number pad has no return key.
- *Why `id: \.self` for the statuses but not for the books?* Books are `Identifiable`; the enum isn't, but its cases are unique and `Hashable`.
- *Why not `ForEach($books)`?* We need the books filtered per section; a binding into a filtered array doesn't work. Finding the index is the simple way for now; the view model in session 2 cleans it up.
