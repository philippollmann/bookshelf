//
//  AccessibilityUITests.swift
//  bookshelfUITests
//

import XCTest

/// Runs Apple's automated accessibility audit (the same checks as the Accessibility Inspector)
/// on every screen, and checks the things the audit can't know, like what VoiceOver says.
///
/// The app starts with `-uiTesting`: an empty in-memory database, so every test starts clean.
/// Each test walks through the app like a user and audits the screen it ends on.
@MainActor
final class AccessibilityUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
    }

    // MARK: Screens, default text size

    func testEmptyShelf() throws {
        app.launch()

        XCTAssertTrue(app.staticTexts["Your shelf is empty"].waitForExistence(timeout: 5))
        try audit()
    }

    func testShelfWithBook() throws {
        app.launch()
        addBook()

        try audit()
    }

    func testAddBookForm() throws {
        app.launch()
        app.buttons["Add book"].firstMatch.tap()

        XCTAssertTrue(app.textFields["Title"].waitForExistence(timeout: 5))
        try audit()
    }

    func testBookDetail() throws {
        app.launch()
        addBook()
        openBook()

        try audit()
    }

    func testUpdateProgressSheet() throws {
        app.launch()
        addBook()
        openBook()
        app.buttons["Update progress"].tap()

        XCTAssertTrue(app.sliders["Page"].waitForExistence(timeout: 5))
        try audit()
    }

    func testAddNoteSheet() throws {
        app.launch()
        addBook()
        openBook()
        app.buttons["Add note"].tap()

        XCTAssertTrue(app.textViews["Note"].waitForExistence(timeout: 5))
        try audit()
    }

    // MARK: Largest text size

    /// The real Dynamic Type test: at the largest size labels get clipped and buttons overlap.
    func testShelfAndDetailWithLargestText() throws {
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        addBook()
        try audit(for: [.dynamicType, .textClipped, .hitRegion, .elementDetection])

        openBook()
        try audit(for: [.dynamicType, .textClipped, .hitRegion, .elementDetection])
    }

    // MARK: What VoiceOver says (the audit can't judge if a label makes sense)

    func testIconOnlyButtonsHaveLabels() throws {
        app.launch()

        XCTAssertTrue(app.buttons["Settings"].exists)
        XCTAssertTrue(app.buttons["Add book"].exists)

        addBook()
        openBook()
        app.buttons["Update progress"].tap()

        XCTAssertTrue(app.buttons["Previous page"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Next page"].exists)
    }

    func testProgressIsReadAsOneElement() throws {
        app.launch()
        addBook()
        openBook()

        let progress = app.otherElements["Progress"]
        XCTAssertTrue(progress.waitForExistence(timeout: 5))
        XCTAssertEqual(progress.value as? String, "0 percent, 0 of 320 pages")
    }

    func testSliderReadsPagesNotPercent() throws {
        app.launch()
        addBook()
        openBook()
        app.buttons["Update progress"].tap()

        let slider = app.sliders["Page"]
        XCTAssertTrue(slider.waitForExistence(timeout: 5))
        XCTAssertEqual(slider.value as? String, "0 of 320")

        app.buttons["Next page"].tap()
        XCTAssertEqual(slider.value as? String, "1 of 320")
    }

    // MARK: Helpers

    /// Audits the current screen. Pass fewer categories to check only some of them.
    private func audit(for types: XCUIAccessibilityAuditType = .all, file: StaticString = #filePath, line: UInt = #line) throws {
        try app.performAccessibilityAudit(for: types) { issue in
            // Return `true` to ignore a known issue that is not ours (e.g. a system view).
            // Everything else fails the test, with the element and a hint in the report.
            print("Accessibility issue: \(issue.compactDescription) on \(String(describing: issue.element))")
            return false
        }
    }

    /// Adds a book through the form, like a user would.
    private func addBook(title: String = "Dune", author: String = "Frank Herbert", pages: String = "320") {
        app.buttons["Add book"].firstMatch.tap()

        let titleField = app.textFields["Title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText(title)

        let authorField = app.textFields["Author"]
        authorField.tap()
        authorField.typeText(author)

        let pagesField = app.textFields["Pages"]
        pagesField.tap()
        pagesField.typeText(pages)

        // `Button(role: .confirm)` is the checkmark in the navigation bar
        app.navigationBars.buttons["Done"].tap()
        XCTAssertTrue(app.staticTexts[title].firstMatch.waitForExistence(timeout: 5))
    }

    private func openBook(title: String = "Dune") {
        app.buttons.containing(.staticText, identifier: title).firstMatch.tap()
        XCTAssertTrue(app.buttons["Update progress"].waitForExistence(timeout: 5))
    }
}
