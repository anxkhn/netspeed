import AppKit

@MainActor
enum AppActivationPolicy {
    private static var visibleWindowCount = 0

    static func enter() {
        visibleWindowCount += 1
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    static func leave() {
        visibleWindowCount = max(0, visibleWindowCount - 1)
        guard visibleWindowCount == 0 else { return }
        Task { @MainActor in NSApp.setActivationPolicy(.accessory) }
    }
}
