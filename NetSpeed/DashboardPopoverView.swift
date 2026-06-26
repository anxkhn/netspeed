import Charts
import SwiftUI

struct DashboardPopoverView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var monitor = NetworkMonitor.shared
    @State private var connection = ConnectionMonitor.shared
    @AppStorage(AppDefaults.unit) private var unitRaw = SpeedUnit.autoBytes.rawValue
    @AppStorage(AppDefaults.showUnitLabels) private var showUnitLabels = true

    private var unit: SpeedUnit { SpeedUnit(rawValue: unitRaw) ?? .bytes }

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            header
            HStack(spacing: 10) {
                SpeedCard(title: "Download", value: speed(monitor.current.downloadBytesPerSecond), color: .blue)
                SpeedCard(title: "Upload", value: speed(monitor.current.uploadBytesPerSecond), color: .pink)
            }
            MiniChart(samples: monitor.samples, unit: unit, showsUnitLabels: showUnitLabels)
                .frame(height: 124)
            infoRows
            Divider().opacity(0.45)
            actionRows
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(width: 348)
        .background(.regularMaterial)
        .preferredColorScheme(AppTheme(rawValue: UserDefaults.standard.string(forKey: AppDefaults.appTheme) ?? "")?.colorScheme)
        .animation(reduceMotion ? nil : .snappy(duration: 0.18), value: monitor.current.downloadBytesPerSecond)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text("NetSpeed")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("\(connection.status) · \(connection.localIPAddress)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "globe")
                .font(.system(size: 26, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
        }
    }

    private var infoRows: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
            DashboardRow(title: "Session", value: "↓ \(SpeedFormatter.bytes(monitor.sessionTotals.downloaded))  ↑ \(SpeedFormatter.bytes(monitor.sessionTotals.uploaded))")
            DashboardRow(title: "Interface", value: monitor.current.interfaceName)
            DashboardRow(title: "Public IP", value: connection.publicIPAddress)
        }
        .font(.system(size: 12, weight: .semibold, design: .rounded))
    }

    private var actionRows: some View {
        VStack(spacing: 4) {
            MenuActionRow(title: "Visualizer", symbol: "chart.xyaxis.line") { VisualizerWindowController.show() }
            MenuActionRow(title: "Settings...", symbol: "gearshape", trailing: "⌘,") { SettingsWindowController.show(tab: .general) }
            MenuActionRow(title: "Refresh", symbol: "arrow.clockwise") { ConnectionMonitor.shared.refreshPublicIPIfNeeded() }
            MenuActionRow(title: "Quit", symbol: "xmark.square", trailing: "⌘Q") { NSApp.terminate(nil) }
        }
    }

    private func speed(_ bytes: UInt64) -> String {
        SpeedFormatter.speedValue(bytes, unit: unit, showsUnit: showUnitLabels)
    }
}

private struct DashboardRow: View {
    let title: String
    let value: String
    var body: some View {
        GridRow {
            Text(title).foregroundStyle(.secondary).frame(width: 66, alignment: .leading)
            Text(value).lineLimit(1).truncationMode(.middle)
        }
    }
}

private struct SpeedCard: View {
    let title: String
    let value: String
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundStyle(.secondary)
            Text(value).font(.system(size: 20, weight: .bold, design: .rounded)).monospacedDigit().lineLimit(1).minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
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

struct MiniChart: View {
    let samples: [NetworkSample]
    let unit: SpeedUnit
    let showsUnitLabels: Bool

    var body: some View {
        Chart(samples.suffix(90)) { sample in
            AreaMark(x: .value("Time", sample.timestamp), y: .value("Download", scaled(sample.downloadBytesPerSecond)))
                .foregroundStyle(.blue.opacity(0.12))
                .interpolationMethod(.catmullRom)
            LineMark(x: .value("Time", sample.timestamp), y: .value("Download", scaled(sample.downloadBytesPerSecond)))
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            LineMark(x: .value("Time", sample.timestamp), y: .value("Upload", scaled(sample.uploadBytesPerSecond)))
                .foregroundStyle(.pink.opacity(0.9))
                .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .minute)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6, dash: [4, 5])).foregroundStyle(.secondary.opacity(0.28))
                AxisValueLabel(anchor: .top) {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.hour().minute())
                            .font(.caption2.monospacedDigit())
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { value in
                AxisGridLine().foregroundStyle(.secondary.opacity(0.28))
                AxisValueLabel {
                    if let v = value.as(Double.self) { Text(label(v)).font(.caption2.monospacedDigit()) }
                }
            }
        }
    }

    private func scaled(_ bytes: UInt64) -> Double { Double(bytes) * (unit.isBitBased ? 8 : 1) }
    private func label(_ value: Double) -> String {
        SpeedFormatter.speedValue(UInt64(value / (unit.isBitBased ? 8 : 1)), unit: unit, showsUnit: showsUnitLabels)
    }
}
