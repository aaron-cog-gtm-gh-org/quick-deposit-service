# RBC QuickDeposit — iOS demo

> **Demo only.** Every person, account, balance, and cheque in this app is
> fictional. The app is a cosmetic walkthrough of a mobile cheque-deposit flow
> for stage demos — it is not connected to, affiliated with, or representative
> of any real RBC system, and it is not production software.

The app walks through sign-in → dashboard → deposit setup → add cheque images
(front + back) → review → submitting → success. On submit it encodes the deposit
details into a benign `.chq` capture container (the format documented in
`service/native/chqparse.c`) and uploads it as `multipart/form-data` field
`file` to `POST http://localhost:8080/api/v1/deposit/cheque`. The parsed fields
returned by the backend (payee, memo, MICR, record count) are rendered on the
confirmation screen.

`ChqEncoder` emits each field's bytes verbatim and does not bound field payloads
against the parser's destination buffers, so an oversized field (e.g. a long
memo) is transmitted as-is. The native parser copies a field into a fixed
256-byte stack buffer using the field's declared length, so a memo longer than
that overflows it — the memory-safety bug is therefore reachable directly from
the app's deposit flow. Security-operator materials (scans, exploit artifacts)
live outside this repository.

## Prerequisites

- macOS with **Xcode** (26.x) and its command-line tools
- **XcodeGen**: `brew install xcodegen`
- The local backend running (see "Backend" below)

## Build

```sh
cd ios
xcodegen generate          # regenerates RBCQuickDeposit.xcodeproj from project.yml
xcodebuild -project RBCQuickDeposit.xcodeproj \
    -target RBCQuickDeposit \
    -sdk iphonesimulator26.5 \
    -configuration Debug \
    build
```

If your Xcode ships a different Simulator SDK, adjust `-sdk` accordingly
(`xcodebuild -showsdks` lists them).

## Backend

```sh
cc -O0 -g -o service/native/chqparse service/native/chqparse.c   # local build
python3 -m venv .venv && .venv/bin/pip install -r service/requirements.txt
CHQPARSE_BIN=$PWD/service/native/chqparse .venv/bin/python service/app.py
# health check: curl http://localhost:8080/healthz -> {"status":"ok"}
```

The Simulator shares the host network, so `http://localhost:8080` reaches the
host backend directly. Override with the `QD_BACKEND_URL` environment variable
to point at a different host.

## Simulator Photos preload

The picker is the real `PHPickerViewController`, so preload sample cheque
images into the Simulator's Photos library.

First boot a Simulator — either run the app from Xcode (open
`ios/RBCQuickDeposit.xcodeproj`, pick an iPhone Simulator in the scheme
selector, press Run), or boot one by name:

```sh
xcrun simctl boot "iPhone 17"          # any device from `xcrun simctl list devices`
```

Then regenerate (if needed) and push the sample images into the booted device:

```sh
swift ios/tools/make_cheque_images.swift ios/tools   # (re)generate cheque PNGs
xcrun simctl addmedia booted ios/tools/cheque_front.png ios/tools/cheque_back.png
```

## Traffic inspection (mitmproxy / Burp / Charles)

To watch the upload on the wire:

1. Point the app at the proxy host: `QD_BACKEND_URL=http://<proxy-host>:<port>`
   via a scheme environment variable, or run the proxy transparently.
2. In the Simulator: Settings → Wi-Fi → (i) on the network → Configure Proxy →
   Manual, host/port of your proxy.
3. Install the proxy CA: drag the CA cert into the Simulator window, then
   Settings → General → About → Certificate Trust Settings → enable full trust.

The request is a plain `multipart/form-data` POST with a single `file` part —
exactly what the web client sends.
