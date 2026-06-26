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
            return condensedSystemFont(size: resolvedSize)
        case .monospaced:
            return NSFont.monospacedDigitSystemFont(ofSize: resolvedSize, weight: .medium)
        case .custom:
            let name = defaults.string(forKey: AppDefaults.menuBarFontName) ?? ""
            return NSFont(name: name, size: resolvedSize) ?? condensedSystemFont(size: resolvedSize)
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
            return .system(size: resolvedSize, weight: .medium, design: .default).width(.condensed)
        case .monospaced:
            return .system(size: resolvedSize, weight: .medium, design: .monospaced)
        case .custom:
            let name = defaults.string(forKey: AppDefaults.menuBarFontName) ?? ""
            return name.isEmpty ? .system(size: resolvedSize, weight: .medium).width(.condensed) : .custom(name, size: resolvedSize)
        }
    }

    private static func condensedSystemFont(size: CGFloat) -> NSFont {
        let width = CGFloat(UserDefaults.standard.double(forKey: AppDefaults.menuBarCondensedWidth))
        let base = NSFont.systemFont(ofSize: size, weight: .medium)
        let descriptor = base.fontDescriptor.addingAttributes([
            .traits: [NSFontDescriptor.TraitKey.width: max(0.62, min(1.0, width))]
        ])
        return NSFont(descriptor: descriptor, size: size) ?? base
    }
}
