import SwiftUI
import PhotosUI

/// Thin SwiftUI wrapper over the real `PHPickerViewController`.
///
/// We deliberately use the system Photos picker (not a faked camera): the
/// Simulator has a genuine Photos library that can be preloaded with sample
/// cheque images, so every control on screen is a real system control.
struct PhotoPicker: UIViewControllerRepresentable {
    /// Called with the picked image once the user selects one, or `nil` if they
    /// cancel.
    var onPicked: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPicked: onPicked) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let onPicked: (UIImage?) -> Void

        init(onPicked: @escaping (UIImage?) -> Void) {
            self.onPicked = onPicked
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // SwiftUI owns the sheet lifecycle via the `pickingFace` binding —
            // do not call `picker.dismiss` here, or it tears down the whole
            // deposit cover along with the Photos sheet.
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                onPicked(nil)
                return
            }

            provider.loadObject(ofClass: UIImage.self) { [onPicked] object, _ in
                DispatchQueue.main.async {
                    onPicked(object as? UIImage)
                }
            }
        }
    }
}
