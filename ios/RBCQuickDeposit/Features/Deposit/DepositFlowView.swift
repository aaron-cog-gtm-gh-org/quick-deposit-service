import SwiftUI

/// Hosts the deposit wizard in its own navigation stack. Setup is the root;
/// add-images, review, submitting and success are pushed as the user advances.
struct DepositFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model = DepositViewModel()

    var body: some View {
        NavigationStack(path: $model.path) {
            DepositSetupView(model: model, onClose: { dismiss() })
                .navigationDestination(for: DepositViewModel.Step.self) { step in
                    switch step {
                    case .addImages:
                        AddImagesView(model: model)
                    case .review:
                        ReviewView(model: model)
                    case .submitting:
                        SubmittingView(model: model)
                    case .success:
                        SuccessView(model: model, onDone: { dismiss() })
                    }
                }
        }
        .tint(RBC.blue)
    }
}
