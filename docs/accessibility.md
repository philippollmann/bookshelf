# Accessibility in Bookshelf

Accessibility is part of building the app, not a feature you add at the end. Many developers skip it simply because nobody showed them where to look. This page is a map: what to think about, where Apple explains it, how to test it, and where you can see each technique in this repo.

Apple's own framing (Human Interface Guidelines, *Accessibility*): an accessible interface is **intuitive**, **perceivable** and **adaptable**. It covers vision, hearing, mobility, speech and cognitive needs. SwiftUI gives you a lot for free (standard controls come with labels, traits and Dynamic Type), so most of the work is for the things you build yourself.

## 1. Where to read (Apple first)

| What | Why read it |
| --- | --- |
| [Accessibility fundamentals (SwiftUI)](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals) | The entry point. Lists the modifiers by topic: creating elements (`accessibilityElement(children:)`, `accessibilityChildren`, `accessibilityRepresentation`), identifying (`accessibilityIdentifier`) and hiding (`accessibilityHidden`) elements. Links to the four topic pages: appearance, controls, descriptions, navigation. |
| [Creating accessible views](https://developer.apple.com/documentation/swiftui/creating-accessible-views) | Apple's sample code for the modifiers above. |
| [HIG: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) | The rules with numbers: text scales to at least 200 %, contrast 4.5:1 for small text and 3:1 for large or bold text, touch targets 44 × 44 pt, no information by color alone, respect Reduce Motion. |
| [Accessibility framework overview](https://developer.apple.com/documentation/accessibility) | Table of contents for everything else: Accessibility Inspector, assistive technologies (VoiceOver, Voice Control, Switch Control, Assistive Access), testing, and the WWDC challenges below. |
| [WWDC21: SwiftUI Accessibility: Beyond the basics (10119)](https://developer.apple.com/videos/play/wwdc2021/10119/) | Accessibility Preview in Xcode, custom controls with `accessibilityRepresentation`, `.combine` / `.contain` / `.ignore`, reading order with `accessibilitySortPriority`, rotors, `AccessibilityFocusState`. |
| [WWDC23: Perform accessibility audits for your app (10035)](https://developer.apple.com/videos/play/wwdc2023/10035/) | Automated audits in Accessibility Inspector and in UI tests. |
| [WWDC23: Build accessible apps with SwiftUI and UIKit (10036)](https://developer.apple.com/videos/play/wwdc2023/10036) | More SwiftUI techniques, listed on Apple's Accessibility overview page. |
| [WWDC20: VoiceOver efficiency with custom rotors (10116)](https://developer.apple.com/videos/play/wwdc2020/10116) | Rotors in depth. |
| [WWDC18: Deliver an exceptional accessibility experience (230)](https://developer.apple.com/videos/play/wwdc2018/230) | The "why" and the mental model, still valid. |
| WWDC challenges (listed on the Accessibility framework page): *VoiceOver Maze*, *Large Text Challenge* | Small playful projects to practice. |
| Community: [A Practical Guide to Accessibility in SwiftUI](https://medium.com/@netman.arauz/a-practical-guide-to-accessibility-in-swiftui-3881bf525fb7) | A good tour of the common modifiers with one-line examples. Two caveats, see the end of this page. |

## 2. What to think about for every screen

1. **Name, role, value.** Every element needs a *name* (label), a *role* (traits: button, header, selected...) and, if it changes, a *value*. Standard controls have all three. Icon-only buttons, custom drawings and composed views need your help.
2. **Don't repeat yourself.** If text next to an image says the same thing, hide the image. If a row is made of 3 texts and an icon, VoiceOver should read it as one sentence, not five stops.
3. **Order and grouping.** VoiceOver reads top-left to bottom-right unless you group (`.combine`, `.contain`) or sort. Headings (`.isHeader`) let people jump through a screen with the rotor.
4. **Text size.** People use text sizes up to ~3× bigger. Layouts must adapt (more lines, stack vertically, one column), not clip. Test with the largest sizes.
5. **Contrast and color.** Check contrast numbers, check dark mode and Increase Contrast. Never use color as the only carrier of meaning.
6. **Touch targets.** At least 44 × 44 pt (HIG default). Small text buttons need extra padding.
7. **Motion.** Respect Reduce Motion (`accessibilityReduceMotion`).
8. **Changes you can't see.** VoiceOver users don't see a list update or a sheet close. Post an announcement or move focus when something important happens.
9. **Alternatives to gestures and menus.** Offer a custom action where you use swipe, long press or a context menu.
10. **Localize the accessibility text too.** Labels, values and hints are shown and spoken in the user's language. Here they live in `Localizable.xcstrings` (English + German).

## 3. Where you can see it in this repo

| Technique | Where |
| --- | --- |
| One element per book: label + value, role from the link (`.ignore` + `accessibilityLabel` + `accessibilityValue`) | `UI/BookGridCard.swift` |
| Heading trait, combined heading "Currently reading, 2" | `Features/Shelf/ShelfView.swift` |
| Image trait; decorative views hidden (`accessibilityHidden`) | `UI/BookCover.swift`, `Features/BookDetail/BookDetailView.swift` |
| Value for a custom bar, one element for title + percent + pages | `UI/ProgressBar.swift`, `BookDetailView.progress(for:)` |
| Slider with a useful label, value ("26 of 320") and `step: 1`, so swiping changes one page | `Features/BookDetail/UpdateProgress/UpdateProgressView.swift` |
| Custom action instead of a context menu only (`accessibilityAction(named:)`) | `BookDetailView.notes(for:)` |
| Announcements (`AccessibilityNotification.Announcement`) after actions without a visible result | `BookDetailView.announce(_:)`, `Features/AddBook/SearchBook/SearchBookView.swift` |
| `.isSelected` trait for a pill picker; hidden duplicate caption for text fields | `Features/AddBook/AddBookView.swift` |
| Adaptive layout with `ViewThatFits`, `@Environment(\.dynamicTypeSize)`, `@ScaledMetric` | `BookDetailView`, `UpdateProgressView`, `AddBookView`, `ShelfView`, `UI/BookCover.swift` |
| Reduce Motion: one helper for all animations (`accessibilityReduceMotion`), plus `.contentTransition` switched off | `Core/Extensions/View+Motion.swift`, used in `UI/ProgressBar.swift` and `UpdateProgressView` |
| Contrast: darker orange and gray for text, high-contrast variant of the accent color | `Resources/Colors.xcassets` (`Text/AccentText`, `Text/SecondaryText`, `AccentColor`) |
| Skeleton hidden from VoiceOver, announced once as "Loading" | `Core/Extensions/View+Redacted.swift` |
| 44 pt touch targets | `BookDetailView` ("Add note"), `SearchBookView` (clear button), `UpdateProgressView` (quick add) |
| Accessibility previews (large text, dark mode, German) | bottom of `ShelfView`, `BookDetailView`, `AddBookView`, `SearchBookView`, `UpdateProgressView` |

## 4. How to test (from quick to thorough)

**1. Xcode Previews.** Every screen has an "Accessibility text size" preview that uses `.dynamicTypeSize(.accessibility3)`; `ShelfView` also has a dark mode + German preview (`.preferredColorScheme`, `.environment(\.locale, ...)`). Use previews to look at big text, dark mode, other languages and right-to-left quickly. WWDC21 (10119) also shows the **Accessibility Preview** in Xcode: it lists the elements of a preview in VoiceOver order with their labels and traits, which is the fastest way to see what a modifier changes. Where that button sits changes between Xcode versions, so look in the preview canvas controls.

**2. Simulator settings.** Switch settings while the app runs, from Xcode's debug bar (*Environment Overrides*) or from the terminal:

```bash
xcrun simctl ui booted content_size accessibility-extra-extra-extra-large   # largest text
xcrun simctl ui booted increase_contrast enabled
xcrun simctl ui booted appearance dark
xcrun simctl ui booted content_size large                                    # back to normal
```

**3. Accessibility Inspector** (*Xcode > Open Developer Tool > Accessibility Inspector*). Pick the simulator or device as target, then:
- *Inspection:* point at an element to see its label, value, traits and hint exactly as VoiceOver gets them.
- *Audit:* press **Run Audit** for the current screen (choose the checks in *Options*). It finds issues such as missing element descriptions, small hit regions, low contrast, clipped text and Dynamic Type problems. Click an issue to highlight the element. *File > Save Audit Report As...* exports an HTML report. An audit only sees what is on screen, so run it for every screen.
- *Settings:* toggles system accessibility settings (Increase Contrast, Reduce Motion, Dynamic Type, Bold Text, ...) on the target device.
- *Color Contrast Calculator:* **Window > Show Color Contrast Calculator** (⌥⌘C). This is how the orange in this app was checked.

**4. VoiceOver on a real device.** The only way to know how it really feels. Settings > Accessibility > VoiceOver, or set *Accessibility Shortcut* (Settings > Accessibility) to VoiceOver and triple-click the side button to toggle it. Basics: swipe right/left = next/previous element, double-tap = activate, three fingers = scroll, rotate two fingers (rotor) = headings, actions, containers. Close your eyes and try to add a book. (The Simulator's VoiceOver support is limited; use the Inspector there.)

**5. Other assistive technologies.** Turn on *Voice Control* ("Tap Add note", "Show numbers"), *Full Keyboard Access*, *Switch Control*, *Bold Text*, *Reduce Motion*, *Differentiate Without Color* and see if the app still works.

**6. Automated audit in a UI test.** Not set up in this repo (the course adds test targets later), but this is all it takes (Apple, WWDC23 10035):

```swift
func testAccessibility() throws {
    let app = XCUIApplication()
    app.launch()
    try app.performAccessibilityAudit()
}
```

You can pick audit types (`.contrast`, `.dynamicType`, `.hitRegion`, `.sufficientElementDescription`, `.textClipped`, `.trait`, ...) and ignore known issues in a closure (`return true` ignores one). It doesn't replace real VoiceOver testing.

### Reduce Motion

Some people get dizzy or sick from sliding, zooming and bouncing. They switch on **Reduce Motion** (Settings > Accessibility > Motion), and apps are expected to respect it. Apple's HIG (*Accessibility*, cognitive section) asks you to reduce automatic animations when it is on. In SwiftUI you read it with `@Environment(\.accessibilityReduceMotion)`. This app wraps that once in `animationRespectingReduceMotion(value:)`, so a new animation is one modifier. Rules of thumb: replace movement with a fade (or nothing), keep the information (a progress bar still changes, it just doesn't slide), and never use motion as the only feedback. This matters more as animations get easier to generate: every generated animation needs this check. Test it with the Accessibility Inspector *Settings* tab or the simulator's accessibility settings. A short community explanation: [Hacking with Swift: how to detect the Reduce Motion setting](https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-the-reduce-motion-accessibility-setting).

## 5. Known gaps: good exercises

- **Brand orange.** `#F88B02` on white is only 2.4:1. Text uses a darker orange (`accentText`, 4.8:1) and the accent color has a darker *Increase Contrast* variant, but the default prominent button (white on orange) is still below 4.5:1. That is a design decision to discuss. Which would you choose?
- **Cover text.** White title on the lighter cover gradients (amber, light blue) is about 2.8 to 3.5:1. VoiceOver is fine (the cover has a label), but sighted low-vision users depend on contrast.
- **Rotors, focus, representation.** Try a custom rotor for the shelf sections, move focus after "Add note" with `@AccessibilityFocusState`, or replace the page controls with one `accessibilityRepresentation { Stepper(...) }`. All three are in WWDC21 10119.
- **UI test audit.** Add a UI test target and the audit above.
- **Accessibility Nutrition Labels.** App Store Connect lets you declare which features your app supports (see Apple's HIG page for the link). Check which ones you could honestly claim.

## 6. Notes on the community article

- It says `.ignore` "hides children from accessibility". Apple (WWDC21 10119) describes `.ignore` as making the view *one element that ignores its children's own properties* (you then give it a label and value, as `BookGridCard` does). To hide something use `accessibilityHidden(true)`.
- Its `accessibilityCustomActions([AccessibilityAction(...)])` example is not SwiftUI API. In SwiftUI use `accessibilityAction(named:)`, as `BookDetailView` does.
- Everything else in its modifier tour (label, hint, value, traits, sort priority, adjustable action, custom content, input labels for Voice Control, focus) matches Apple's documentation.
