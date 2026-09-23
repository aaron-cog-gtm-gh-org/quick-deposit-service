import SwiftUI

/// Cosmetic sign-in. No real authentication — tapping either affordance enters
/// the app. Kept deliberately short.
struct SignInView: View {
    var onSignedIn: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [RBC.navy, Color(hex: 0x00224A)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    BrandMark(size: 76)
                    VStack(spacing: 6) {
                        (Text("RBC ").fontWeight(.bold) + Text("QuickDeposit").fontWeight(.regular))
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                        Text("Mobile cheque deposit")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(hex: 0x9FB6D6))
                    }
                }

                Spacer()

                VStack(spacing: 16) {
                    Button(action: onSignedIn) {
                        Label("Sign in with Face ID", systemImage: "faceid")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundStyle(RBC.navy)
                            .background(
                                RoundedRectangle(cornerRadius: 999, style: .continuous)
                                    .fill(RBC.gold)
                            )
                    }

                    Button("Use passcode", action: onSignedIn)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)

                Text("Demo environment — not connected to any real RBC system.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: 0x7E96BC))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
        }
    }
}
