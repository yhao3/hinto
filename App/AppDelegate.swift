import Carbon
import Cocoa
import Sparkle
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var modeController: ModeController?
    private var eventTapManager: EventTapManager?
    private var settingsWindow: NSWindow?
    private var whatsNewWindowController: WhatsNewWindowController?

    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    func applicationDidFinishLaunching(_: Notification) {
        log("Hinto: Starting up...")
        setupStatusBarItem()
        log("Hinto: Status bar item created")
        checkAccessibilityPermission()
        setupEventTap()
        setupModeController()
        recordFirstLaunchVersion()
        log("Hinto: Ready! Press Cmd+Shift+Space to activate")
    }

    // MARK: - Sparkle

    var updater: SPUUpdater {
        updaterController.updater
    }

    // MARK: - What's New

    private func recordFirstLaunchVersion() {
        let prefs = Preferences.shared
        if prefs.isFirstLaunch {
            log("Hinto: First launch, recording version \(prefs.currentVersion)")
            prefs.lastSeenVersion = prefs.currentVersion
        }
    }

    func showWhatsNewWindow(onDismiss: (() -> Void)? = nil) {
        guard let entry = ChangelogParser.shared.currentVersionEntry() else {
            log("Hinto: No changelog entry found for version \(Preferences.shared.currentVersion)")
            onDismiss?()
            return
        }

        log("Hinto: Showing What's New window, entry version: \(entry.version), content length: \(entry.content.count)")
        NSApp.setActivationPolicy(.regular)
        whatsNewWindowController = WhatsNewWindowController(entry: entry, onDismiss: onDismiss)
        whatsNewWindowController?.showWindow(nil)
    }

    func applicationWillTerminate(_: Notification) {
        eventTapManager?.stop()
    }

    // MARK: - Setup

    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(named: "MenuBarIcon")
            button.image?.isTemplate = true
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Activate", action: #selector(activateMode), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Quit Hinto",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))

        statusItem?.menu = menu
    }

    private func checkAccessibilityPermission() {
        let trusted = AXIsProcessTrusted()
        log("Hinto: Accessibility permission = \(trusted)")

        if !trusted {
            log("Hinto: Requesting accessibility permission...")
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            _ = AXIsProcessTrustedWithOptions(options)
        }
    }

    private func setupEventTap() {
        eventTapManager = EventTapManager()
        eventTapManager?.hotKey = Preferences.shared.hotKey
        eventTapManager?.onHotKeyPressed = { [weak self] in
            log("Hinto: Hotkey pressed!")
            self?.modeController?.toggle()
        }
        eventTapManager?.start()
        log("Hinto: EventTap running = \(eventTapManager?.isRunning ?? false)")

        // Listen for hotkey changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hotkeyDidChange),
            name: Preferences.hotkeyDidChangeNotification,
            object: nil
        )

        // Listen for recording start/end to bypass hotkey detection
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hotkeyRecordingDidStart),
            name: Preferences.hotkeyRecordingDidStartNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hotkeyRecordingDidEnd),
            name: Preferences.hotkeyRecordingDidEndNotification,
            object: nil
        )
    }

    @objc private func hotkeyDidChange() {
        log("Hinto: Hotkey changed, updating...")
        eventTapManager?.hotKey = Preferences.shared.hotKey
        log("Hinto: New hotkey applied")
    }

    @objc private func hotkeyRecordingDidStart() {
        log("Hinto: Hotkey recording started, bypassing hotkey detection")
        eventTapManager?.bypassHotkey = true
    }

    @objc private func hotkeyRecordingDidEnd() {
        log("Hinto: Hotkey recording ended, resuming hotkey detection")
        eventTapManager?.bypassHotkey = false
    }

    private func setupModeController() {
        modeController = ModeController()
    }

    // MARK: - Actions

    @objc private func activateMode() {
        modeController?.activate()
    }

    @objc private func openSettings() {
        // For menu bar apps (LSUIElement), we need to set activation policy to regular
        // to show windows properly
        NSApp.setActivationPolicy(.regular)

        // Show What's New on first Settings open after update
        let prefs = Preferences.shared
        if prefs.isFirstLaunchAfterUpdate {
            log("Hinto: First Settings open after update, showing What's New")
            showWhatsNewWindow { [weak self] in
                self?.showSettingsWindow()
            }
            return
        }

        showSettingsWindow()
    }

    private func showSettingsWindow() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "Hinto Settings"
            window.styleMask = [.titled, .closable, .fullSizeContentView]
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isMovableByWindowBackground = true
            window.isOpaque = false
            window.backgroundColor = .clear
            window.center()
            window.isReleasedWhenClosed = false

            // When window closes, go back to accessory mode
            NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                // Delay to avoid issues during window close
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self?.settingsWindow?.isVisible != true {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
            }

            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
