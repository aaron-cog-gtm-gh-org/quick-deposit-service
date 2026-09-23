import SwiftUI

/// RBC brand palette and shared type/spacing tokens for the demo app.
///
/// Restyled to the RBC Mobile reference: layered deep blues for the hero
/// header, a brighter action blue for icons and primary controls, white flat
/// surfaces on a very light cool-gray page, charcoal text, hairline
/// separators, and restrained 0–6pt radii.
enum RBC {
    /// Deep blues used by the sign-in/dashboard hero and navigation chrome.
    static let navy = Color(hex: 0x003168)
    static let headerTop = Color(hex: 0x1A72B4)
    static let headerMid = Color(hex: 0x0F5C9E)
    static let headerDeep = Color(hex: 0x06406F)
    static let chrome = Color(hex: 0x0D5694)

    /// Bright RBC blue for icons, links, and primary actions.
    static let blue = Color(hex: 0x005DAA)
    /// Kept for the demo mark; no longer a dominant CTA colour.
    static let gold = Color(hex: 0xFEDF01)

    static let ink = Color(hex: 0x1C2430)
    static let muted = Color(hex: 0x5B6673)
    static let surface = Color(hex: 0xF4F6F9)
    static let card = Color.white
    static let line = Color(hex: 0xE2E7EE)
    static let success = Color(hex: 0x1E874B)
    static let danger = Color(hex: 0xC81E1E)

    /// Modest radius used for flat surfaces and controls (0–6pt range).
    static let radius: CGFloat = 4
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

/// Solid RBC blue primary action — compact rectangle with white text.
struct RBCPrimaryButtonStyle: ButtonStyle {
    var enabled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundStyle(enabled ? Color.white : Color(hex: 0x9AA4B2))
            .background(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .fill(enabled ? RBC.blue : Color(hex: 0xE3E7EE))
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// Quiet secondary action — white surface with a blue outline and blue text.
struct RBCSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(RBC.blue)
            .background(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                            .stroke(RBC.blue, lineWidth: 1)
                    )
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// Flat white surface with a hairline border — used for content sections.
struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .fill(RBC.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .stroke(RBC.line, lineWidth: 0.5)
            )
    }
}

extension View {
    func rbcCard() -> some View { modifier(CardBackground()) }
}
