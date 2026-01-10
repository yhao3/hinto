import XCTest

/// Tests for Sparkle auto-update configuration
/// Verifies Info.plist has correct Sparkle keys for secure auto-updates
final class SparkleConfigTests: XCTestCase {
    private var infoPlist: [String: Any]!

    override func setUp() {
        super.setUp()
        loadInfoPlist()
    }

    override func tearDown() {
        infoPlist = nil
        super.tearDown()
    }

    // MARK: - Feed URL Tests

    func test_feedURL_givenInfoPlist_thenIsProperlyConfigured() {
        givenInfoPlistLoaded()

        thenFeedURLExists()
        thenFeedURLIsValidURL()
        thenFeedURLUsesHTTPS()
        thenFeedURLPointsToAppcast()
    }

    // MARK: - Public Key Tests

    func test_publicKey_givenInfoPlist_thenIsProperlyConfigured() {
        givenInfoPlistLoaded()

        thenPublicKeyExists()
        thenPublicKeyIsBase64Encoded()
        thenPublicKeyIsNotPlaceholder()
    }

    // MARK: - Auto-Check Tests

    func test_autoCheck_givenInfoPlist_thenIsProperlyConfigured() {
        givenInfoPlistLoaded()

        thenAutoCheckIsEnabled()
        thenCheckIntervalIsDaily()
        thenCheckIntervalIsReasonable()
    }
}

// MARK: - Given

extension SparkleConfigTests {
    private func loadInfoPlist() {
        let plistPath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent() // Tests/
            .deletingLastPathComponent() // Hinto/
            .appendingPathComponent("Resources/Info.plist")

        guard let data = try? Data(contentsOf: plistPath),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            XCTFail("Failed to load Info.plist from \(plistPath.path)")
            return
        }
        infoPlist = plist
    }

    private func givenInfoPlistLoaded() {
        XCTAssertNotNil(infoPlist, "Info.plist must be loaded")
    }
}

// MARK: - Then (Feed URL)

extension SparkleConfigTests {
    private func thenFeedURLExists() {
        let feedURL = infoPlist["SUFeedURL"] as? String
        XCTAssertNotNil(feedURL, "SUFeedURL must be set in Info.plist")
    }

    private func thenFeedURLIsValidURL() {
        guard let feedURL = infoPlist["SUFeedURL"] as? String else {
            XCTFail("SUFeedURL not found")
            return
        }
        XCTAssertNotNil(URL(string: feedURL), "SUFeedURL must be a valid URL")
    }

    private func thenFeedURLUsesHTTPS() {
        guard let feedURL = infoPlist["SUFeedURL"] as? String else {
            XCTFail("SUFeedURL not found")
            return
        }
        XCTAssertTrue(feedURL.hasPrefix("https://"), "SUFeedURL must use HTTPS for security")
    }

    private func thenFeedURLPointsToAppcast() {
        guard let feedURL = infoPlist["SUFeedURL"] as? String else {
            XCTFail("SUFeedURL not found")
            return
        }
        XCTAssertTrue(feedURL.hasSuffix("appcast.xml"), "SUFeedURL should point to appcast.xml")
    }
}

// MARK: - Then (Public Key)

extension SparkleConfigTests {
    private func thenPublicKeyExists() {
        let publicKey = infoPlist["SUPublicEDKey"] as? String
        XCTAssertNotNil(publicKey, "SUPublicEDKey must be set for EdDSA signature verification")
    }

    private func thenPublicKeyIsBase64Encoded() {
        guard let publicKey = infoPlist["SUPublicEDKey"] as? String else {
            XCTFail("SUPublicEDKey not found")
            return
        }
        // EdDSA public key is 32 bytes = 44 chars in base64 (with padding)
        XCTAssertEqual(publicKey.count, 44, "EdDSA public key should be 44 characters in base64")
        XCTAssertTrue(publicKey.hasSuffix("="), "Base64 encoded key should have padding")
    }

    private func thenPublicKeyIsNotPlaceholder() {
        guard let publicKey = infoPlist["SUPublicEDKey"] as? String else {
            XCTFail("SUPublicEDKey not found")
            return
        }
        XCTAssertNotEqual(publicKey, "YOUR_ED25519_PUBLIC_KEY", "SUPublicEDKey must not be a placeholder")
        XCTAssertFalse(publicKey.isEmpty, "SUPublicEDKey must not be empty")
    }
}

// MARK: - Then (Auto-Check)

extension SparkleConfigTests {
    private func thenAutoCheckIsEnabled() {
        let autoCheck = infoPlist["SUEnableAutomaticChecks"] as? Bool
        XCTAssertEqual(autoCheck, true, "Automatic update checks should be enabled")
    }

    private func thenCheckIntervalIsDaily() {
        let interval = infoPlist["SUScheduledCheckInterval"] as? Int
        XCTAssertEqual(interval, 86400, "Check interval should be 24 hours (86400 seconds)")
    }

    private func thenCheckIntervalIsReasonable() {
        guard let interval = infoPlist["SUScheduledCheckInterval"] as? Int else {
            XCTFail("SUScheduledCheckInterval not found")
            return
        }
        // Should be at least 1 hour and at most 1 week
        XCTAssertGreaterThanOrEqual(interval, 3600, "Check interval should be at least 1 hour")
        XCTAssertLessThanOrEqual(interval, 604_800, "Check interval should be at most 1 week")
    }
}
