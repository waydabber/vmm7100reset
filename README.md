# vmm7100reset

This small swift command line app resets the USB-C to HDMI dongle. It is the result of analyzing the messages sent by VMMHIDTool under windows (by @djrobx).

This is a swift rewrite based on https://github.com/djrobx/USBResetter for [BetterDisplay](https://betterdisplay.pro).

### Installation:

- Enter: `swiftc vmm7100reset.swift`

### Usage:

1. Enter: `./vmm7100`
2. After resetting the adapter(s), there must be some event to get macOS to notice the adapters and wake the screens up. So resetting the adapter, THEN powering up the monitors usually does the trick (note: BetterDisplay does instruct the displays to reconnect but that is not part of this code).
