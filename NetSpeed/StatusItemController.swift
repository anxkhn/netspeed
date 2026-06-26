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
        popover.contentSize = NSSize(width: 348, height: 410)
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
        let iconPosition = MenuBarIconPosition(rawValue: UserDefaults.standard.string(forKey: AppDefaults.menuBarIconPosition) ?? "") ?? .hidden
        let showUnits = UserDefaults.standard.bool(forKey: AppDefaults.showUnitLabels)
        let up = SpeedFormatter.speedValue(sample.uploadBytesPerSecond, unit: unit, showsUnit: showUnits)
        let down = SpeedFormatter.speedValue(sample.downloadBytesPerSecond, unit: unit, showsUnit: showUnits)
        let font = MenuBarFont.nsFont(size: layout == .stacked ? nil : max(10, UserDefaults.standard.double(forKey: AppDefaults.menuBarFontSize)))
        if iconPosition == .hidden {
            button.image = nil
        } else {
            let image = NSImage(systemSymbolName: "network", accessibilityDescription: "NetSpeed")
            image?.isTemplate = true
            button.image = image
            button.imagePosition = iconPosition == .left ? .imageLeft : .imageRight
        }

        switch layout {
        case .stacked:
            button.attributedTitle = stackedTitle(up: up, down: down)
        case .compact:
            button.attributedTitle = singleLineTitle("↓ \(down)  ↑ \(up)", font: font)
        case .downloadOnly:
            button.attributedTitle = singleLineTitle("↓ \(down)", font: font)
        }
    }

    private func stackedTitle(up: String, down: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        style.lineHeightMultiple = 0.72
        let base: [NSAttributedString.Key: Any] = [.font: MenuBarFont.nsFont(), .foregroundColor: NSColor.labelColor, .paragraphStyle: style]
        let output = NSMutableAttributedString(string: "↑ \(up)\n", attributes: base)
        var lower = base
        lower[.baselineOffset] = -5
        output.append(NSAttributedString(string: "↓ \(down)", attributes: lower))
        return output
    }

    private func singleLineTitle(_ text: String, font: NSFont) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: NSColor.labelColor,
        ])
    }
}
