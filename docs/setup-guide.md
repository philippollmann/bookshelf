# Bookshelf: setup guide and checkpoint plan

The in-class app for iOS Advanced. It is built **live** in front of the class, not as exercises. Students code along in their own project; the repo is a reference they can look at. Every live demo ends in a git tag, so anyone who gets lost can look up or copy the code of the last checkpoint.

## 1. Create the Xcode project (once, by you)

Xcode 27, File > New > Project > iOS > App.

| Field | Value |
| --- | --- |
| Product Name | `Bookshelf` |
| Organization Identifier | your reverse domain, e.g. `at.jku.iosadvanced` |
| Interface / Language | SwiftUI / Swift |
| Testing System | None for now (test targets come in session 4, adding them later is a teaching moment) |
| Storage | None (SwiftData is added by hand in session 2) |
| Location | this repo folder (`bookshelf/`). **Uncheck** "Create Git repository on my Mac" (the repo already exists). |

Xcode creates `bookshelf/bookshelf/bookshelf.xcodeproj` and the source folder `bookshelf/bookshelf/bookshelf/` (synchronized folder: new files in it show up in Xcode automatically). The app entry point is `MyApp.swift`.

Then in the target's **Build Settings**:

| Setting | Value | Why |
| --- | --- | --- |
| iOS Deployment Target | **26.0** | Liquid Glass exists, and students whose Mac only has an iOS 26 simulator can still run it |
| Swift Language Version | **Swift 6** | as planned: Swift 6 from day one |
| Default Actor Isolation | **MainActor** (Xcode default) | the same default the students' own new projects get; session 3 explains what it means and when to leave the main actor |
| Approachable Concurrency | Yes (Xcode default) | same reason |
| Supported Destinations (General tab) | **iPhone and iPad only**, remove Mac and Apple Vision | the course is iOS; otherwise iOS-only APIs like `.keyboardType` break the Mac build |

Run once on a simulator, then commit the empty template (it becomes `s1-0-start`, see below).

## 2. Repo and checkpoints

**One branch per session for review, `main` only gets reviewed work, one tag per live demo.**

1. Each session is prepared on its own branch: `session-1`, `session-2`, ...
2. On that branch, **one commit per live demo** (plus fix-up commits while you review).
3. You review it session by session (run it, practise the script, change what you want). Fix things directly on the branch; to fix a demo commit itself, `git commit --fixup <sha>` and `git rebase --autosquash main` keep one clean commit per demo.
4. When you are happy: merge into `main` **with a merge commit, not squash**, so the per-demo commits survive and can be tagged:

   ```bash
   git switch main
   git merge --no-ff session-1
   git tag s1-0-start <sha of "empty Xcode project">
   git tag s1-1-model <sha of "live demo 1">
   git push origin main --tags
   ```

5. The next session's branch starts from the updated `main`: `git switch -c session-2 main`.

Tag names: `s<session>-<demo>-<topic>`, which sorts correctly: `s1-0-start`, `s1-1-model`, `s1-2-shelf`, ... Optionally make each tag a GitHub Release, so students can download a zip.

**If you find a bug after a session is merged and tagged:** fix it in the next session's branch and say so in class. Moving tags is possible (students only read the repo), but the compare links would stop matching what you showed.

**What students do:** they code along in their **own** Xcode project on their own Mac. The repo is only a reference; they get the link and use it if they want to. No git skills needed:

- **See the code of a checkpoint:** on GitHub, switch the branch/tag dropdown to e.g. `s1-1-model` and open the file.
- **Fell behind:** copy the changed files from the tag into their own project (each demo touches only a few files), or download the zip of the GitHub Release for that tag and continue from there.
- **Compare with their own code:** GitHub's compare view, e.g. `.../compare/s1-0-start...s1-1-model`, shows exactly what one live demo changed. Put that link on the wrap-up slide of each demo.

## 3. Checkpoint map

Session length is about 3 h. The Bookshelf demos get roughly 60-80 min per session, project time the rest.

| Tag | Session | Live demo | Bookshelf afterwards | Status |
| --- | --- | --- | --- | --- |
| `s1-0-start` | 1 | none (empty Xcode template) | Hello World runs | done |
| `s1-1-model` | 1 | Demo 1: Swift basics, modeling the shelf | `Book` + `ReadingStatus`, sample data, a list with progress bars, Add button, "Read 10 pages" | done, script in `live-coding/s1-1-model.md` |
| `s1-2-shelf` | 1 | Demo 2: SwiftUI + layout | Text input for new books (`@State`, bindings), sections by status, `BookCard` with cover placeholder, 2-column grid, files split into Models/Views | to do |
| `s2-1-...` | 2 | MVVM: `@Observable` view model + repository | | to do, details still open |
| `s2-2-...` | 2 | Screens: detail view, Add Book + Update progress sheets | | to do |
| `s2-3-...` | 2 | Networking: Open Library search (Codable, async/await) | | to do |
| ... | 3-4 | SwiftData, concurrency, Claude Code, tests, accessibility, tools | | to do |
