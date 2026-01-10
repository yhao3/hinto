import SwiftUI

/// Unified design constants for consistent UI across the app
enum Design {
    // MARK: - Corner Radius

    enum CornerRadius {
        /// Extra small: 4px - for small badges, tags
        static let xs: CGFloat = 4
        /// Small: 6px - for key badges, small inputs
        static let sm: CGFloat = 6
        /// Medium: 8px - for buttons, cards
        static let md: CGFloat = 8
        /// Large: 10px - for larger cards, sections
        static let lg: CGFloat = 10
        /// Extra large: 12px - for windows, modals
        static let xl: CGFloat = 12
    }

    // MARK: - Spacing

    enum Spacing {
        /// 4px
        static let xs: CGFloat = 4
        /// 8px
        static let sm: CGFloat = 8
        /// 12px
        static let md: CGFloat = 12
        /// 16px
        static let lg: CGFloat = 16
        /// 20px
        static let xl: CGFloat = 20
        /// 24px
        static let xxl: CGFloat = 24
        /// 28px
        static let xxxl: CGFloat = 28
        /// 32px
        static let huge: CGFloat = 32
    }

    // MARK: - Animation

    enum Animation {
        /// Quick interaction feedback: 0.15s
        static let quick: SwiftUI.Animation = .easeOut(duration: 0.15)
        /// Standard transition: 0.2s
        static let standard: SwiftUI.Animation = .easeInOut(duration: 0.2)
    }

    // MARK: - Shadow

    enum Shadow {
        /// Subtle shadow for buttons
        static func button(_ colorScheme: ColorScheme) -> some View {
            Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1)
        }

        /// Button shadow radius
        static let buttonRadius: CGFloat = 2
        /// Button shadow offset
        static let buttonY: CGFloat = 1
    }

    // MARK: - Font

    enum Font {
        /// Title: 17pt semibold
        static let title: SwiftUI.Font = .system(size: 17, weight: .semibold)
        /// Body: 13pt regular
        static let body: SwiftUI.Font = .system(size: 13, weight: .regular)
        /// Button: 12pt medium
        static let button: SwiftUI.Font = .system(size: 12, weight: .medium)
        /// Caption: 11pt regular
        static let caption: SwiftUI.Font = .system(size: 11, weight: .regular)
        /// Small caption: 10pt
        static let small: SwiftUI.Font = .system(size: 10, weight: .regular)
    }

    // MARK: - Icon Size

    enum IconSize {
        /// Small: 16px
        static let sm: CGFloat = 16
        /// Medium: 20px
        static let md: CGFloat = 20
        /// Large: 56px - for app icon in headers
        static let lg: CGFloat = 56
        /// Extra large: 80px - for about view
        static let xl: CGFloat = 80
    }

    // MARK: - Colors

    enum Colors {
        /// Primary accent color (#047aff)
        static let accent = Color(red: 0.016, green: 0.478, blue: 1.0)
        /// Selected state background
        static let selectedBackground = accent
        /// Selected state shadow
        static func selectedShadow(_ opacity: Double = 0.35) -> Color {
            accent.opacity(opacity)
        }
    }

    // MARK: - Glassmorphism Colors

    /// Unified glassmorphism color system for consistent UI
    enum Glass {
        // MARK: - Background Opacity

        /// Glass background for dark mode
        enum Dark {
            /// Default state: very subtle glass
            static let bgDefault: Double = 0.08
            /// Hover state: slightly more visible
            static let bgHover: Double = 0.12
            /// Pressed state
            static let bgPressed: Double = 0.15
            /// Light reflection on top
            static let reflection: Double = 0.08
            /// Border default
            static let borderDefault: Double = 0.15
            /// Border hover
            static let borderHover: Double = 0.25
            /// Border selected/active
            static let borderActive: Double = 0.3
            /// Shadow opacity
            static let shadow: Double = 0.3
        }

        /// Glass background for light mode
        enum Light {
            /// Default state: frosted glass
            static let bgDefault: Double = 0.7
            /// Hover state: more opaque
            static let bgHover: Double = 0.85
            /// Pressed state
            static let bgPressed: Double = 0.9
            /// Light reflection on top
            static let reflection: Double = 0.5
            /// Border default
            static let borderDefault: Double = 0.1
            /// Border hover
            static let borderHover: Double = 0.15
            /// Border selected/active (uses accent color)
            static let borderActive: Double = 0.5
            /// Shadow opacity
            static let shadow: Double = 0.08
        }

        // MARK: - Helper Methods

        /// Get background opacity for default state
        static func bgDefault(_ scheme: ColorScheme) -> Double {
            scheme == .dark ? Dark.bgDefault : Light.bgDefault
        }

        /// Get background opacity for hover state
        static func bgHover(_ scheme: ColorScheme) -> Double {
            scheme == .dark ? Dark.bgHover : Light.bgHover
        }

        /// Get background opacity for pressed state
        static func bgPressed(_ scheme: ColorScheme) -> Double {
            scheme == .dark ? Dark.bgPressed : Light.bgPressed
        }

        /// Get reflection opacity
        static func reflection(_ scheme: ColorScheme) -> Double {
            scheme == .dark ? Dark.reflection : Light.reflection
        }

        /// Get border opacity for default state
        static func borderDefault(_ scheme: ColorScheme) -> Double {
            scheme == .dark ? Dark.borderDefault : Light.borderDefault
        }

        /// Get border opacity for hover state
        static func borderHover(_ scheme: ColorScheme) -> Double {
            scheme == .dark ? Dark.borderHover : Light.borderHover
        }

        /// Get shadow opacity
        static func shadow(_ scheme: ColorScheme) -> Double {
            scheme == .dark ? Dark.shadow : Light.shadow
        }

        /// Get glass background color
        static func background(_ scheme: ColorScheme, isHovering: Bool = false, isPressed: Bool = false) -> Color {
            let opacity: Double
            if isPressed {
                opacity = bgPressed(scheme)
            } else if isHovering {
                opacity = bgHover(scheme)
            } else {
                opacity = bgDefault(scheme)
            }
            return Color.white.opacity(opacity)
        }

        /// Get border color (default uses white for dark, black for light)
        static func border(_ scheme: ColorScheme, isHovering: Bool = false) -> Color {
            let opacity = isHovering ? borderHover(scheme) : borderDefault(scheme)
            return scheme == .dark
                ? Color.white.opacity(opacity)
                : Color.black.opacity(opacity)
        }

        /// Get shadow color
        static func shadowColor(_ scheme: ColorScheme) -> Color {
            Color.black.opacity(shadow(scheme))
        }

        /// Get light reflection gradient
        static func reflectionGradient(_ scheme: ColorScheme) -> LinearGradient {
            LinearGradient(
                colors: [
                    Color.white.opacity(reflection(scheme)),
                    Color.clear,
                ],
                startPoint: .top,
                endPoint: .center
            )
        }
    }
}
