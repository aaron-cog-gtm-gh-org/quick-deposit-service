import SwiftUI

/// Signed-in home: account balances and the headline "Deposit a cheque" action.
struct DashboardView: View {
    var onSignOut: () -> Void

    @State private var showDeposit = false

    var body: some View {
        VStack(spacing: 0) {
            BrandBar(trailing: "Mobile Deposit")

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good afternoon,")
                            .font(.system(size: 15))
                            .foregroundStyle(RBC.muted)
                        Text(DemoProfile.holderName)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(RBC.ink)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 14) {
                        ForEach(DemoProfile.accounts) { account in
                            AccountTile(account: account)
                        }
                    }

                    depositCallout

                    RecentActivity()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(RBC.surface)
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showDeposit) {
            DepositFlowView()
        }
    }

    private var depositCallout: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(RBC.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Deposit a cheque")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(RBC.ink)
                    Text("Add the front and back — funds usually available next business day.")
                        .font(.system(size: 13))
                        .foregroundStyle(RBC.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Button("Deposit a cheque") { showDeposit = true }
                .buttonStyle(RBCPrimaryButtonStyle())
        }
        .padding(18)
        .rbcCard()
    }
}

/// A single account balance tile.
struct AccountTile: View {
    let account: Account

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(RBC.navy)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: account.kind == "Savings" ? "banknote" : "creditcard")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(RBC.gold)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(account.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(RBC.ink)
                Text("\(account.kind) \(account.displayNumber)")
                    .font(.system(size: 13))
                    .foregroundStyle(RBC.muted)
            }
            Spacer()
            Text(account.balance.currencyString)
                .font(.money(18))
                .foregroundStyle(RBC.ink)
        }
        .padding(16)
        .rbcCard()
    }
}

/// Static recent-activity list for demo texture.
struct RecentActivity: View {
    private let rows: [(String, String, String)] = [
        ("Interac e-Transfer", "Today", "-$40.00"),
        ("Payroll deposit", "Sep 19", "+$2,140.18"),
        ("Hydro bill", "Sep 17", "-$96.42"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent activity")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(RBC.ink)
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.0).font(.system(size: 15)).foregroundStyle(RBC.ink)
                            Text(row.1).font(.system(size: 12)).foregroundStyle(RBC.muted)
                        }
                        Spacer()
                        Text(row.2)
                            .font(.money(15, weight: .medium))
                            .foregroundStyle(row.2.hasPrefix("+") ? RBC.success : RBC.ink)
                    }
                    .padding(.vertical, 12)
                    if index < rows.count - 1 {
                        Divider().overlay(RBC.line)
                    }
                }
            }
            .padding(.horizontal, 16)
            .rbcCard()
        }
    }
}
