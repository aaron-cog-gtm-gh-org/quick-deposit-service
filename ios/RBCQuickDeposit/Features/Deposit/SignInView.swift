import SwiftUI

/// Cosmetic sign-in, restyled to the RBC Mobile reference: a layered blue
/// gradient hero over a white authentication panel with a compact rectangular
/// blue primary action. No real authentication — either affordance enters.
struct SignInView: View {
    var onSignedIn: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            hero

            VStack(spacing: 14) {
                Button(action: onSignedIn) {
                    Label("Sign in with Face ID", systemImage: "faceid")
                }
                .buttonStyle(RBCPrimaryButtonStyle())

                Button("Use passcode", action: onSignedIn)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RBC.blue)

                Text("Demo environment — not connected to any real RBC system.")
                    .font(.system(size: 11))
                    .foregroundStyle(RBC.muted)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 26)
            .padding(.bottom, 40)
            .background(Color.white)
        }
        .ignoresSafeArea()
    }

    private var hero: some View {
        ZStack {
            LinearGradient(
                colors: [RBC.headerTop, RBC.headerMid, RBC.headerDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Ellipse()
                .fill(Color.white.opacity(0.06))
                .frame(width: 340, height: 340)
                .offset(x: 190, y: -220)
            Ellipse()
                .stroke(Color.white.opacity(0.10), lineWidth: 28)
                .frame(width: 300, height: 300)
                .offset(x: 230, y: -190)
            Ellipse()
                .fill(Color.white.opacity(0.05))
                .frame(width: 260, height: 160)
                .offset(x: -90, y: 150)
            Ellipse()
                .stroke(Color.white.opacity(0.07), lineWidth: 18)
                .frame(width: 240, height: 240)
                .offset(x: -120, y: -160)

            VStack(spacing: 18) {
                BrandMark(size: 68)
                VStack(spacing: 6) {
                    (Text("RBC ").fontWeight(.bold) + Text("QuickDeposit").fontWeight(.light))
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                    Text("Mobile cheque deposit")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}
