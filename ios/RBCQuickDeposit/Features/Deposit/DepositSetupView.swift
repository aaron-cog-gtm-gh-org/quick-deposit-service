import SwiftUI

/// Step 1 of the wizard: choose the destination account and enter the amount.
struct DepositSetupView: View {
    @Bindable var model: DepositViewModel
    var onClose: () -> Void

    @FocusState private var amountFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                section("Deposit to") {
                    VStack(spacing: 10) {
                        ForEach(model.accounts) { account in
                            SelectableAccountRow(
                                account: account,
                                isSelected: account == model.selectedAccount
                            ) { model.selectedAccount = account }
                        }
                    }
                }

                section("Amount") {
                    HStack(spacing: 6) {
                        Text("$")
                            .font(.money(32, weight: .medium))
                            .foregroundStyle(RBC.muted)
                        TextField("0.00", text: $model.amountText)
                            .font(.money(34))
                            .foregroundStyle(RBC.ink)
                            .keyboardType(.decimalPad)
                            .focused($amountFocused)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .rbcCard()
                }

                section("Memo (optional)") {
                    TextField("What's this cheque for?", text: $model.memo)
                        .font(.system(size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .rbcCard()
                }

                section("Raw capture payload (security testing)") {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("Send raw memo payload", isOn: $model.rawPayloadEnabled)
                            .font(.system(size: 15, weight: .medium))
                            .tint(RBC.blue)

                        if model.rawPayloadEnabled {
                            TextField(
                                "Hex bytes for the memo field (e.g. 41414141…)",
                                text: $model.rawPayloadHex,
                                axis: .vertical
                            )
                            .font(.system(size: 13, design: .monospaced))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .lineLimit(3...8)

                            Text("Bytes are sent verbatim as the memo record, bypassing the text field's encoding and length.")
                                .font(.system(size: 12))
                                .foregroundStyle(RBC.muted)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .rbcCard()
                }
            }
            .padding(20)
        }
        .background(RBC.surface)
        .safeAreaInset(edge: .bottom) { continueBar }
        .navigationTitle("Deposit a cheque")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(RBC.chrome, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", action: onClose)
            }
        }
        .onTapGesture { amountFocused = false }
    }

    private var continueBar: some View {
        Button("Add cheque images") {
            amountFocused = false
            model.startAddingImages()
        }
        .buttonStyle(RBCPrimaryButtonStyle(enabled: model.canContinueFromSetup))
        .disabled(!model.canContinueFromSetup)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(.bar)
    }

    @ViewBuilder
    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(RBC.muted)
            content()
        }
    }
}

/// Selectable account row with a radio affordance.
struct SelectableAccountRow: View {
    let account: Account
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? RBC.blue : RBC.line)
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(RBC.ink)
                    Text("\(account.kind) \(account.displayNumber)")
                        .font(.system(size: 13))
                        .foregroundStyle(RBC.muted)
                }
                Spacer()
                Text(account.balance.currencyString)
                    .font(.money(15, weight: .medium))
                    .foregroundStyle(RBC.muted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .fill(RBC.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RBC.radius, style: .continuous)
                    .stroke(isSelected ? RBC.blue : RBC.line, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
