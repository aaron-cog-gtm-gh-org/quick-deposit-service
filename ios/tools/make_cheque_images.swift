// Generates sample cheque images (front + back) for preloading the Simulator
// Photos library used by the demo. These are fictional demo cheques.
// Run: swift ios/tools/make_cheque_images.swift <outdir>
import AppKit

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let W = 1000.0, H = 460.0

let navy = NSColor(srgbRed: 0x00/255, green: 0x31/255, blue: 0x68/255, alpha: 1)
let blue = NSColor(srgbRed: 0x00/255, green: 0x5D/255, blue: 0xAA/255, alpha: 1)
let gold = NSColor(srgbRed: 0xFE/255, green: 0xDF/255, blue: 0x01/255, alpha: 1)
let ink = NSColor(srgbRed: 0x1c/255, green: 0x28/255, blue: 0x38/255, alpha: 1)
let paper = NSColor(srgbRed: 0.98, green: 0.985, blue: 0.99, alpha: 1)
let rule = NSColor(srgbRed: 0.72, green: 0.78, blue: 0.85, alpha: 1)

func text(_ s: String, _ x: Double, _ y: Double, size: CGFloat, color: NSColor, bold: Bool = false, mono: Bool = false) {
    let font: NSFont
    if mono { font = NSFont.monospacedSystemFont(ofSize: size, weight: bold ? .bold : .regular) }
    else { font = NSFont.systemFont(ofSize: size, weight: bold ? .bold : .regular) }
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
    NSString(string: s).draw(at: NSPoint(x: x, y: y), withAttributes: attrs)
}

func line(_ x1: Double, _ y: Double, _ x2: Double, color: NSColor = rule, width: CGFloat = 1.5) {
    color.setStroke()
    let p = NSBezierPath()
    p.lineWidth = width
    p.move(to: NSPoint(x: x1, y: y)); p.line(to: NSPoint(x: x2, y: y))
    p.stroke()
}

func render(_ name: String, _ draw: () -> Void) {
    let img = NSImage(size: NSSize(width: W, height: H))
    img.lockFocus()
    // paper with subtle guilloché-ish tint band
    paper.setFill(); NSBezierPath(rect: CGRect(x: 0, y: 0, width: W, height: H)).fill()
    NSColor(srgbRed: 0.90, green: 0.94, blue: 0.98, alpha: 1).setFill()
    NSBezierPath(rect: CGRect(x: 0, y: H-70, width: W, height: 70)).fill()
    draw()
    img.unlockFocus()
    let tiff = img.tiffRepresentation!
    let rep = NSBitmapImageRep(data: tiff)!
    let png = rep.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: "\(outDir)/\(name)"))
    print("wrote \(outDir)/\(name)")
}

// FRONT
render("cheque_front.png") {
    text("RBC", 30, H-52, size: 30, color: gold, bold: true)
    text("Royal Bank of Canada", 110, H-48, size: 18, color: .white, bold: true)
    text("No. 0142", W-150, H-48, size: 16, color: .white, bold: true)

    text("PROVINCE STREET BRANCH — TORONTO, ON", 30, H-92, size: 12, color: blue)
    text("DATE", W-260, H-120, size: 11, color: ink)
    line(W-210, H-122, W-30, color: rule)
    text("2026-09-22", W-200, H-118, size: 14, color: ink, mono: true)

    text("PAY TO THE\nORDER OF", 30, H-175, size: 11, color: ink)
    text("Jordan Avery", 130, H-168, size: 20, color: ink, bold: true)
    line(120, H-178, W-220, color: rule)
    // amount box
    rule.setStroke()
    let box = NSBezierPath(rect: CGRect(x: W-200, y: H-185, width: 165, height: 34)); box.lineWidth = 1.5; box.stroke()
    text("$", W-192, H-180, size: 18, color: ink, bold: true)
    text("1,250.00", W-160, H-181, size: 20, color: ink, bold: true, mono: true)

    text("One thousand two hundred fifty and 00/100", 30, H-215, size: 15, color: ink)
    line(500, H-222, W-30, color: rule)
    text("DOLLARS", W-110, H-215, size: 11, color: ink)

    text("MEMO", 30, H-300, size: 11, color: ink)
    text("Rent — September", 90, H-303, size: 14, color: ink)
    line(85, H-312, 360, color: rule)

    text("Jordan Avery", W-260, H-300, size: 20, color: blue)
    line(W-280, H-312, W-30, color: rule)
    text("AUTHORIZED SIGNATURE", W-260, H-330, size: 9, color: ink)

    // MICR line
    text("⑈0142⑈  ⑆00312 068⑆  1234 567 890⑈", 40, 22, size: 22, color: ink, mono: true)
}

// BACK
render("cheque_back.png") {
    text("ENDORSE HERE", 40, H-70, size: 14, color: ink, bold: true)
    line(40, H-120, W-40, color: rule)
    line(40, H-155, W-40, color: rule)
    line(40, H-190, W-40, color: rule)
    text("Jordan Avery", 60, H-114, size: 20, color: blue)
    text("For mobile deposit only — RBC QuickDeposit", 60, H-150, size: 13, color: ink)

    text("DO NOT WRITE, STAMP OR SIGN BELOW THIS LINE", 40, H-240, size: 11, color: NSColor.gray)
    line(40, H-255, W-40, color: NSColor(white: 0.85, alpha: 1), width: 2)
    text("★ RESERVED FOR FINANCIAL INSTITUTION USE ★", W/2-180, 40, size: 12, color: NSColor(white: 0.7, alpha: 1))
}
