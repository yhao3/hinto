import SwiftUI

/// View displaying changelog for "What's New" popup
struct WhatsNewView: View {
    let entry: ChangelogEntry
    let isPostUpdate: Bool
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding(.top, 28)
                .padding(.bottom, 20)

            // Content
            ScrollView {
                Text(.init(entry.content))
                    .font(.system(size: 13, weight: .regular))
                    .lineSpacing(4)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 20)
            }
            .frame(maxHeight: .infinity)

            // Footer
            footer
                .padding(.top, 16)
                .padding(.bottom, 24)
        }
        .frame(width: 400, height: 460)
        .background {
            ZStack {
                // Base material (same as Settings)
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thickMaterial)

                // Subtle gradient overlay
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.15)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var gradientColors: [Color] {
        colorScheme == .dark
            ? [Color(red: 0.2, green: 0.35, blue: 0.45), Color(red: 0.15, green: 0.25, blue: 0.35)]
            : [Color(red: 0.5, green: 0.7, blue: 0.85), Color(red: 0.6, green: 0.75, blue: 0.8)]
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fit)
                .frame(width: 56, height: 56)

            Text("What's New")
                .font(.system(size: 17, weight: .semibold))

            Text("Version \(entry.version)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }

    private var footer: some View {
        Button(action: {
            if isPostUpdate {
                // Mark as seen only for post-update popup
                Preferences.shared.lastSeenVersion = Preferences.shared.currentVersion
            }
            onDismiss()
        }) {
            Text(isPostUpdate ? "Continue" : "Close")
                .frame(minWidth: 100)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

// MARK: - Window Controller

final class WhatsNewWindowController: NSWindowController {
    private var externalOnDismiss: (() -> Void)?

    convenience init(entry: ChangelogEntry, onDismiss: (() -> Void)? = nil) {
        let whatsNewView = WhatsNewView(entry: entry, isPostUpdate: true) {
            // Will be set after window is created
        }

        let hostingController = NSHostingController(rootView: whatsNewView)
        hostingController.sizingOptions = [.preferredContentSize]

        let window = NSWindow(contentViewController: hostingController)
        window.title = "What's New"
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.setContentSize(NSSize(width: 400, height: 460))
        window.center()

        self.init(window: window)
        externalOnDismiss = onDismiss

        // Update the view with proper dismiss handler (isPostUpdate: true for window controller)
        let updatedView = WhatsNewView(entry: entry, isPostUpdate: true) { [weak self] in
            self?.dismissWindow()
        }
        hostingController.rootView = updatedView
    }

    private func dismissWindow() {
        close()
        externalOnDismiss?()
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

#Preview("Post Update") {
    WhatsNewView(
        entry: ChangelogEntry(
            version: "0.1.0",
            date: "2026-01-01",
            content: """
            **Added**

            - Initial release
            - Keyboard-driven UI navigation with hint labels
            - Global hotkey activation (Cmd+Shift+Space)

            **Fixed**

            - Some bug fixes
            """
        ),
        isPostUpdate: true,
        onDismiss: {}
    )
}

#Preview("Manual") {
    WhatsNewView(
        entry: ChangelogEntry(
            version: "0.1.0",
            date: "2026-01-01",
            content: """
            **Added**

            - Initial release
            """
        ),
        isPostUpdate: false,
        onDismiss: {}
    )
}
