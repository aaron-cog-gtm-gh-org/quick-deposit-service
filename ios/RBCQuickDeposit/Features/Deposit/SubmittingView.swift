import SwiftUI

/// Transient step shown while the capture uploads. No controls — the view model
/// advances to success (or back to review on error) when the request settles.
struct SubmittingView: View {
    @Bindable var model: DepositViewModel

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
                .tint(RBC.blue)
            Text("Submitting your deposit…")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(RBC.ink)
            Text("Sending your cheque capture securely.")
                .font(.system(size: 14))
                .foregroundStyle(RBC.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RBC.surface)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
