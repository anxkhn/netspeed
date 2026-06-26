import AppKit
import SwiftUI

@MainActor
final class StatusItemController: NSObject, NSPopoverDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private var updateTask: Task<Void, Never>?

    override init() {
        super.init()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 390, height: 430)
        popover.delegate = self
        popover.contentViewController = NSHostingController(rootView: DashboardPopoverView())

        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        updateTitle()
        updateTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { self?.updateTitle() }
            }
        }
    }

    deinit { updateTask?.cancel() }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown { popover.performClose(nil) }
        else { popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY) }
    }

    private func updateTitle() {
        guard let button = statusItem.button else { return }
        let sample = NetworkMonitor.shared.current
        let unit = SpeedUnit(rawValue: UserDefaults.standard.string(forKey: AppDefaults.unit) ?? "") ?? .bytes
        let layout = MenuBarLayout(rawValue: UserDefaults.standard.string(forKey: AppDefaults.menuBarLayout) ?? "") ?? .stacked
        let up = SpeedFormatter.speed(sample.uploadBytesPerSecond, unit: unit)
        let down = SpeedFormatter.speed(sample.downloadBytesPerSecond, unit: unit)

        switch layout {
        case .stacked:
            button.attributedTitle = stackedTitle(up: up, down: down)
        case .compact:
            button.title = "↓ \(down)  ↑ \(up)"
        case .downloadOnly:
            button.title = "↓ \(down)"
        }
    }

    private func stackedTitle(up: String, down: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        style.lineHeightMultiple = 0.72
        let base: [NSAttributedString.Key: Any] = [.font: NSFont.monospacedDigitSystemFont(ofSize: 9, weight: .medium), .foregroundColor: NSColor.labelColor, .paragraphStyle: style]
        let output = NSMutableAttributedString(string: "↑ \(up)\n", attributes: base)
        var lower = base
        lower[.baselineOffset] = -5
        output.append(NSAttributedString(string: "↓ \(down)", attributes: lower))
        return output
    }
}
