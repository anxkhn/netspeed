import SwiftUI

struct DashboardPopoverView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var monitor = NetworkMonitor.shared
    @AppStorage(AppDefaults.unit) private var unitRaw = SpeedUnit.autoBytes.rawValue
    @AppStorage(AppDefaults.showUnitLabels) private var showUnitLabels = true

    private var unit: SpeedUnit { SpeedUnit(rawValue: unitRaw) ?? .autoBytes }
    private var lastHour: NetworkTotals { monitor.totals(since: Date().addingTimeInterval(-3_600)) }
    private var lastSixHours: NetworkTotals { monitor.totals(since: Date().addingTimeInterval(-21_600)) }
    private var today: NetworkTotals { monitor.todayTotals }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LiveSpeedBlock(
                download: speed(monitor.current.downloadBytesPerSecond),
                upload: speed(monitor.current.uploadBytesPerSecond)
            )

            Divider().opacity(0.45)

            VStack(spacing: 7) {
                UsageLine(title: "Last hour", totals: lastHour)
                UsageLine(title: "Last 6 hours", totals: lastSixHours)
                UsageLine(title: "Today", totals: today)
            }

            Divider().opacity(0.45)
            actionRows
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(width: 318)
        .background(.regularMaterial)
        .preferredColorScheme(AppTheme(rawValue: UserDefaults.standard.string(forKey: AppDefaults.appTheme) ?? "")?.colorScheme)
        .animation(reduceMotion ? nil : .snappy(duration: 0.16), value: monitor.current.downloadBytesPerSecond)
    }

    private var actionRows: some View {
        VStack(spacing: 4) {
            MenuActionRow(title: "Open Visualizer", symbol: "chart.xyaxis.line") { VisualizerWindowController.show() }
            MenuActionRow(title: "Settings...", symbol: "gearshape", trailing: "⌘,") { SettingsWindowController.show(tab: .general) }
            Divider().opacity(0.35)
            MenuActionRow(title: "Quit", symbol: "xmark.square", trailing: "⌘Q") { NSApp.terminate(nil) }
        }
    }

    private func speed(_ bytes: UInt64) -> String {
        SpeedFormatter.speedValue(bytes, unit: unit, showsUnit: showUnitLabels)
    }
}

private struct LiveSpeedBlock: View {
    let download: String
    let upload: String

    var body: some View {
        VStack(spacing: 8) {
            LiveSpeedRow(symbol: "arrow.down", title: "Download", value: download, color: .blue)
            LiveSpeedRow(symbol: "arrow.up", title: "Upload", value: upload, color: .pink)
        }
    }
}

private struct LiveSpeedRow: View {
    let symbol: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(color)
                .font(.system(size: 13, weight: .bold))
                .frame(width: 18)
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 72, alignment: .leading)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
    }
}

private struct UsageLine: View {
    let title: String
    let totals: NetworkTotals

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 78, alignment: .leading)
            Spacer(minLength: 8)
            Text("↓ \(SpeedFormatter.bytes(totals.downloaded))")
                .monospacedDigit()
            Text("↑ \(SpeedFormatter.bytes(totals.uploaded))")
                .monospacedDigit()
        }
        .font(.caption)
    }
}

private struct MenuActionRow: View {
    let title: String
    let symbol: String
    var trailing: String = ""
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol).frame(width: 20)
                Text(title).font(.system(size: 14, weight: .semibold, design: .rounded))
                Spacer()
                if !trailing.isEmpty { Text(trailing).foregroundStyle(.tertiary).font(.system(size: 14, weight: .semibold, design: .rounded)) }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
        }
        .buttonStyle(.plain)
    }
}
