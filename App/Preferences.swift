import Cocoa

final class Preferences {
    static let shared = Preferences()

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Keys

    private enum Keys {
        static let labelCharacters = "label-characters"
        static let labelSize = "label-size"
        static let labelTheme = "label-theme"
        static let customLabelBackground = "custom-label-background"
        static let customLabelText = "custom-label-text"
        static let customLabelBorder = "custom-label-border"
        static let showMenuBarIcon = "show-menubar-icon"
        static let autoClickEnabled = "is-auto-click-enabled"
        static let hideLabelsWhenNothingSearched = "hide-labels-when-nothing-is-searched"
        static let hotkeyKeyCode = "hotkey-keycode"
        static let hotkeyModifiers = "hotkey-modifiers"
    }

    // MARK: - Notifications

    static let hotkeyDidChangeNotification = Notification.Name("PreferencesHotkeyDidChange")
    static let hotkeyRecordingDidStartNotification = Notification.Name("PreferencesHotkeyRecordingDidStart")
    static let hotkeyRecordingDidEndNotification = Notification.Name("PreferencesHotkeyRecordingDidEnd")

    // MARK: - Properties

    var labelCharacters: String {
        get { defaults.string(forKey: Keys.labelCharacters) ?? "ASDFGHJKLQWERTYUIOPZXCVBNM" }
        set { defaults.set(newValue, forKey: Keys.labelCharacters) }
    }

    /// Label size: "small", "medium", "large"
    var labelSize: String {
        get { defaults.string(forKey: Keys.labelSize) ?? "medium" }
        set { defaults.set(newValue, forKey: Keys.labelSize) }
    }

    var showMenuBarIcon: Bool {
        get { defaults.bool(forKey: Keys.showMenuBarIcon) }
        set { defaults.set(newValue, forKey: Keys.showMenuBarIcon) }
    }

    var autoClickEnabled: Bool {
        get { defaults.bool(forKey: Keys.autoClickEnabled) }
        set { defaults.set(newValue, forKey: Keys.autoClickEnabled) }
    }

    var hideLabelsWhenNothingSearched: Bool {
        get { defaults.bool(forKey: Keys.hideLabelsWhenNothingSearched) }
        set { defaults.set(newValue, forKey: Keys.hideLabelsWhenNothingSearched) }
    }

    // MARK: - Hotkey

    /// Whether a custom hotkey has been set
    var hasCustomHotkey: Bool {
        defaults.object(forKey: Keys.hotkeyKeyCode) != nil
    }

    /// The hotkey key code (default: Space = 49)
    var hotkeyKeyCode: UInt16 {
        get {
            if defaults.object(forKey: Keys.hotkeyKeyCode) != nil {
                return UInt16(defaults.integer(forKey: Keys.hotkeyKeyCode))
            }
            return 49 // kVK_Space
        }
        set {
            defaults.set(Int(newValue), forKey: Keys.hotkeyKeyCode)
            NotificationCenter.default.post(name: Self.hotkeyDidChangeNotification, object: nil)
        }
    }

    /// The hotkey modifiers (default: Cmd+Shift)
    var hotkeyModifiers: UInt {
        get {
            if defaults.object(forKey: Keys.hotkeyModifiers) != nil {
                return UInt(defaults.integer(forKey: Keys.hotkeyModifiers))
            }
            return 3 // command + shift
        }
        set {
            defaults.set(Int(newValue), forKey: Keys.hotkeyModifiers)
            NotificationCenter.default.post(name: Self.hotkeyDidChangeNotification, object: nil)
        }
    }

    /// Get the current hotkey configuration
    var hotKey: HotKey {
        HotKey(
            keyCode: hotkeyKeyCode,
            modifiers: HotKey.ModifierFlags(rawValue: hotkeyModifiers)
        )
    }

    /// Set both keyCode and modifiers at once (posts single notification)
    func setHotkey(keyCode: UInt16, modifiers: UInt) {
        defaults.set(Int(keyCode), forKey: Keys.hotkeyKeyCode)
        defaults.set(Int(modifiers), forKey: Keys.hotkeyModifiers)
        NotificationCenter.default.post(name: Self.hotkeyDidChangeNotification, object: nil)
    }

    /// Label theme: "dark", "light", "blue", "custom"
    var labelTheme: String {
        get { defaults.string(forKey: Keys.labelTheme) ?? "dark" }
        set { defaults.set(newValue, forKey: Keys.labelTheme) }
    }

    // MARK: - Custom Label Colors

    var customLabelBackground: NSColor {
        get { colorFromHex(defaults.string(forKey: Keys.customLabelBackground)) ?? NSColor(white: 0.2, alpha: 0.95) }
        set { defaults.set(newValue.toHex(), forKey: Keys.customLabelBackground) }
    }

    var customLabelText: NSColor {
        get { colorFromHex(defaults.string(forKey: Keys.customLabelText)) ?? .white }
        set { defaults.set(newValue.toHex(), forKey: Keys.customLabelText) }
    }

    var customLabelBorder: NSColor {
        get { colorFromHex(defaults.string(forKey: Keys.customLabelBorder)) ?? NSColor(white: 0.4, alpha: 1.0) }
        set { defaults.set(newValue.toHex(), forKey: Keys.customLabelBorder) }
    }

    // MARK: - Color Helpers

    private func colorFromHex(_ hex: String?) -> NSColor? {
        guard let hex = hex else { return nil }
        return NSColor.fromHex(hex)
    }
}

// MARK: - NSColor Hex Extension

extension NSColor {
    /// Create NSColor from hex string (e.g., "#FF5733" or "#FF5733FF")
    static func fromHex(_ hex: String) -> NSColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let length = hexSanitized.count
        let r, g, b, a: CGFloat

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF00_0000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF_0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000_FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x0000_00FF) / 255.0
        } else {
            return nil
        }

        return NSColor(red: r, green: g, blue: b, alpha: a)
    }

    /// Convert NSColor to hex string (e.g., "#FF5733FF")
    func toHex() -> String {
        guard let rgbColor = usingColorSpace(.sRGB) else {
            return "#000000FF"
        }

        let r = Int(round(rgbColor.redComponent * 255))
        let g = Int(round(rgbColor.greenComponent * 255))
        let b = Int(round(rgbColor.blueComponent * 255))
        let a = Int(round(rgbColor.alphaComponent * 255))

        return String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }
}
