# NetSpeed

NetSpeed is a native macOS menu bar network monitor rebuilt for macOS 26 with liquid-glass windows, SwiftUI Charts, Sparkle updates, history tracking, exports, alerts, and a professional settings experience.

## Features

- Live upload and download speeds in the menu bar.
- Rich liquid-glass popover dashboard.
- Full-size visualizer window with Swift Charts.
- Daily usage history with retention controls.
- CSV and JSON export.
- Local IP, interface, and optional public IP display.
- Spike notifications with custom thresholds.
- Launch at login via `SMAppService`.
- Custom menu bar layouts and bytes/bits units.
- Native macOS 26 liquid-glass Settings window with sidebar navigation.
- Sparkle 2 auto-update integration for non-App Store distribution.
- Sandboxed, hardened runtime-friendly build settings.

## Requirements

- macOS 14 or later.
- Xcode 26 or later for development.

## Build

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -resolvePackageDependencies -project NetSpeed.xcodeproj -scheme NetSpeed
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild build -project NetSpeed.xcodeproj -scheme NetSpeed -configuration Debug -destination 'platform=macOS'
```

## Sparkle Setup

NetSpeed includes Sparkle wiring and an empty `appcast.xml` for `https://github.com/anxkhn/netspeed`.

Before shipping releases, replace `REPLACE_WITH_SPARKLE_PUBLIC_EDDSA_KEY` in the generated Info.plist build settings with your Sparkle EdDSA public key. Generate it after package resolution using Sparkle's `generate_keys` tool from DerivedData.

## License

NetSpeed is GPLv3-or-later. See `LICENSE`.
