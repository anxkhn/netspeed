import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private static var shared: SettingsWindowController?

    static func show(tab: SettingsTab? = nil) {
        if let tab { SettingsNavigation.shared.selectedTab = tab }
        if shared == nil { shared = SettingsWindowController() }
        shared?.showWindow(nil)
    }

    private init() {
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: CGSize(width: 760, height: 580)), styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: false)
        super.init(window: window)
        window.title = "Settings"
        window.toolbarStyle = .automatic
        window.isMovableByWindowBackground = true
        window.setFrameAutosaveName("NetSpeedSettings")
        window.minSize = NSSize(width: 680, height: 500)
        window.contentViewController = NSHostingController(rootView: SettingsView())
        window.delegate = self
        window.center()
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func showWindow(_ sender: Any?) {
        AppActivationPolicy.enter()
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        Self.shared = nil
        AppActivationPolicy.leave()
    }
}
