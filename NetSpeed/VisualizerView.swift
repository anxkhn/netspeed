import Charts
import SwiftUI

struct VisualizerView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var monitor = NetworkMonitor.shared
    @State private var connection = ConnectionMonitor.shared
    @AppStorage(AppDefaults.unit) private var unitRaw = SpeedUnit.autoBytes.rawValue
    @AppStorage(AppDefaults.showUnitLabels) private var showUnitLabels = true
    @State private var showUpload = true
    @State private var showDownload = true

    private var unit: SpeedUnit { SpeedUnit(rawValue: unitRaw) ?? .bytes }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live Traffic").font(.largeTitle.bold())
                    Text("\(connection.status) · \(connection.localIPAddress) · \(monitor.current.interfaceName)").foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("Download", isOn: $showDownload).toggleStyle(.checkbox)
                Toggle("Upload", isOn: $showUpload).toggleStyle(.checkbox)
            }

            Chart(monitor.samples) { sample in
                if showDownload {
                    AreaMark(x: .value("Time", sample.timestamp), y: .value("Download", scaled(sample.downloadBytesPerSecond)))
                        .foregroundStyle(.blue.opacity(0.16))
                        .interpolationMethod(.catmullRom)
                    LineMark(x: .value("Time", sample.timestamp), y: .value("Download", scaled(sample.downloadBytesPerSecond)))
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                }
                if showUpload {
                    LineMark(x: .value("Time", sample.timestamp), y: .value("Upload", scaled(sample.uploadBytesPerSecond)))
                        .foregroundStyle(.pink)
                        .lineStyle(StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .minute)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6, dash: [4, 5]))
                    AxisValueLabel {
                        if let date = value.as(Date.self) { Text(date, format: .dateTime.hour().minute()).font(.caption.monospacedDigit()) }
                    }
                }
            }
            .chartYAxis { AxisMarks { value in AxisGridLine(); AxisValueLabel { if let v = value.as(Double.self) { Text(label(v)) } } } }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 24) {
                StatBlock(title: "Download now", value: SpeedFormatter.speed(monitor.current.downloadBytesPerSecond, unit: unit))
                StatBlock(title: "Upload now", value: SpeedFormatter.speed(monitor.current.uploadBytesPerSecond, unit: unit))
                StatBlock(title: "Session total", value: "↓ \(SpeedFormatter.bytes(monitor.sessionTotals.downloaded))  ↑ \(SpeedFormatter.bytes(monitor.sessionTotals.uploaded))")
                Spacer()
                Button("Reset Session") { monitor.resetSession() }
            }
        }
        .padding(24)
        .background(.regularMaterial)
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: monitor.samples.count)
    }

    private func scaled(_ bytes: UInt64) -> Double { Double(bytes) * (unit.isBitBased ? 8 : 1) }
    private func label(_ value: Double) -> String { SpeedFormatter.speedValue(UInt64(value / (unit.isBitBased ? 8 : 1)), unit: unit, showsUnit: showUnitLabels) }
}

private struct StatBlock: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline).monospacedDigit()
        }
    }
}
