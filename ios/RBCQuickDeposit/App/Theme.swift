import SwiftUI

/// RBC brand palette and shared type/spacing tokens for the demo app.
///
/// Colours mirror the web demo (navy #003168, RBC blue #005DAA, gold #FEDF01)
/// so the two surfaces read as the same product.
enum RBC {
    static let navy = Color(hex: 0x003168)
    static let blue = Color(hex: 0x005DAA)
    static let gold = Color(hex: 0xFEDF01)

    static let ink = Color(hex: 0x14181F)
    static let muted = Color(hex: 0x5B6673)
    static let surface = Color(hex: 0xF2F4F7)
    static let card = Color.white
    static let line = Color(hex: 0xD9DEE6)
    static let success = Color(hex: 0x1E874B)
    static let danger = Color(hex: 0xC81E1E)

    /// Corner radius used for cards and primary controls.
    static let radius: CGFloat = 16
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension Font {
    /// Balances and amounts read best in a rounded, tabular treatment.
    static func money(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// Gold, pill-shaped primary action used for the headline "Deposit" CTAs.
struct RBCPrimaryButtonStyle: ButtonStyle {
    var enabled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(enabled ? RBC.navy : Color(hex: 0x9AA4B2))
            .background(
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(enabled ? RBC.gold : Color(hex: 0xE3E7EE))
            )
            .opacity(configuration.isPressed ? 0.88 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Quiet secondary action (navy outline on white).
struct RBCSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(RBC.blue)
            .background(
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .stroke(RBC.line, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// White rounded surface used for account tiles and content sections.
struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .fill(RBC.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .stroke(RBC.line, lineWidth: 1)
            )
    }
}

extension View {
    func rbcCard() -> some View { modifier(CardBackground()) }
}
