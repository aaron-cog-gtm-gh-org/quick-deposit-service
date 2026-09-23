import SwiftUI

/// Final step: confirmation with the parsed fields returned by the backend.
struct SuccessView: View {
    @Bindable var model: DepositViewModel
    var onDone: () -> Void

    private var availabilityText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: model.availabilityDate)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 14) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(RBC.success)
                    Text("Deposit submitted")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(RBC.ink)
                    Text("\(model.amountDisplay) to \(model.selectedAccount.kind) \(model.selectedAccount.displayNumber)")
                        .font(.system(size: 15))
                        .foregroundStyle(RBC.muted)
                }
                .padding(.top, 24)

                VStack(spacing: 12) {
                    DetailRow(label: "Funds available by", value: availabilityText)
                    Divider().overlay(RBC.line)
                    DetailRow(label: "Confirmation number", value: model.confirmationNumber, mono: true)
                    if let parsed = model.parsed {
                        Divider().overlay(RBC.line)
                        DetailRow(label: "Payee", value: parsed.payee)
                        Divider().overlay(RBC.line)
                        DetailRow(label: "Memo", value: parsed.memo)
                        Divider().overlay(RBC.line)
                        DetailRow(label: "MICR", value: parsed.micr, mono: true)
                    }
                }
                .padding(16)
                .rbcCard()

                Text("Your cheque capture was read and indexed for posting. Keep the paper cheque until the funds appear.")
                    .font(.system(size: 13))
                    .foregroundStyle(RBC.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(20)
        }
        .background(RBC.surface)
        .safeAreaInset(edge: .bottom) {
            Button("Done", action: onDone)
                .buttonStyle(RBCPrimaryButtonStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.bar)
        }
        .navigationTitle("Confirmation")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(RBC.chrome, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
