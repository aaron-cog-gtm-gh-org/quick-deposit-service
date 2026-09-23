import SwiftUI

/// The RBC "lion & globe"-style shield mark, drawn to match the gold-on-navy
/// treatment used across the demo (a stylised globe in a ring, not the real
/// trademarked lion — this is a demo asset).
struct BrandMark: View {
    var size: CGFloat = 30
    var stroke: Color = .white

    var body: some View {
        Canvas { ctx, canvasSize in
            let r = min(canvasSize.width, canvasSize.height)
            let c = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let ring = Path(ellipseIn: CGRect(
                x: c.x - r * 0.46, y: c.y - r * 0.46,
                width: r * 0.92, height: r * 0.92))
            ctx.stroke(ring, with: .color(stroke), lineWidth: r * 0.075)

            let meridian = Path(ellipseIn: CGRect(
                x: c.x - r * 0.19, y: c.y - r * 0.46,
                width: r * 0.38, height: r * 0.92))
            ctx.stroke(meridian, with: .color(stroke), lineWidth: r * 0.05)

            for dy in [-r * 0.18, 0, r * 0.18] {
                var line = Path()
                line.move(to: CGPoint(x: c.x - r * 0.46, y: c.y + dy))
                line.addLine(to: CGPoint(x: c.x + r * 0.46, y: c.y + dy))
                ctx.stroke(line, with: .color(stroke), lineWidth: r * 0.05)
            }
        }
        .frame(width: size, height: size)
    }
}

/// Blue gradient top bar with the RBC wordmark — the fixed chrome that
/// anchors every screen in the flow.
struct BrandBar: View {
    var trailing: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            BrandMark(size: 26)
            (Text("RBC ").fontWeight(.bold) + Text("QuickDeposit").fontWeight(.regular))
                .font(.system(size: 17))
                .foregroundStyle(.white)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.75))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(
            LinearGradient(
                colors: [RBC.headerMid, RBC.headerDeep],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.15)).frame(height: 0.5)
        }
    }
}

/// A small labelled row used on review/success detail lists.
struct DetailRow: View {
    let label: String
    let value: String
    var mono: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(RBC.muted)
            Spacer(minLength: 16)
            Text(value)
                .font(mono ? .system(size: 14, design: .monospaced) : .system(size: 15, weight: .medium))
                .foregroundStyle(RBC.ink)
                .multilineTextAlignment(.trailing)
        }
    }
}
