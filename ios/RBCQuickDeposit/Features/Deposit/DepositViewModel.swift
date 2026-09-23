import SwiftUI
import Observation

/// Drives the deposit wizard: destination account, amount, captured cheque
/// sides, the upload round-trip, and the resulting confirmation.
@Observable
final class DepositViewModel {
    /// Wizard steps pushed onto the flow's navigation stack, in order.
    enum Step: Hashable {
        case addImages
        case review
        case submitting
        case success
    }

    // Setup
    var accounts: [Account] = DemoProfile.accounts
    var selectedAccount: Account
    var amountText: String = ""
    var memo: String = ""

    // Capture
    var front = ChequeSide(face: .front, image: nil)
    var back = ChequeSide(face: .back, image: nil)

    // Result
    var parsed: ParsedCheque?
    var confirmationNumber: String = ""
    var errorMessage: String?

    var path: [Step] = []

    private let client: DepositClient

    init(client: DepositClient = DepositClient()) {
        self.client = client
        self.selectedAccount = DemoProfile.accounts[0]
    }

    // MARK: - Derived state

    var amount: Decimal? {
        let cleaned = amountText.replacingOccurrences(of: ",", with: "")
        guard let value = Decimal(string: cleaned), value > 0 else { return nil }
        return value
    }

    var amountDisplay: String { amount?.currencyString ?? "$0.00" }

    var canContinueFromSetup: Bool { amount != nil }

    var bothSidesCaptured: Bool { front.isCaptured && back.isCaptured }

    /// Funds-available date shown on the success screen (next business day-ish).
    var availabilityDate: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }

    // MARK: - Navigation

    func startAddingImages() { path.append(.addImages) }
    func goToReview() { path.append(.review) }

    func resetFlow() {
        amountText = ""
        memo = ""
        front.image = nil
        back.image = nil
        parsed = nil
        confirmationNumber = ""
        errorMessage = nil
        path.removeAll()
    }

    // MARK: - Upload

    /// Builds a benign `.chq` from the deposit details and uploads it to the
    /// ingestion endpoint, then advances to the success screen with the parsed
    /// fields the backend returns.
    @MainActor
    func submit() async {
        errorMessage = nil
        path.append(.submitting)

        let memoText = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let fields = ChqEncoder.Fields(
            micr: selectedAccount.micr,
            payee: DemoProfile.holderName,
            memo: memoText.isEmpty ? "Cheque deposit" : memoText
        )
        let chq = ChqEncoder.encode(fields)

        do {
            let result = try await client.submit(chq: chq)
            parsed = result
            confirmationNumber = Self.makeConfirmationNumber()
            path = [.success]
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Something went wrong submitting your deposit."
            // Drop back to the review screen so the user can retry.
            path = [.addImages, .review]
        }
    }

    private static func makeConfirmationNumber() -> String {
        let digits = (0..<9).map { _ in String(Int.random(in: 0...9)) }.joined()
        return "QD" + digits
    }
}
