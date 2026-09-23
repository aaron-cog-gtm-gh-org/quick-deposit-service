import SwiftUI

/// Step 2: add the front and back of the cheque using the real system Photos
/// picker (`PHPickerViewController`). No camera is faked.
struct AddImagesView: View {
    @Bindable var model: DepositViewModel

    /// Which side the picker is currently capturing, if any.
    @State private var pickingFace: ChequeSide.Face?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Add cheque images")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(RBC.ink)
                    Text("Choose a clear photo of each side from your library. Make sure the corners and MICR line are visible.")
                        .font(.system(size: 14))
                        .foregroundStyle(RBC.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                CaptureCard(side: model.front) { pickingFace = .front }
                CaptureCard(side: model.back) { pickingFace = .back }
            }
            .padding(20)
        }
        .background(RBC.surface)
        .safeAreaInset(edge: .bottom) {
            Button("Review deposit") { model.goToReview() }
                .buttonStyle(RBCPrimaryButtonStyle(enabled: model.bothSidesCaptured))
                .disabled(!model.bothSidesCaptured)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.bar)
        }
        .navigationTitle("Cheque images")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(RBC.navy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(item: pickerBinding) { face in
            PhotoPicker { image in
                if let image {
                    switch face.face {
                    case .front: model.front.image = image
                    case .back: model.back.image = image
                    }
                }
                pickingFace = nil
            }
            .ignoresSafeArea()
        }
    }

    /// Bridges the optional `Face` into an `Identifiable` sheet item.
    private var pickerBinding: Binding<FaceItem?> {
        Binding(
            get: { pickingFace.map(FaceItem.init) },
            set: { pickingFace = $0?.face }
        )
    }
}

private struct FaceItem: Identifiable {
    let face: ChequeSide.Face
    var id: String { face.rawValue }
}

/// A single front/back capture slot: empty prompt or captured thumbnail.
struct CaptureCard: View {
    let side: ChequeSide
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(side.face.rawValue) of cheque")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(RBC.ink)
                Spacer()
                if side.isCaptured {
                    Label("Added", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(RBC.success)
                }
            }

            if let image = side.image {
                GeometryReader { geo in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: 168)
                        .clipped()
                }
                .frame(height: 168)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(RBC.line, lineWidth: 1)
                )
                Button("Replace photo", action: onAdd)
                    .buttonStyle(RBCSecondaryButtonStyle())
            } else {
                Button(action: onAdd) {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 30))
                            .foregroundStyle(RBC.blue)
                        Text("Add \(side.face.rawValue.lowercased())")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(RBC.blue)
                        Text("Choose from library")
                            .font(.system(size: 12))
                            .foregroundStyle(RBC.muted)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 168)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hex: 0xF7F9FC))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
                            .foregroundStyle(Color(hex: 0x9CB4D0))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .rbcCard()
    }
}
