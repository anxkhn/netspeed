import AppKit
import SwiftUI

@MainActor
final class StatusItemController: NSObject, NSPopoverDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private var updateTask: Task<Void, Never>?
    private var lastRenderedTitle = ""

    override init() {
        super.init()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 348, height: 410)
        popover.delegate = self
        popover.contentViewController = NSHostingController(rootView: DashboardPopoverView())

        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem.button?.wantsLayer = true
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
        let arrowPosition = MenuBarArrowPosition(rawValue: UserDefaults.standard.string(forKey: AppDefaults.menuBarArrowPosition) ?? "") ?? .left
        let showUnits = UserDefaults.standard.bool(forKey: AppDefaults.showUnitLabels)
        let up = SpeedFormatter.speedValue(sample.uploadBytesPerSecond, unit: unit, showsUnit: showUnits)
        let down = SpeedFormatter.speedValue(sample.downloadBytesPerSecond, unit: unit, showsUnit: showUnits)
        let font = MenuBarFont.nsFont(size: layout == .stacked ? nil : max(10, UserDefaults.standard.double(forKey: AppDefaults.menuBarFontSize)))
        button.image = nil
        updateReservedWidth(layout: layout, unit: unit, showsUnit: showUnits, arrowPosition: arrowPosition, font: font)

        switch layout {
        case .stacked:
            let title = stackedTitle(up: up, down: down, arrowPosition: arrowPosition)
            apply(title: title, renderKey: title.string)
        case .compact:
            let text = compose(speed: down, arrow: "↓", position: arrowPosition) + "  " + compose(speed: up, arrow: "↑", position: arrowPosition)
            apply(title: singleLineTitle(text, font: font), renderKey: text)
        case .downloadOnly:
            let text = compose(speed: down, arrow: "↓", position: arrowPosition)
            apply(title: singleLineTitle(text, font: font), renderKey: text)
        }
    }

    private func apply(title: NSAttributedString, renderKey: String) {
        guard let button = statusItem.button else { return }
        if shouldFadeTransition(to: renderKey) {
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.16
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            button.layer?.add(transition, forKey: "netspeed-title-fade")
        }
        button.attributedTitle = title
        lastRenderedTitle = renderKey
    }

    private func shouldFadeTransition(to renderKey: String) -> Bool {
        guard lastRenderedTitle != renderKey else { return false }
        guard UserDefaults.standard.bool(forKey: AppDefaults.smoothMenuBarTransitions) else { return false }
        return !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    private func stackedTitle(up: String, down: String, arrowPosition: MenuBarArrowPosition) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        style.lineHeightMultiple = 0.72
        let base: [NSAttributedString.Key: Any] = [.font: MenuBarFont.nsFont(), .foregroundColor: NSColor.labelColor, .paragraphStyle: style]
        let output = NSMutableAttributedString(string: "\(compose(speed: up, arrow: "↑", position: arrowPosition))\n", attributes: base)
        var lower = base
        lower[.baselineOffset] = -5
        output.append(NSAttributedString(string: compose(speed: down, arrow: "↓", position: arrowPosition), attributes: lower))
        return output
    }

    private func singleLineTitle(_ text: String, font: NSFont) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: NSColor.labelColor,
        ])
    }

    private func compose(speed: String, arrow: String, position: MenuBarArrowPosition) -> String {
        switch position {
        case .hidden: speed
        case .left: "\(arrow) \(speed)"
        case .right: "\(speed) \(arrow)"
        }
    }

    private func updateReservedWidth(layout: MenuBarLayout, unit: SpeedUnit, showsUnit: Bool, arrowPosition: MenuBarArrowPosition, font: NSFont) {
        guard UserDefaults.standard.bool(forKey: AppDefaults.stabilizeMenuBarWidth) else {
            statusItem.length = NSStatusItem.variableLength
            return
        }

        let referenceDown = referenceSpeed(unit: unit, showsUnit: showsUnit)
        let referenceUp = referenceSpeed(unit: unit, showsUnit: showsUnit)
        let text: String
        switch layout {
        case .stacked:
            text = maxWidthLine(compose(speed: referenceUp, arrow: "↑", position: arrowPosition), compose(speed: referenceDown, arrow: "↓", position: arrowPosition))
        case .compact:
            text = compose(speed: referenceDown, arrow: "↓", position: arrowPosition) + "  " + compose(speed: referenceUp, arrow: "↑", position: arrowPosition)
        case .downloadOnly:
            text = compose(speed: referenceDown, arrow: "↓", position: arrowPosition)
        }

        let width = ceil((text as NSString).size(withAttributes: [.font: font]).width)
        let padding: CGFloat = layout == .stacked ? 12 : 18
        statusItem.length = max(44, width + padding)
    }

    private func referenceSpeed(unit: SpeedUnit, showsUnit: Bool) -> String {
        let bytes: UInt64
        switch unit {
        case .bytes, .bits:
            bytes = 999
        case .kilobytes, .kilobits:
            bytes = 999 * 1024
        case .megabytes, .megabits, .autoBytes, .autoBits:
            bytes = 999 * 1024 * 1024
        case .gigabytes, .gigabits:
            bytes = 99 * 1024 * 1024 * 1024
        }
        return SpeedFormatter.speedValue(bytes, unit: unit, showsUnit: showsUnit)
    }

    private func maxWidthLine(_ first: String, _ second: String) -> String {
        let font = MenuBarFont.nsFont()
        let firstWidth = (first as NSString).size(withAttributes: [.font: font]).width
        let secondWidth = (second as NSString).size(withAttributes: [.font: font]).width
        return firstWidth >= secondWidth ? first : second
    }
}
