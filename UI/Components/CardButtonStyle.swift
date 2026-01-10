import SwiftUI

/// Card-style button used throughout the app
/// Glassmorphism design: frosted glass, subtle border, light reflection, Z-depth
struct CardButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Design.Font.button)
            .foregroundColor(colorScheme == .dark ? .white : Color(white: 0.1))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    // Glassmorphism: frosted glass background
                    RoundedRectangle(cornerRadius: Design.CornerRadius.md)
                        .fill(Design.Glass.background(
                            colorScheme,
                            isHovering: isHovering,
                            isPressed: configuration.isPressed
                        ))

                    // Light reflection (top highlight)
                    RoundedRectangle(cornerRadius: Design.CornerRadius.md)
                        .fill(Design.Glass.reflectionGradient(colorScheme))
                }
            )
            // Glassmorphism: subtle border
            .overlay(
                RoundedRectangle(cornerRadius: Design.CornerRadius.md)
                    .stroke(Design.Glass.border(colorScheme, isHovering: isHovering), lineWidth: 1)
            )
            // Z-depth shadow
            .shadow(
                color: Design.Glass.shadowColor(colorScheme),
                radius: isHovering ? 6 : 4,
                x: 0,
                y: isHovering ? 3 : 2
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(Design.Animation.quick, value: configuration.isPressed)
            .animation(Design.Animation.quick, value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

extension ButtonStyle where Self == CardButtonStyle {
    static var hintoCard: CardButtonStyle { CardButtonStyle() }
}

// MARK: - Checkbox Toggle Style (Glassmorphism)

/// Custom checkbox style with glassmorphism design
/// Frosted glass, subtle border, light reflection, Z-depth
struct HintoCheckboxStyle: ToggleStyle {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovering = false

    private let boxSize: CGFloat = 18
    private let cornerRadius: CGFloat = 5

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Design.Spacing.sm) {
            // Checkbox box with Glassmorphism
            ZStack {
                // Glassmorphism: frosted glass background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(configuration.isOn ? Design.Colors.accent : Design.Glass.background(colorScheme))
                    .frame(width: boxSize, height: boxSize)

                // Light reflection for unchecked state
                if !configuration.isOn {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Design.Glass.reflectionGradient(colorScheme))
                        .frame(width: boxSize, height: boxSize)
                }

                // Glassmorphism: subtle border
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor(isOn: configuration.isOn), lineWidth: 1)
                    .frame(width: boxSize, height: boxSize)

                // Checkmark
                if configuration.isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            // Z-depth shadow
            .shadow(
                color: configuration.isOn
                    ? Design.Colors.accent.opacity(0.3)
                    : Design.Glass.shadowColor(colorScheme),
                radius: configuration.isOn ? 4 : 2,
                x: 0,
                y: 1
            )
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isOn)
            .animation(Design.Animation.quick, value: isHovering)

            // Label
            configuration.label
                .font(Design.Font.body)
                .foregroundColor(colorScheme == .dark ? .white : Color(white: 0.1))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            configuration.isOn.toggle()
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }

    // Glassmorphism: subtle border
    private func borderColor(isOn: Bool) -> Color {
        if isOn {
            return Design.Colors.accent
        }
        if isHovering {
            return Design.Colors.accent.opacity(0.8)
        }
        return Design.Glass.border(colorScheme)
    }
}

extension ToggleStyle where Self == HintoCheckboxStyle {
    static var hintoCheckbox: HintoCheckboxStyle { HintoCheckboxStyle() }
}
