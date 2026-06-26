import AppKit
import SwiftUI

enum MenuBarFont {
    static func nsFont(size: CGFloat? = nil) -> NSFont {
        let defaults = UserDefaults.standard
        let mode = MenuBarFontMode(rawValue: defaults.string(forKey: AppDefaults.menuBarFontMode) ?? "") ?? .condensed
        let resolvedSize = size ?? max(7, defaults.double(forKey: AppDefaults.menuBarFontSize))

        switch mode {
        case .system:
            return NSFont.systemFont(ofSize: resolvedSize, weight: .medium)
        case .condensed:
            return builtInCondensedFont(size: resolvedSize)
        case .monospaced:
            return NSFont.monospacedDigitSystemFont(ofSize: resolvedSize, weight: .medium)
        case .custom:
            let name = defaults.string(forKey: AppDefaults.menuBarFontName) ?? ""
            return NSFont(name: name, size: resolvedSize) ?? builtInCondensedFont(size: resolvedSize)
        }
    }

    static func swiftUIFont(size: CGFloat? = nil) -> Font {
        let defaults = UserDefaults.standard
        let mode = MenuBarFontMode(rawValue: defaults.string(forKey: AppDefaults.menuBarFontMode) ?? "") ?? .condensed
        let resolvedSize = size ?? max(7, defaults.double(forKey: AppDefaults.menuBarFontSize))
        switch mode {
        case .system:
            return .system(size: resolvedSize, weight: .medium, design: .default)
        case .condensed:
            return .custom("AvenirNextCondensed-Medium", size: resolvedSize)
        case .monospaced:
            return .system(size: resolvedSize, weight: .medium, design: .monospaced)
        case .custom:
            let name = defaults.string(forKey: AppDefaults.menuBarFontName) ?? ""
            return name.isEmpty ? .custom("AvenirNextCondensed-Medium", size: resolvedSize) : .custom(name, size: resolvedSize)
        }
    }

    private static func builtInCondensedFont(size: CGFloat) -> NSFont {
        let candidates = [
            "AvenirNextCondensed-Medium",
            "AvenirNextCondensed-DemiBold",
            "HelveticaNeue-CondensedBold",
            "HelveticaNeue-CondensedBlack",
        ]
        for name in candidates {
            if let font = NSFont(name: name, size: size) { return font }
        }
        let base = NSFont.systemFont(ofSize: size, weight: .medium)
        let descriptor = base.fontDescriptor.withSymbolicTraits(.condensed)
        return NSFont(descriptor: descriptor, size: size) ?? base
    }
}
