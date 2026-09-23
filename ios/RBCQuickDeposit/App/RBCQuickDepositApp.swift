import SwiftUI

@main
struct RBCQuickDepositApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(RBC.blue)
        }
    }
}

/// Switches between the cosmetic sign-in splash and the authenticated app.
struct RootView: View {
    @State private var signedIn = false

    var body: some View {
        if signedIn {
            DashboardView(onSignOut: { withAnimation { signedIn = false } })
                .transition(.opacity)
        } else {
            SignInView(onSignedIn: { withAnimation { signedIn = true } })
                .transition(.opacity)
        }
    }
}
