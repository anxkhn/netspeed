import AppKit
import Charts
import SwiftUI

struct GeneralSettingsPane: View {
    @AppStorage(AppDefaults.onboardingCompleted) private var onboardingCompleted = false
    @State private var launchAtLogin = LaunchAtLoginManager.isEnabled
    @State private var launchError: String?

    var body: some View {
        Form {
            Section("System") {
                Toggle(isOn: Binding(get: { launchAtLogin }, set: { enabled in setLaunchAtLogin(enabled) })) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Launch at Login")
                        Text("Start NetSpeed automatically when you sign in.").font(.caption).foregroundStyle(.secondary)
                    }
                }.toggleStyle(.switch)
                if let launchError { Text(launchError).font(.caption).foregroundStyle(.red) }
            }
            Section("Setup") {
                LabeledContent {
                    Button("Open Onboarding") { onboardingCompleted = false; OnboardingWindowController.show() }
                        .controlSize(.small)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Onboarding")
                        Text("Review startup, notifications, public IP display, and app window basics.").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }.settingsForm()
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do { try LaunchAtLoginManager.setEnabled(enabled); launchAtLogin = LaunchAtLoginManager.isEnabled; launchError = nil }
        catch { launchError = error.localizedDescription; launchAtLogin = LaunchAtLoginManager.isEnabled }
    }
}

struct MenuBarSettingsPane: View {
    @AppStorage(AppDefaults.menuBarLayout) private var menuBarLayout = MenuBarLayout.stacked.rawValue
    @AppStorage(AppDefaults.menuBarArrowPosition) private var arrowPosition = MenuBarArrowPosition.left.rawValue
    @AppStorage(AppDefaults.showUnitLabels) private var showUnitLabels = true
    @AppStorage(AppDefaults.menuBarFontMode) private var fontMode = MenuBarFontMode.condensed.rawValue
    @AppStorage(AppDefaults.menuBarFontName) private var customFontName = ""
    @AppStorage(AppDefaults.menuBarFontSize) private var fontSize = 9.0
    @AppStorage(AppDefaults.menuBarFontWidth) private var fontWidth = 0.82
    @AppStorage(AppDefaults.menuBarFontWeight) private var fontWeight = 0.0
    @AppStorage(AppDefaults.stabilizeMenuBarWidth) private var stabilizeMenuBarWidth = true
    @AppStorage(AppDefaults.smoothMenuBarTransitions) private var smoothMenuBarTransitions = true
    @AppStorage(AppDefaults.unit) private var unit = SpeedUnit.autoBytes.rawValue

    var body: some View {
        Form {
            Section("Preview") {
                MenuBarFontPreview()
            }

            Section("Content") {
                Picker("Layout", selection: $menuBarLayout) {
                    ForEach(MenuBarLayout.allCases) { Text($0.title).tag($0.rawValue) }
                }
                .pickerStyle(.segmented)

                Picker("Arrow", selection: $arrowPosition) {
                    ForEach(MenuBarArrowPosition.allCases) { Text($0.title).tag($0.rawValue) }
                }
                .pickerStyle(.menu)

                Picker("Units", selection: $unit) {
                    Section("Automatic") {
                        Text(SpeedUnit.autoBytes.title).tag(SpeedUnit.autoBytes.rawValue)
                        Text(SpeedUnit.autoBits.title).tag(SpeedUnit.autoBits.rawValue)
                    }
                    Section("Bytes") {
                        Text(SpeedUnit.bytes.title).tag(SpeedUnit.bytes.rawValue)
                        Text(SpeedUnit.kilobytes.title).tag(SpeedUnit.kilobytes.rawValue)
                        Text(SpeedUnit.megabytes.title).tag(SpeedUnit.megabytes.rawValue)
                        Text(SpeedUnit.gigabytes.title).tag(SpeedUnit.gigabytes.rawValue)
                    }
                    Section("Bits") {
                        Text(SpeedUnit.bits.title).tag(SpeedUnit.bits.rawValue)
                        Text(SpeedUnit.kilobits.title).tag(SpeedUnit.kilobits.rawValue)
                        Text(SpeedUnit.megabits.title).tag(SpeedUnit.megabits.rawValue)
                        Text(SpeedUnit.gigabits.title).tag(SpeedUnit.gigabits.rawValue)
                    }
                }
                .pickerStyle(.menu)

                Toggle("Show unit labels", isOn: $showUnitLabels).toggleStyle(.switch)
            }

            Section("Typography") {
                Picker("Font", selection: $fontMode) {
                    ForEach(MenuBarFontMode.allCases) { Text($0.title).tag($0.rawValue) }
                }
                .pickerStyle(.menu)

                LabeledContent("Size") {
                    Slider(value: $fontSize, in: 7...15, step: 0.5).frame(width: 180)
                    Text("\(fontSize, specifier: "%.1f") pt").monospacedDigit().foregroundStyle(.secondary).frame(width: 58, alignment: .trailing)
                }

                LabeledContent("Width") {
                    Slider(value: $fontWidth, in: 0.55...1.0, step: 0.01).frame(width: 180)
                    Text("\(Int(fontWidth * 100))%").monospacedDigit().foregroundStyle(.secondary).frame(width: 58, alignment: .trailing)
                }

                Toggle("Bold", isOn: Binding(get: { fontWeight >= 0.5 }, set: { fontWeight = $0 ? 1.0 : 0.0 })).toggleStyle(.switch)

                if MenuBarFontMode(rawValue: fontMode) == .condensed {
                    Text("Condensed uses a built-in macOS typeface. Width can compress it further for tighter menu bar layouts.").font(.caption).foregroundStyle(.secondary)
                }

                LabeledContent("Custom font") {
                    HStack(spacing: 8) {
                        if !customFontName.isEmpty { Text(customFontName).font(.caption).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle) }
                        Button("Choose...") { FontPickerController.shared.show() }.controlSize(.small)
                    }
                }
            }

            Section("Behavior") {
                Toggle("Keep width stable", isOn: $stabilizeMenuBarWidth).toggleStyle(.switch)
                Toggle("Fade speed changes", isOn: $smoothMenuBarTransitions).toggleStyle(.switch)
                Text("Fade transitions are automatically disabled when Reduce Motion is enabled in macOS.").font(.caption).foregroundStyle(.secondary)
            }
        }.settingsForm()
    }
}

private struct MenuBarFontPreview: View {
    @AppStorage(AppDefaults.menuBarLayout) private var layout = MenuBarLayout.stacked.rawValue
    @AppStorage(AppDefaults.menuBarArrowPosition) private var arrowPosition = MenuBarArrowPosition.left.rawValue
    @AppStorage(AppDefaults.unit) private var unitRaw = SpeedUnit.autoBytes.rawValue
    @AppStorage(AppDefaults.showUnitLabels) private var showUnitLabels = true
    @AppStorage(AppDefaults.menuBarFontMode) private var fontMode = MenuBarFontMode.condensed.rawValue
    @AppStorage(AppDefaults.menuBarFontName) private var customFontName = ""
    @AppStorage(AppDefaults.menuBarFontSize) private var fontSize = 9.0
    @AppStorage(AppDefaults.menuBarFontWidth) private var fontWidth = 0.82
    @AppStorage(AppDefaults.menuBarFontWeight) private var fontWeight = 0.0

    private var unit: SpeedUnit { SpeedUnit(rawValue: unitRaw) ?? .bytes }
    private var up: String { SpeedFormatter.speedValue(815 * 1024, unit: unit, showsUnit: showUnitLabels) }
    private var down: String { SpeedFormatter.speedValue(18 * 1024 * 1024, unit: unit, showsUnit: showUnitLabels) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview").font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Image(systemName: "menubar.rectangle")
                    .foregroundStyle(.secondary)
                previewText
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.78), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
        }
        .id("\(layout)-\(arrowPosition)-\(unitRaw)-\(showUnitLabels)-\(fontMode)-\(customFontName)-\(fontSize)-\(fontWidth)-\(fontWeight)")
    }

    @ViewBuilder
    private var previewText: some View {
        let mode = MenuBarLayout(rawValue: layout) ?? .stacked
        switch mode {
        case .stacked:
            VStack(alignment: .trailing, spacing: -3) {
                Text(compose(speed: up, arrow: "↑"))
                Text(compose(speed: down, arrow: "↓"))
            }
            .font(MenuBarFont.swiftUIFont(size: fontSize))
            .foregroundStyle(.white)
            .monospacedDigit()
            .lineLimit(1)
        case .compact:
            Text("\(compose(speed: down, arrow: "↓"))  \(compose(speed: up, arrow: "↑"))")
                .font(MenuBarFont.swiftUIFont(size: max(10, fontSize)))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
        case .downloadOnly:
            Text(compose(speed: down, arrow: "↓"))
                .font(MenuBarFont.swiftUIFont(size: max(10, fontSize)))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
        }
    }

    private func compose(speed: String, arrow: String) -> String {
        switch MenuBarArrowPosition(rawValue: arrowPosition) ?? .left {
        case .hidden: speed
        case .left: "\(arrow) \(speed)"
        case .right: "\(speed) \(arrow)"
        }
    }
}

struct AppearanceSettingsPane: View {
    @AppStorage(AppDefaults.appTheme) private var theme = AppTheme.system.rawValue
    @AppStorage(AppDefaults.accentColorName) private var accent = "blue"
    @AppStorage(AppDefaults.surfaceStyle) private var surfaceStyle = SurfaceStyle.system.rawValue
    var body: some View {
        Form {
            Section("Window Appearance") {
                Picker("Theme", selection: $theme) { ForEach(AppTheme.allCases) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.segmented)
                Picker("Surface", selection: $surfaceStyle) { ForEach(SurfaceStyle.allCases) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.segmented)
                Text("System respects macOS accessibility settings. Opaque improves contrast when transparency is distracting.").font(.caption).foregroundStyle(.secondary)
            }
            Section("Charts") { Picker("Accent", selection: $accent) { Text("Blue").tag("blue"); Text("Pink").tag("pink"); Text("Green").tag("green"); Text("Orange").tag("orange") }.pickerStyle(.segmented) }
        }.settingsForm()
    }
}

struct NetworkSettingsPane: View {
    @State private var connection = ConnectionMonitor.shared
    @AppStorage(AppDefaults.showInterfaceName) private var showInterfaceName = true
    @AppStorage(AppDefaults.showPublicIP) private var showPublicIP = false
    @AppStorage(AppDefaults.sampleInterval) private var sampleInterval = 1.0
    var body: some View {
        Form {
            Section("Current Connection") {
                LabeledContent("Status", value: connection.status)
                LabeledContent("Interface", value: connection.interface)
                LabeledContent("Local IP", value: connection.localIPAddress)
                LabeledContent("Public IP", value: connection.publicIPAddress)
                Button("Refresh Public IP") { connection.refreshPublicIPIfNeeded() }.controlSize(.small)
            }
            Section("Displayed Data") {
                Toggle("Show interface names", isOn: $showInterfaceName).toggleStyle(.switch)
                Toggle("Fetch public IP address", isOn: $showPublicIP).toggleStyle(.switch).onChange(of: showPublicIP) { _, _ in connection.refreshPublicIPIfNeeded() }
            }
            Section("Sampling") {
                LabeledContent("Sample interval") { Slider(value: $sampleInterval, in: 0.5...5, step: 0.5).frame(width: 180); Text("\(sampleInterval, specifier: "%.1f")s").monospacedDigit() }
                Button("Restart Monitor") { NetworkMonitor.shared.start(interval: sampleInterval) }.controlSize(.small)
            }
        }.settingsForm()
    }
}

struct AlertsSettingsPane: View {
    @AppStorage(AppDefaults.alertEnabled) private var enabled = false
    @AppStorage(AppDefaults.downloadAlertMBps) private var download = 50.0
    @AppStorage(AppDefaults.uploadAlertMBps) private var upload = 10.0
    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Notify on traffic spikes", isOn: $enabled).toggleStyle(.switch)
                Button("Request Notification Permission") { AlertManager.shared.requestAuthorization() }.controlSize(.small)
            }
            Section("Thresholds") {
                LabeledContent("Download threshold") { Slider(value: $download, in: 1...500, step: 1).frame(width: 180); Text("\(Int(download)) MB/s").monospacedDigit() }
                LabeledContent("Upload threshold") { Slider(value: $upload, in: 1...500, step: 1).frame(width: 180); Text("\(Int(upload)) MB/s").monospacedDigit() }
            }
        }.settingsForm()
    }
}

struct HistorySettingsPane: View {
    @State private var store = UsageHistoryStore.shared
    @AppStorage(AppDefaults.historyRetentionDays) private var retention = 30
    @State private var exportMessage: String?
    var body: some View {
        Form {
            Section("Overview") {
                UsageSummaryView(rows: usageRows)
            }
            Section("Trend") {
                UsageHistoryChart(rows: usageRows)
                    .frame(height: 180)
            }
            Section("Storage") { Stepper("Keep \(retention) days", value: $retention, in: 1...365) }
            Section("Usage") {
                ForEach(usageRows) { row in
                    LabeledContent(row.date, value: row.value)
                }
                if store.dailyTotals.isEmpty { Text("No history yet.").foregroundStyle(.secondary) }
            }
            Section("Export") {
                LabeledContent("Data") {
                    HStack(spacing: 8) {
                        Button("Export CSV") { export(kind: "csv") }.controlSize(.small)
                        Button("Export JSON") { export(kind: "json") }.controlSize(.small)
                    }
                }
                LabeledContent("Reset") {
                    Button("Clear History", role: .destructive) { store.clear() }.controlSize(.small)
                }
                if let exportMessage { Text(exportMessage).font(.caption).foregroundStyle(.secondary) }
            }
        }.settingsForm()
    }
    private func export(kind: String) {
        do {
            let url = try kind == "csv" ? store.exportCSV() : store.exportJSON()
            NSWorkspace.shared.activateFileViewerSelecting([url])
            exportMessage = "Exported to \(url.lastPathComponent)"
        } catch { exportMessage = error.localizedDescription }
    }

    private var usageRows: [UsageRow] {
        store.dailyTotals.keys.sorted().map { day in
            let totals = store.dailyTotals[day, default: NetworkTotals()]
            return UsageRow(
                date: day.formatted(date: .abbreviated, time: .omitted),
                rawDate: day,
                uploaded: totals.uploaded,
                downloaded: totals.downloaded,
                value: "↓ \(SpeedFormatter.bytes(totals.downloaded))  ↑ \(SpeedFormatter.bytes(totals.uploaded))"
            )
        }
    }
}

private struct UsageRow: Identifiable {
    let id = UUID()
    let date: String
    let rawDate: Date
    let uploaded: UInt64
    let downloaded: UInt64
    let value: String
    var total: UInt64 { uploaded + downloaded }
}

private struct UsageSummaryView: View {
    let rows: [UsageRow]
    private var totalDownloaded: UInt64 { rows.reduce(0) { $0 + $1.downloaded } }
    private var totalUploaded: UInt64 { rows.reduce(0) { $0 + $1.uploaded } }
    private var total: UInt64 { totalDownloaded + totalUploaded }
    private var downloadFraction: Double { total == 0 ? 0 : Double(totalDownloaded) / Double(total) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                LabeledContent("Downloaded", value: SpeedFormatter.bytes(totalDownloaded))
                LabeledContent("Uploaded", value: SpeedFormatter.bytes(totalUploaded))
            }
            ProgressView(value: downloadFraction)
            Text(total == 0 ? "No recorded traffic yet." : "Download is \(Int(downloadFraction * 100))% of recorded usage.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct UsageHistoryChart: View {
    let rows: [UsageRow]

    var body: some View {
        if rows.isEmpty {
            ContentUnavailableView("No History", systemImage: "chart.bar.xaxis", description: Text("Usage totals appear here after NetSpeed records traffic."))
        } else {
            Chart(rows) { row in
                BarMark(x: .value("Day", row.rawDate), y: .value("Downloaded", row.downloaded))
                    .foregroundStyle(.blue.opacity(0.78))
                BarMark(x: .value("Day", row.rawDate), y: .value("Uploaded", row.uploaded))
                    .foregroundStyle(.pink.opacity(0.72))
            }
            .chartYAxis { AxisMarks { value in AxisGridLine(); AxisValueLabel { if let bytes = value.as(UInt64.self) { Text(SpeedFormatter.bytes(bytes)) } } } }
        }
    }
}

struct UpdatesSettingsPane: View {
    @ObservedObject private var updater = UpdaterManager.shared
    var body: some View {
        Form {
            Section("Sparkle") {
                Toggle("Automatically check for updates", isOn: Binding(
                    get: { updater.automaticallyChecksForUpdates },
                    set: { updater.automaticallyChecksForUpdates = $0 }
                ))
                .toggleStyle(.switch)
                Button("Check for Updates...") { updater.checkForUpdates() }.disabled(!updater.canCheckForUpdates)
                Text("Debug builds disable update checks. Release builds use the appcast configured in Info.plist.").font(.caption).foregroundStyle(.secondary)
            }
        }.settingsForm()
    }
}

struct AboutSettingsPane: View {
    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 72, height: 72)
                    VStack(alignment: .leading, spacing: 5) { Text("NetSpeed").font(.largeTitle.bold()); Text("A menu bar network monitor for macOS.").foregroundStyle(.secondary); Text("Copyright (C) 2026 anxkhn").font(.caption).foregroundStyle(.tertiary) }
                }
            }
            Section("Project") {
                Link("GitHub", destination: URL(string: "https://github.com/anxkhn/netspeed")!)
                Link("GPLv3 License", destination: URL(string: "https://www.gnu.org/licenses/gpl-3.0.html")!)
            }
        }.settingsForm()
    }
}

private extension View {
    func settingsForm() -> some View { modifier(SettingsFormModifier()) }
}

private struct SettingsFormModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 8, for: .scrollContent)
    }
}
