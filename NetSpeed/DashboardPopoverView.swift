import Charts
import SwiftUI

struct DashboardPopoverView: View {
    @State private var monitor = NetworkMonitor.shared
    @State private var connection = ConnectionMonitor.shared
    @AppStorage(AppDefaults.unit) private var unitRaw = SpeedUnit.bytes.rawValue

    private var unit: SpeedUnit { SpeedUnit(rawValue: unitRaw) ?? .bytes }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NetSpeed").font(.title2.bold())
                    Text("\(connection.status) · \(connection.localIPAddress)").foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "network").font(.title).symbolRenderingMode(.hierarchical)
            }

            HStack(spacing: 12) {
                SpeedCard(title: "Download", value: SpeedFormatter.speed(monitor.current.downloadBytesPerSecond, unit: unit), color: .blue)
                SpeedCard(title: "Upload", value: SpeedFormatter.speed(monitor.current.uploadBytesPerSecond, unit: unit), color: .pink)
            }

            MiniChart(samples: monitor.samples, unit: unit).frame(height: 140)

            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 8) {
                GridRow { Text("Session").foregroundStyle(.secondary); Text("↓ \(SpeedFormatter.bytes(monitor.sessionTotals.downloaded))  ↑ \(SpeedFormatter.bytes(monitor.sessionTotals.uploaded))") }
                GridRow { Text("Interface").foregroundStyle(.secondary); Text(monitor.current.interfaceName).lineLimit(1).truncationMode(.middle) }
                GridRow { Text("Public IP").foregroundStyle(.secondary); Text(connection.publicIPAddress) }
            }.font(.caption)

            HStack {
                Button("Visualizer") { VisualizerWindowController.show() }
                Button("Settings") { SettingsWindowController.show(tab: .general) }.keyboardShortcut(",")
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
            }
        }
        .padding(18)
        .background(.regularMaterial)
        .preferredColorScheme(AppTheme(rawValue: UserDefaults.standard.string(forKey: AppDefaults.appTheme) ?? "")?.colorScheme)
    }
}

private struct SpeedCard: View {
    let title: String
    let value: String
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.system(.title3, design: .rounded, weight: .semibold)).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct MiniChart: View {
    let samples: [NetworkSample]
    let unit: SpeedUnit
    var body: some View {
        Chart(samples.suffix(90)) { sample in
            LineMark(x: .value("Time", sample.timestamp), y: .value("Download", scaled(sample.downloadBytesPerSecond)))
                .foregroundStyle(.blue)
            LineMark(x: .value("Time", sample.timestamp), y: .value("Upload", scaled(sample.uploadBytesPerSecond)))
                .foregroundStyle(.pink)
        }
        .chartYAxis { AxisMarks { value in AxisGridLine(); AxisValueLabel { if let v = value.as(Double.self) { Text(label(v)) } } } }
    }
    private func scaled(_ bytes: UInt64) -> Double { Double(bytes) * (unit == .bits ? 8 : 1) }
    private func label(_ value: Double) -> String { SpeedFormatter.speed(UInt64(value / (unit == .bits ? 8 : 1)), unit: unit) }
}
