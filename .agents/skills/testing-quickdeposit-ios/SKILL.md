---
name: testing-quickdeposit-ios
description: Run the QuickDeposit native iOS demo against its real local Flask parser and verify the Photos-to-confirmation flow.
---

# QuickDeposit iOS testing

## Devin Secrets Needed
None for local demo testing. Sign-in is cosmetic and the local ingestion endpoint is unauthenticated.

## Setup
- Follow `ios/README.md` for XcodeGen, build, native parser, Python dependencies, and Simulator Photos preload.
- Inspect `xcrun simctl runtime match list`. For Xcode SDK iphoneos26.5 with installed runtime build 23F73, use `xcrun simctl runtime match set iphoneos26.5 23F73`; do not apply this version-specific override blindly on other hosts.
- Build alone does not prove launchability: install the `.app` with `xcrun simctl install booted` and launch `com.rbc.quickdeposit.demo`.
- Start Flask with `CHQPARSE_BIN` set to the absolute compiled native-parser path. A healthy `/healthz` response alone does not verify parser configuration.
- Simulator reaches the host at `http://localhost:8080`. Keep a backend request/response log to correlate UI submission with real processing.

## Golden path
- Use native Simulator controls, real PHPicker selection, and the fictional `ios/tools/cheque_front.png` / `cheque_back.png` assets preloaded in Photos.
- Choose the nondefault Savings account, a positive amount, and a distinctive short ASCII memo. Confirm the actual typed memo visually because iOS autocorrect may change it.
- Check each photo returns to the wizard and marks only its respective side Added; review must remain disabled until both exist.
- Submit through the UI only. Corroborate multipart field `file`, filename `cheque.chq`, CHQ1 magic, HTTP 200, and three records in observation logs without replacing the real endpoint/parser.
- Confirmation must display the returned payee, memo, and selected-account MICR. Amount and photos are UI/demo data, not an OCR or real banking operation.
- Check horizontal margins and photo/card clipping after images load, as layout can differ from empty capture slots.
- Record a full native UI flow, and scope claims to the tested device/appearance.
