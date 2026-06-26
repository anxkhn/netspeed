import AppKit
import SwiftUI

enum MenuBarFont {
    static func nsFont(size: CGFloat? = nil) -> NSFont {
        let defaults = UserDefaults.standard
        let mode = MenuBarFontMode(rawValue: defaults.string(forKey: AppDefaults.menuBarFontMode) ?? "") ?? .condensed
        let resolvedSize = size ?? max(7, defaults.double(forKey: AppDefaults.menuBarFontSize))
        let weight = weightValue()

        switch mode {
        case .system:
            return adjusted(NSFont.systemFont(ofSize: resolvedSize, weight: weight), size: resolvedSize)
        case .condensed:
            return adjusted(builtInCondensedFont(size: resolvedSize, weight: weight), size: resolvedSize)
        case .monospaced:
            return adjusted(NSFont.monospacedDigitSystemFont(ofSize: resolvedSize, weight: weight), size: resolvedSize)
        case .custom:
            let name = defaults.string(forKey: AppDefaults.menuBarFontName) ?? ""
            return adjusted(NSFont(name: name, size: resolvedSize) ?? builtInCondensedFont(size: resolvedSize, weight: weight), size: resolvedSize)
        }
    }

    static func swiftUIFont(size: CGFloat? = nil) -> Font {
        let defaults = UserDefaults.standard
        let mode = MenuBarFontMode(rawValue: defaults.string(forKey: AppDefaults.menuBarFontMode) ?? "") ?? .condensed
        let resolvedSize = size ?? max(7, defaults.double(forKey: AppDefaults.menuBarFontSize))
        let weight = swiftUIWeight()
        switch mode {
        case .system:
            return .system(size: resolvedSize, weight: weight, design: .default).width(swiftUIWidth())
        case .condensed:
            return .custom(weight == .bold ? "AvenirNextCondensed-Bold" : "AvenirNextCondensed-Medium", size: resolvedSize).width(swiftUIWidth())
        case .monospaced:
            return .system(size: resolvedSize, weight: weight, design: .monospaced).width(swiftUIWidth())
        case .custom:
            let name = defaults.string(forKey: AppDefaults.menuBarFontName) ?? ""
            let font = name.isEmpty ? Font.custom("AvenirNextCondensed-Medium", size: resolvedSize) : Font.custom(name, size: resolvedSize)
            return font.width(swiftUIWidth())
        }
    }

    private static func builtInCondensedFont(size: CGFloat, weight: NSFont.Weight) -> NSFont {
        let candidates = weight.rawValue >= NSFont.Weight.semibold.rawValue
            ? ["AvenirNextCondensed-Bold", "AvenirNextCondensed-DemiBold", "HelveticaNeue-CondensedBold", "HelveticaNeue-CondensedBlack"]
            : ["AvenirNextCondensed-Medium", "AvenirNextCondensed-Regular", "HelveticaNeue-CondensedBold"]
        for name in candidates {
            if let font = NSFont(name: name, size: size) { return font }
        }
        let base = NSFont.systemFont(ofSize: size, weight: weight)
        let descriptor = base.fontDescriptor.withSymbolicTraits(.condensed)
        return NSFont(descriptor: descriptor, size: size) ?? base
    }

    private static func adjusted(_ font: NSFont, size: CGFloat) -> NSFont {
        let width = CGFloat(UserDefaults.standard.double(forKey: AppDefaults.menuBarFontWidth))
        guard width < 0.98 else { return font }
        let matrix = AffineTransform(m11: max(0.55, min(1.0, width)), m12: 0, m21: 0, m22: 1.0, tX: 0, tY: 0)
        return NSFont(descriptor: font.fontDescriptor, textTransform: matrix) ?? font
    }

    private static func weightValue() -> NSFont.Weight {
        UserDefaults.standard.double(forKey: AppDefaults.menuBarFontWeight) >= 0.5 ? .bold : .medium
    }

    private static func swiftUIWeight() -> Font.Weight {
        UserDefaults.standard.double(forKey: AppDefaults.menuBarFontWeight) >= 0.5 ? .bold : .medium
    }

    private static func swiftUIWidth() -> Font.Width {
        let width = UserDefaults.standard.double(forKey: AppDefaults.menuBarFontWidth)
        if width <= 0.62 { return .compressed }
        if width <= 0.82 { return .condensed }
        return .standard
    }
}
