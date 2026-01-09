import SwiftUI

/// View displaying changelog for "What's New" popup
struct WhatsNewView: View {
    let entry: ChangelogEntry
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding(.top, 24)
                .padding(.bottom, 16)

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(.init(entry.content))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
            }

            Divider()

            // Footer
            footer
                .padding(.vertical, 16)
        }
        .frame(width: 420, height: 480)
        .background(backgroundMaterial)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image("AboutIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)

            Text("What's New in Hinto")
                .font(.system(size: 18, weight: .semibold))

            if let date = entry.date {
                Text("Version \(entry.version) - \(date)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            } else {
                Text("Version \(entry.version)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var footer: some View {
        Button(action: {
            // Mark as seen only when user dismisses
            Preferences.shared.lastSeenVersion = Preferences.shared.currentVersion
            onDismiss()
        }) {
            Text("Continue")
                .frame(minWidth: 100)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private var backgroundMaterial: some View {
        Group {
            if colorScheme == .dark {
                Color(nsColor: .windowBackgroundColor)
            } else {
                Color(nsColor: .windowBackgroundColor)
            }
        }
    }
}

// MARK: - Window Controller

final class WhatsNewWindowController: NSWindowController {
    convenience init(entry: ChangelogEntry) {
        let whatsNewView = WhatsNewView(entry: entry) {
            // Will be set after window is created
        }

        let hostingController = NSHostingController(rootView: whatsNewView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "What's New"
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.center()

        self.init(window: window)

        // Update the view with proper dismiss handler
        let updatedView = WhatsNewView(entry: entry) { [weak self] in
            self?.close()
        }
        hostingController.rootView = updatedView
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

#Preview {
    WhatsNewView(
        entry: ChangelogEntry(
            version: "0.1.0",
            date: "2025-01-09",
            content: """
            ### Added
            - Initial release
            - Keyboard-driven UI navigation with hint labels
            - Global hotkey activation (Cmd+Shift+Space)

            ### Fixed
            - Some bug fixes
            """
        ),
        onDismiss: {}
    )
}
