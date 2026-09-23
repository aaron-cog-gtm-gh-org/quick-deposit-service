import SwiftUI

/// Signed-in home, restyled after the RBC Mobile reference: a layered blue
/// gradient hero with greeting and search, a horizontal strip of action tiles,
/// and a flat hairline-separated accounts list. All data is fictional.
struct DashboardView: View {
    var onSignOut: () -> Void

    @State private var showDeposit = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HeroHeader(onSignOut: onSignOut)

                ActionStrip(onDeposit: { showDeposit = true })

                AccountsOverview()

                RecentActivity()
            }
            .padding(.bottom, 20)
        }
        .background(RBC.surface)
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showDeposit) {
            DepositFlowView()
        }
    }
}

/// Layered blue gradient hero: translucent curved shapes, greeting, search
/// capsule, and a help affordance — drawn entirely with SwiftUI shapes.
private struct HeroHeader: View {
    var onSignOut: () -> Void

    var body: some View {
        LinearGradient(
            colors: [RBC.headerTop, RBC.headerMid, RBC.headerDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            ZStack {
                Ellipse()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 340, height: 340)
                    .offset(x: 190, y: -170)
                Ellipse()
                    .stroke(Color.white.opacity(0.10), lineWidth: 28)
                    .frame(width: 300, height: 300)
                    .offset(x: 230, y: -140)
                Ellipse()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 260, height: 160)
                    .offset(x: -80, y: 110)
                Ellipse()
                    .stroke(Color.white.opacity(0.07), lineWidth: 18)
                    .frame(width: 240, height: 240)
                    .offset(x: -110, y: -120)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button("Sign out", action: onSignOut)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.85))
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.white)
                }
                .padding(.top, 54)

                Text("Good Morning")
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(.white)
                    .padding(.top, 18)

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13, weight: .medium))
                    Text("Search RBC Mobile")
                        .font(.system(size: 14))
                    Spacer()
                }
                .foregroundStyle(Color.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Capsule().fill(Color.white.opacity(0.18))
                )
                .padding(.bottom, 18)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 226)
    }
}

/// Horizontally scrolling strip of compact action tiles with blue line icons.
/// Only Deposit is wired; the rest are cosmetic, matching the reference.
private struct ActionStrip: View {
    var onDeposit: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                tile("Deposit", "checkmark.square", onDeposit)
                tile("Send", "paperplane", nil)
                tile("Transfer", "arrow.left.arrow.right", nil)
                tile("Pay bills", "doc.plaintext", nil)
            }
            .padding(.horizontal, 20)
        }
    }

    /// A compact white tile ~128x94pt: blue line icon above its label,
    /// matching the reference's distinct action cards.
    private func tile(_ label: String, _ icon: String, _ action: (() -> Void)?) -> some View {
        Button(action: { action?() }) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(RBC.blue)
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(RBC.ink)
            }
            .frame(width: 128, height: 94)
            .background(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .stroke(RBC.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Flat full-width account rows separated by hairlines, under a compact
/// "Accounts Overview" heading with a trailing ellipsis.
private struct AccountsOverview: View {
    /// Display rows: the two fictional demo accounts plus a static Credit Line
    /// row for texture (also fictional).
    private var rows: [(String, String)] {
        DemoProfile.accounts.map {
            ("\($0.kind) (\($0.lastFour))", $0.balance.currencyString)
        } + [("Credit Line (0001)", Decimal(52853.77).currencyString)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Accounts Overview")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(RBC.ink)
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.system(size: 13))
                    .foregroundStyle(RBC.muted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 {
                    Divider().overlay(RBC.line).padding(.leading, 16)
                }
                HStack(spacing: 10) {
                    Text(row.0)
                        .font(.system(size: 15))
                        .foregroundStyle(RBC.ink)
                    Spacer()
                    Text(row.1)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(RBC.ink)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(RBC.muted.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
            }
        }
        .background(Color.white)
        .overlay(alignment: .top) {
            Rectangle().fill(RBC.line).frame(height: 0.5)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(RBC.line).frame(height: 0.5)
        }
    }
}

/// Static recent-activity list in the same flat style.
private struct RecentActivity: View {
    private let rows: [(String, String, String)] = [
        ("Interac e-Transfer", "Today", "-$40.00"),
        ("Payroll deposit", "Sep 19", "+$2,140.18"),
        ("Hydro bill", "Sep 17", "-$96.42"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent activity")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(RBC.ink)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 {
                    Divider().overlay(RBC.line).padding(.leading, 16)
                }
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.0)
                            .font(.system(size: 14))
                            .foregroundStyle(RBC.ink)
                        Text(row.1)
                            .font(.system(size: 12))
                            .foregroundStyle(RBC.muted)
                    }
                    Spacer()
                    Text(row.2)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(row.2.hasPrefix("+") ? RBC.success : RBC.ink)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
            }
        }
        .background(Color.white)
        .overlay(alignment: .top) {
            Rectangle().fill(RBC.line).frame(height: 0.5)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(RBC.line).frame(height: 0.5)
        }
    }
}
