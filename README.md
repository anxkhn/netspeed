<p align="center">
  <img src="Resources/netspeed-app-icon.svg" alt="NetSpeed app icon" width="140" height="140">
</p>

<h1 align="center">NetSpeed</h1>

<p align="center">
  A polished macOS menu bar monitor for live network speed, usage history, and connection details.
</p>

<p align="center">
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-GPLv3--or--later-111111"></a>
  <img alt="macOS" src="https://img.shields.io/badge/macOS-14%2B-111111">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6-111111">
</p>

## Overview

NetSpeed puts live upload and download activity where it is easiest to glance at: the macOS menu bar. Open the popover for a clean snapshot of current throughput, recent usage, and interface details, or switch to the visualizer for a larger chart-driven view.

It is built with SwiftUI, Swift Charts, a native settings experience, usage exports, alerting, launch-at-login support, sandboxing, hardened runtime settings, and Sparkle wiring for direct distribution.

## Highlights

- Live upload and download speeds in the menu bar.
- Compact popover with speed cards, recent usage totals, and network details.
- Full visualizer window powered by Swift Charts.
- Daily usage history with configurable retention.
- CSV and JSON exports for recorded usage data.
- Local IP, active interface, and optional public IP display.
- Spike notifications with custom thresholds.
- Launch at login via `SMAppService`.
- Custom menu bar layout, arrow placement, typography, stable width, and bytes/bits units.
- Native macOS 26 liquid-glass settings with sidebar navigation.
- Sparkle 2 integration for non-App Store updates.

## Requirements

- macOS 14 or later.
- Xcode 26 or later for development.

## Build

Resolve dependencies:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -resolvePackageDependencies -project NetSpeed.xcodeproj -scheme NetSpeed
```

Build a debug copy:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild build -project NetSpeed.xcodeproj -scheme NetSpeed -configuration Debug -destination 'platform=macOS'
```

For unsigned command-line verification, add `CODE_SIGNING_ALLOWED=NO`.

## License

NetSpeed is GPLv3-or-later. See `LICENSE`.
