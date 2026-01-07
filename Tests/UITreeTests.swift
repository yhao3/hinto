@testable import HintoCore
import XCTest

/// Tests for UITree - focusing on isClickable logic
final class UITreeTests: XCTestCase {
    // MARK: - Standard Clickable Roles

    func test_isClickable_givenButton_thenReturnsTrue() {
        // given
        let frame = CGRect(x: 100, y: 100, width: 80, height: 30)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result)
    }

    func test_isClickable_givenLink_thenReturnsTrue() {
        // given
        let frame = CGRect(x: 100, y: 100, width: 50, height: 20)

        // when
        let result = UITree.isClickable(role: "AXLink", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result)
    }

    func test_isClickable_givenCheckBox_thenReturnsTrue() {
        // given
        let frame = CGRect(x: 100, y: 100, width: 20, height: 20)

        // when
        let result = UITree.isClickable(role: "AXCheckBox", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result)
    }

    // MARK: - Disabled Elements

    func test_isClickable_givenDisabledButton_thenReturnsFalse() {
        // given
        let frame = CGRect(x: 100, y: 100, width: 80, height: 30)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: false)

        // then
        XCTAssertFalse(result)
    }

    // MARK: - iTerm2 Tabs (AXRadioButton at y < 60, isEnabled=false)

    func test_isClickable_givenITerm2Tab_disabledRadioButtonInTitleBar_thenReturnsTrue() {
        // given - iTerm2 tabs are AXRadioButton at y=25, and they report isEnabled=false
        let frame = CGRect(x: 200, y: 25, width: 100, height: 30)

        // when
        let result = UITree.isClickable(role: "AXRadioButton", frame: frame, isEnabled: false)

        // then
        XCTAssertTrue(result, "iTerm2 tabs (AXRadioButton at y < 60) should be clickable even when disabled")
    }

    func test_isClickable_givenRadioButtonAtY50_disabled_thenReturnsTrue() {
        // given - boundary check: y=50 is still < 60
        let frame = CGRect(x: 200, y: 50, width: 100, height: 30)

        // when
        let result = UITree.isClickable(role: "AXRadioButton", frame: frame, isEnabled: false)

        // then
        XCTAssertTrue(result)
    }

    func test_isClickable_givenRadioButtonAtY60_disabled_thenReturnsFalse() {
        // given - y=60 is NOT < 60, so disabled check applies
        let frame = CGRect(x: 200, y: 60, width: 100, height: 30)

        // when
        let result = UITree.isClickable(role: "AXRadioButton", frame: frame, isEnabled: false)

        // then
        XCTAssertFalse(result, "Disabled AXRadioButton at y >= 60 should not be clickable")
    }

    func test_isClickable_givenRadioButtonAtY100_enabled_thenReturnsTrue() {
        // given - enabled radio button elsewhere in window
        let frame = CGRect(x: 200, y: 100, width: 100, height: 30)

        // when
        let result = UITree.isClickable(role: "AXRadioButton", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result)
    }

    // MARK: - IntelliJ File Tabs (AXStaticText at y=55-90, width >= 50)

    func test_isClickable_givenIntelliJFileTab_thenReturnsTrue() {
        // given - IntelliJ file tabs are AXStaticText at y=55-90 with width >= 50
        let frame = CGRect(x: 300, y: 65, width: 80, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result, "IntelliJ file tabs (AXStaticText at y=55-90, width >= 50) should be clickable")
    }

    func test_isClickable_givenStaticTextAtY55_width50_thenReturnsTrue() {
        // given - boundary check: y=55 is valid
        let frame = CGRect(x: 300, y: 55, width: 50, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result)
    }

    func test_isClickable_givenStaticTextAtY90_width50_thenReturnsTrue() {
        // given - boundary check: y=90 is valid
        let frame = CGRect(x: 300, y: 90, width: 50, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result)
    }

    func test_isClickable_givenStaticTextAtY54_thenReturnsFalse() {
        // given - y=54 is below the 55-90 range (not a file tab)
        let frame = CGRect(x: 300, y: 54, width: 80, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "AXStaticText at y < 55 should not be clickable as file tab")
    }

    func test_isClickable_givenStaticTextAtY91_narrowWidth_thenReturnsFalse() {
        // given - y=91 is above file tab range, and width < 30 won't match session tab
        let frame = CGRect(x: 300, y: 91, width: 25, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result)
    }

    func test_isClickable_givenFileTabWithNarrowWidth_thenReturnsFalse() {
        // given - file tab position but width < 50
        let frame = CGRect(x: 300, y: 65, width: 40, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "File tabs need width >= 50")
    }

    // MARK: - IntelliJ Session Tabs (AXStaticText at y > 100, width 30-200)

    func test_isClickable_givenIntelliJSessionTab_thenReturnsTrue() {
        // given - Terminal session tabs like "Local", "Local (2)" in tool window
        let frame = CGRect(x: 400, y: 600, width: 60, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result, "Session tabs (AXStaticText at y > 100, width 30-200) should be clickable")
    }

    func test_isClickable_givenSessionTabAtY101_width30_thenReturnsTrue() {
        // given - boundary check: y=101 > 100, width=30 is valid
        let frame = CGRect(x: 400, y: 101, width: 30, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result)
    }

    func test_isClickable_givenSessionTabAtY100_thenReturnsFalse() {
        // given - y=100 is NOT > 100
        let frame = CGRect(x: 400, y: 100, width: 60, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Session tabs need y > 100")
    }

    func test_isClickable_givenSessionTabWidth200_thenReturnsTrue() {
        // given - boundary check: width=200 is valid
        let frame = CGRect(x: 400, y: 500, width: 200, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result)
    }

    func test_isClickable_givenSessionTabWidth201_thenReturnsFalse() {
        // given - width=201 exceeds 200 limit
        let frame = CGRect(x: 400, y: 500, width: 201, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Session tabs need width <= 200")
    }

    func test_isClickable_givenSessionTabWidth29_thenReturnsFalse() {
        // given - width=29 is below 30 minimum
        let frame = CGRect(x: 400, y: 500, width: 29, height: 20)

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Session tabs need width >= 30")
    }

    // MARK: - Filter: Origin (0,0)

    func test_isClickable_givenElementAtOrigin_thenReturnsFalse() {
        // given - elements at (0,0) are likely hidden/placeholder
        let frame = CGRect(x: 0, y: 0, width: 100, height: 30)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Elements at origin (0,0) should be filtered out")
    }

    func test_isClickable_givenElementAtX0Y10_thenReturnsTrue() {
        // given - x=0 OR y=0, but not both
        let frame = CGRect(x: 0, y: 100, width: 100, height: 30)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result)
    }

    // MARK: - Filter: Too Large

    func test_isClickable_givenTooWideElement_thenReturnsFalse() {
        // given - width > 2000 likely a container
        let frame = CGRect(x: 100, y: 100, width: 2001, height: 30)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Elements wider than 2000px should be filtered out")
    }

    func test_isClickable_givenTooTallElement_thenReturnsFalse() {
        // given - height > 2000 likely a scroll view
        let frame = CGRect(x: 100, y: 100, width: 100, height: 2001)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Elements taller than 2000px should be filtered out")
    }

    // MARK: - Filter: Too Small

    func test_isClickable_givenTooNarrowElement_thenReturnsFalse() {
        // given - width < 10 likely invisible
        let frame = CGRect(x: 100, y: 100, width: 9, height: 30)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Elements narrower than 10px should be filtered out")
    }

    func test_isClickable_givenTooShortElement_thenReturnsFalse() {
        // given - height < 10 likely decorative
        let frame = CGRect(x: 100, y: 100, width: 100, height: 9)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Elements shorter than 10px should be filtered out")
    }

    // MARK: - Filter: Top Edge (y < 20) for non-menu items

    func test_isClickable_givenButtonAtY15_thenReturnsFalse() {
        // given - buttons near top are often close buttons
        let frame = CGRect(x: 100, y: 15, width: 30, height: 20)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Buttons at y < 20 should be filtered out")
    }

    func test_isClickable_givenMenuBarItemAtY10_thenReturnsTrue() {
        // given - menu bar items are allowed at top
        let frame = CGRect(x: 100, y: 10, width: 50, height: 22)

        // when
        let result = UITree.isClickable(role: "AXMenuBarItem", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result, "Menu bar items should be clickable even at y < 20")
    }

    // MARK: - Filter: Negative Y (off-screen)

    func test_isClickable_givenNegativeY_thenReturnsFalse() {
        // given - y < -100 is off-screen
        let frame = CGRect(x: 100, y: -150, width: 100, height: 30)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Elements at y < -100 should be filtered out")
    }

    func test_isClickable_givenSlightlyNegativeY_thenReturnsTrue() {
        // given - y=-50 is within tolerance
        let frame = CGRect(x: 100, y: -50, width: 100, height: 30)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertTrue(result, "Elements at y >= -100 should be allowed")
    }

    // MARK: - Filter: Zero Size

    func test_isClickable_givenZeroWidth_thenReturnsFalse() {
        // given
        let frame = CGRect(x: 100, y: 100, width: 0, height: 30)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result)
    }

    func test_isClickable_givenZeroHeight_thenReturnsFalse() {
        // given
        let frame = CGRect(x: 100, y: 100, width: 100, height: 0)

        // when
        let result = UITree.isClickable(role: "AXButton", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result)
    }

    // MARK: - Non-Clickable Roles

    func test_isClickable_givenStaticTextNotInTabArea_thenReturnsFalse() {
        // given - random static text that's not a tab
        let frame = CGRect(x: 100, y: 200, width: 250, height: 20) // width > 200

        // when
        let result = UITree.isClickable(role: "AXStaticText", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "AXStaticText not matching tab criteria should not be clickable")
    }

    func test_isClickable_givenUnknownRole_thenReturnsFalse() {
        // given
        let frame = CGRect(x: 100, y: 100, width: 100, height: 30)

        // when
        let result = UITree.isClickable(role: "AXGroup", frame: frame, isEnabled: true)

        // then
        XCTAssertFalse(result, "Unknown roles like AXGroup should not be clickable")
    }
}
