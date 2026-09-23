// Generates the app icon (1024x1024 PNG) for RBC QuickDeposit.
// Run: swift ios/tools/make_icon.swift <output.png>
import AppKit

let size = 1024.0
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png"

let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext

// Navy background
ctx.setFillColor(NSColor(srgbRed: 0x00/255, green: 0x31/255, blue: 0x68/255, alpha: 1).cgColor)
ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))

let gold = NSColor(srgbRed: 0xFE/255, green: 0xDF/255, blue: 0x01/255, alpha: 1).cgColor
ctx.setStrokeColor(gold)

let c = CGPoint(x: size/2, y: size/2)
let r = size * 0.30

// Outer ring
ctx.setLineWidth(size * 0.028)
ctx.strokeEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r*2, height: r*2))

// Meridian ellipse
ctx.setLineWidth(size * 0.020)
ctx.strokeEllipse(in: CGRect(x: c.x - r*0.42, y: c.y - r, width: r*0.84, height: r*2))

// Horizontal grid lines
for dy in [-r*0.42, 0, r*0.42] {
    ctx.move(to: CGPoint(x: c.x - r, y: c.y + dy))
    ctx.addLine(to: CGPoint(x: c.x + r, y: c.y + dy))
}
ctx.strokePath()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("failed to render png")
}
try! png.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath)")
