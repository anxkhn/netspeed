import AppKit
import SwiftUI

struct AdaptiveGlassBackground: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(AppDefaults.surfaceStyle) private var surfaceStyle = SurfaceStyle.system.rawValue

    private var reduceTransparency: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
    }

    func body(content: Content) -> some View {
        content
            .background(backgroundShape)
            .animation(reduceMotion ? nil : .snappy(duration: 0.18), value: surfaceStyle)
    }

    @ViewBuilder
    private var backgroundShape: some View {
        let style = SurfaceStyle(rawValue: surfaceStyle) ?? .system
        let forceOpaque = reduceTransparency || style == .opaque
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(forceOpaque ? Color(nsColor: .windowBackgroundColor) : Color(nsColor: .windowBackgroundColor).opacity(style == .transparent ? 0.58 : 0.74))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(.white.opacity(forceOpaque ? 0.08 : 0.18), lineWidth: 1))
            .shadow(color: .black.opacity(reduceMotion ? 0.12 : 0.24), radius: reduceMotion ? 8 : 24, y: reduceMotion ? 4 : 14)
            .glassIfAvailable(opaque: forceOpaque)
    }
}

extension View {
    func adaptiveGlassBackground() -> some View { modifier(AdaptiveGlassBackground()) }

    @ViewBuilder
    func glassIfAvailable(opaque: Bool = false) -> some View {
        if #available(macOS 26.0, *), !opaque {
            glassEffect(.regular, in: .rect(cornerRadius: 28))
        } else {
            self
        }
    }
}
