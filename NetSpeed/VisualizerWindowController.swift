import AppKit
import SwiftUI

@MainActor
final class VisualizerWindowController: NSWindowController, NSWindowDelegate {
    private static var shared: VisualizerWindowController?

    static func show() {
        if shared == nil { shared = VisualizerWindowController() }
        shared?.showWindow(nil)
    }

    private init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 820, height: 540), styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: false)
        super.init(window: window)
        window.title = "NetSpeed Visualizer"
        window.titlebarAppearsTransparent = false
        window.toolbarStyle = .unifiedCompact
        window.minSize = NSSize(width: 680, height: 420)
        window.setFrameAutosaveName("NetSpeedVisualizer")
        window.contentViewController = NSHostingController(rootView: VisualizerView())
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
