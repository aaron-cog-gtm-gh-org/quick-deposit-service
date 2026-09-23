import Foundation
import UIKit

/// A demo deposit account shown on the dashboard and as a deposit destination.
struct Account: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let kind: String          // "Chequing", "Savings"
    let lastFour: String
    let balance: Decimal

    /// MICR line encoded into the capture for cheques deposited to this account.
    let micr: String

    var displayNumber: String { "••••\(lastFour)" }
}

/// The demo customer. Cheques captured in the app are made out to this holder,
/// so the encoded payee matches a self-deposit.
enum DemoProfile {
    static let holderName = "Jordan Avery"

    static let accounts: [Account] = [
        Account(
            name: "Everyday Chequing",
            kind: "Chequing",
            lastFour: "1234",
            balance: 4820.55,
            micr: "C0001234567C 001234 56789012"
        ),
        Account(
            name: "eSavings",
            kind: "Savings",
            lastFour: "5678",
            balance: 15230.00,
            micr: "C0001234567C 001234 56785678"
        ),
    ]
}

/// A picked cheque side (front/back) with its label and thumbnail.
struct ChequeSide: Identifiable {
    enum Face: String { case front = "Front", back = "Back" }
    let id = UUID()
    let face: Face
    var image: UIImage?
    var isCaptured: Bool { image != nil }
}

extension Decimal {
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }
}
