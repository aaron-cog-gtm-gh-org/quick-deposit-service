import SwiftUI

/// Step 3: confirm the deposit. Shows the captured images and the amount, then
/// uploads the capture on confirm.
struct ReviewView: View {
    @Bindable var model: DepositViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("You're depositing")
                        .font(.system(size: 14))
                        .foregroundStyle(RBC.muted)
                    Text(model.amountDisplay)
                        .font(.money(44, weight: .bold))
                        .foregroundStyle(RBC.ink)
                    Text("into \(model.selectedAccount.kind) \(model.selectedAccount.displayNumber)")
                        .font(.system(size: 15))
                        .foregroundStyle(RBC.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .rbcCard()

                HStack(spacing: 12) {
                    thumbnail(model.front)
                    thumbnail(model.back)
                }

                VStack(spacing: 12) {
                    DetailRow(label: "Payee", value: DemoProfile.holderName)
                    Divider().overlay(RBC.line)
                    DetailRow(
                        label: "Memo",
                        value: model.memo.isEmpty ? "Cheque deposit" : model.memo
                    )
                    Divider().overlay(RBC.line)
                    DetailRow(label: "MICR", value: model.selectedAccount.micr, mono: true)
                }
                .padding(16)
                .rbcCard()

                if let error = model.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(RBC.danger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                                .fill(RBC.danger.opacity(0.08))
                        )
                }
            }
            .padding(20)
        }
        .background(RBC.surface)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 4) {
                Button("Deposit \(model.amountDisplay)") {
                    Task { await model.submit() }
                }
                .buttonStyle(RBCPrimaryButtonStyle())
                Text("By depositing, you agree to the RBC deposit terms.")
                    .font(.system(size: 11))
                    .foregroundStyle(RBC.muted)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.bar)
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(RBC.chrome, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func thumbnail(_ side: ChequeSide) -> some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                Group {
                    if let image = side.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: 96)
                            .clipped()
                    } else {
                        Color(hex: 0xF7F9FC)
                    }
                }
            }
            .frame(height: 96)
            .clipShape(RoundedRectangle(cornerRadius: RBC.radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .stroke(RBC.line, lineWidth: 1)
            )
            Text(side.face.rawValue)
                .font(.system(size: 12))
                .foregroundStyle(RBC.muted)
        }
    }
}
