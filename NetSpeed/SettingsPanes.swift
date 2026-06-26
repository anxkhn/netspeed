import AppKit
import SwiftUI

struct GeneralSettingsPane: View {
    @AppStorage(AppDefaults.menuBarLayout) private var menuBarLayout = MenuBarLayout.stacked.rawValue
    @AppStorage(AppDefaults.menuBarIconPosition) private var iconPosition = MenuBarIconPosition.hidden.rawValue
    @AppStorage(AppDefaults.showUnitLabels) private var showUnitLabels = true
    @AppStorage(AppDefaults.menuBarFontMode) private var fontMode = MenuBarFontMode.condensed.rawValue
    @AppStorage(AppDefaults.menuBarFontName) private var customFontName = ""
    @AppStorage(AppDefaults.menuBarFontSize) private var fontSize = 9.0
    @AppStorage(AppDefaults.stabilizeMenuBarWidth) private var stabilizeMenuBarWidth = true
    @AppStorage(AppDefaults.unit) private var unit = SpeedUnit.autoBytes.rawValue
    @State private var launchAtLogin = LaunchAtLoginManager.isEnabled
    @State private var launchError: String?

    var body: some View {
        Form {
            Section("Menu Bar") {
                Picker("Layout", selection: $menuBarLayout) { ForEach(MenuBarLayout.allCases) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.segmented)
                Picker("Icon position", selection: $iconPosition) { ForEach(MenuBarIconPosition.allCases) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.segmented)
                Picker("Units", selection: $unit) { ForEach(SpeedUnit.allCases) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.menu)
                Toggle("Show unit labels", isOn: $showUnitLabels).toggleStyle(.switch)
                Toggle("Keep menu bar width stable", isOn: $stabilizeMenuBarWidth).toggleStyle(.switch)
            }
            Section("Menu Bar Font") {
                Picker("Font", selection: $fontMode) { ForEach(MenuBarFontMode.allCases) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.segmented)
                LabeledContent("Size") { Slider(value: $fontSize, in: 7...15, step: 0.5).frame(width: 180); Text("\(fontSize, specifier: "%.1f") pt").monospacedDigit().foregroundStyle(.secondary).frame(width: 58, alignment: .trailing) }
                if MenuBarFontMode(rawValue: fontMode) == .condensed {
                    Text("Uses Avenir Next Condensed, a built-in macOS font with taller, narrower glyphs.").font(.caption).foregroundStyle(.secondary)
                }
                HStack(spacing: 8) {
                    Button("Choose Custom Font...") { FontPickerController.shared.show() }.controlSize(.small)
                    if !customFontName.isEmpty { Text(customFontName).font(.caption).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle) }
                }
                MenuBarFontPreview()
            }
            Section("System") {
                Toggle(isOn: Binding(get: { launchAtLogin }, set: { enabled in setLaunchAtLogin(enabled) })) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Launch at Login")
                        Text("Start NetSpeed automatically when you sign in.").font(.caption).foregroundStyle(.secondary)
                    }
                }.toggleStyle(.switch)
                if let launchError { Text(launchError).font(.caption).foregroundStyle(.red) }
            }
        }.settingsForm()
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do { try LaunchAtLoginManager.setEnabled(enabled); launchAtLogin = LaunchAtLoginManager.isEnabled; launchError = nil }
        catch { launchError = error.localizedDescription; launchAtLogin = LaunchAtLoginManager.isEnabled }
    }
}

private struct MenuBarFontPreview: View {
    @AppStorage(AppDefaults.menuBarLayout) private var layout = MenuBarLayout.stacked.rawValue
    @AppStorage(AppDefaults.unit) private var unitRaw = SpeedUnit.autoBytes.rawValue
    @AppStorage(AppDefaults.showUnitLabels) private var showUnitLabels = true
    @AppStorage(AppDefaults.menuBarFontMode) private var fontMode = MenuBarFontMode.condensed.rawValue
    @AppStorage(AppDefaults.menuBarFontName) private var customFontName = ""
    @AppStorage(AppDefaults.menuBarFontSize) private var fontSize = 9.0

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
        .id("\(layout)-\(unitRaw)-\(showUnitLabels)-\(fontMode)-\(customFontName)-\(fontSize)")
    }

    @ViewBuilder
    private var previewText: some View {
        let mode = MenuBarLayout(rawValue: layout) ?? .stacked
        switch mode {
        case .stacked:
            VStack(alignment: .trailing, spacing: -3) {
                Text("↑ \(up)")
                Text("↓ \(down)")
            }
            .font(MenuBarFont.swiftUIFont(size: fontSize))
            .foregroundStyle(.white)
            .monospacedDigit()
            .lineLimit(1)
        case .compact:
            Text("↓ \(down)  ↑ \(up)")
                .font(MenuBarFont.swiftUIFont(size: max(10, fontSize)))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
        case .downloadOnly:
            Text("↓ \(down)")
                .font(MenuBarFont.swiftUIFont(size: max(10, fontSize)))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
        }
    }
}

struct AppearanceSettingsPane: View {
    @AppStorage(AppDefaults.appTheme) private var theme = AppTheme.system.rawValue
    @AppStorage(AppDefaults.accentColorName) private var accent = "blue"
    @AppStorage(AppDefaults.surfaceStyle) private var surfaceStyle = SurfaceStyle.system.rawValue
    var body: some View {
        Form {
            Section("Theme") { Picker("Appearance", selection: $theme) { ForEach(AppTheme.allCases) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.segmented) }
            Section("Surface") {
                Picker("Material", selection: $surfaceStyle) { ForEach(SurfaceStyle.allCases) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.segmented)
                Text("System follows macOS Reduce Transparency. Transparent uses Liquid Glass where available; Opaque prefers contrast and legibility.").font(.caption).foregroundStyle(.secondary)
            }
            Section("Accent") { Picker("Chart Accent", selection: $accent) { Text("Blue").tag("blue"); Text("Pink").tag("pink"); Text("Green").tag("green"); Text("Orange").tag("orange") }.pickerStyle(.segmented) }
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
            Section("Connection") {
                LabeledContent("Status", value: connection.status)
                LabeledContent("Interface", value: connection.interface)
                LabeledContent("Local IP", value: connection.localIPAddress)
                LabeledContent("Public IP", value: connection.publicIPAddress)
                Button("Refresh Public IP") { connection.refreshPublicIPIfNeeded() }.controlSize(.small)
            }
            Section("Monitoring") {
                Toggle("Show interface names", isOn: $showInterfaceName).toggleStyle(.switch)
                Toggle("Fetch public IP address", isOn: $showPublicIP).toggleStyle(.switch).onChange(of: showPublicIP) { _, _ in connection.refreshPublicIPIfNeeded() }
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
            Section("Spike Alerts") {
                Toggle("Notify on traffic spikes", isOn: $enabled).toggleStyle(.switch)
                LabeledContent("Download threshold") { Slider(value: $download, in: 1...500, step: 1).frame(width: 180); Text("\(Int(download)) MB/s").monospacedDigit() }
                LabeledContent("Upload threshold") { Slider(value: $upload, in: 1...500, step: 1).frame(width: 180); Text("\(Int(upload)) MB/s").monospacedDigit() }
                Button("Request Notification Permission") { AlertManager.shared.requestAuthorization() }.controlSize(.small)
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
            Section("Retention") { Stepper("Keep \(retention) days", value: $retention, in: 1...365) }
            Section("Usage") {
                ForEach(historyRows) { row in
                    LabeledContent(row.date, value: row.value)
                }
                if store.dailyTotals.isEmpty { Text("No history yet.").foregroundStyle(.secondary) }
            }
            Section("Export") {
                HStack { Button("Export CSV") { export(kind: "csv") }; Button("Export JSON") { export(kind: "json") }; Button("Clear History", role: .destructive) { store.clear() } }
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

    private var historyRows: [HistoryRow] {
        store.dailyTotals.keys.sorted().map { day in
            let totals = store.dailyTotals[day, default: NetworkTotals()]
            return HistoryRow(
                date: day.formatted(date: .abbreviated, time: .omitted),
                value: "↓ \(SpeedFormatter.bytes(totals.downloaded))  ↑ \(SpeedFormatter.bytes(totals.uploaded))"
            )
        }
    }
}

private struct HistoryRow: Identifiable {
    let id = UUID()
    let date: String
    let value: String
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
    @AppStorage(AppDefaults.onboardingCompleted) private var onboardingCompleted = false
    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 72, height: 72)
                    VStack(alignment: .leading, spacing: 5) { Text("NetSpeed").font(.largeTitle.bold()); Text("A professional liquid-glass network monitor for macOS.").foregroundStyle(.secondary); Text("Copyright (C) 2026 anxkhn").font(.caption).foregroundStyle(.tertiary) }
                }
            }
            Section("Project") {
                Link("GitHub", destination: URL(string: "https://github.com/anxkhn/netspeed")!)
                Link("GPLv3 License", destination: URL(string: "https://www.gnu.org/licenses/gpl-3.0.html")!)
                Button("Show Onboarding Again") { onboardingCompleted = false; OnboardingWindowController.show() }.controlSize(.small)
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
