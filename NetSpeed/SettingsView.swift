import AppKit
import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general, menuBar, appearance, network, alerts, history, updates, about
    var id: Self { self }
    var title: String {
        switch self {
        case .general: "General"
        case .menuBar: "Menu Bar"
        case .appearance: "Appearance"
        case .network: "Network"
        case .alerts: "Alerts"
        case .history: "History"
        case .updates: "Updates"
        case .about: "About"
        }
    }
    var systemImage: String {
        switch self {
        case .general: "gearshape"
        case .menuBar: "menubar.rectangle"
        case .appearance: "paintbrush"
        case .network: "network"
        case .alerts: "bell.badge"
        case .history: "chart.bar.xaxis"
        case .updates: "arrow.down.circle"
        case .about: "info.circle"
        }
    }
}

@MainActor
@Observable
final class SettingsNavigation {
    static let shared = SettingsNavigation()
    var selectedTab: SettingsTab? = .general
    private init() {}
}

struct SettingsView: View {
    @State private var navigation = SettingsNavigation.shared
    @State private var history: [SettingsTab] = [.general]
    @State private var index = 0
    @State private var isHistoryNavigation = false

    private var activeTab: SettingsTab { navigation.selectedTab ?? .general }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $navigation.selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    Label(tab.title, systemImage: tab.systemImage).tag(tab)
                }
                Text(versionString).font(.footnote).fontDesign(.monospaced).foregroundStyle(.tertiary).listRowSeparator(.hidden)
            }
            .listStyle(.sidebar)
            .scrollEdgeEffectStyleSoftIfAvailable()
            .navigationTitle("Settings")
            .navigationSplitViewColumnWidth(min: 205, ideal: 215, max: 235)
            .toolbar(removing: .sidebarToggle)
        } detail: {
            SettingsDetailView(tab: activeTab)
        }
        .navigationTitle("Settings")
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 700, minHeight: 540)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button { goBack() } label: { Image(systemName: "chevron.left") }.disabled(index == 0)
                Button { goForward() } label: { Image(systemName: "chevron.right") }.disabled(index >= history.count - 1)
            }
        }
        .onChange(of: navigation.selectedTab) { _, _ in recordNavigation() }
    }

    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    private func goBack() { guard index > 0 else { return }; isHistoryNavigation = true; index -= 1; navigation.selectedTab = history[index]; DispatchQueue.main.async { isHistoryNavigation = false } }
    private func goForward() { guard index < history.count - 1 else { return }; isHistoryNavigation = true; index += 1; navigation.selectedTab = history[index]; DispatchQueue.main.async { isHistoryNavigation = false } }
    private func recordNavigation() {
        guard !isHistoryNavigation, let tab = navigation.selectedTab, history.last != tab else { return }
        if index < history.count - 1 { history = Array(history.prefix(index + 1)) }
        history.append(tab)
        index = history.count - 1
    }
}

private struct SettingsDetailView: View {
    let tab: SettingsTab
    var body: some View {
        Group {
            switch tab {
            case .general: GeneralSettingsPane()
            case .menuBar: MenuBarSettingsPane()
            case .appearance: AppearanceSettingsPane()
            case .network: NetworkSettingsPane()
            case .alerts: AlertsSettingsPane()
            case .history: HistorySettingsPane()
            case .updates: UpdatesSettingsPane()
            case .about: AboutSettingsPane()
            }
        }
        .navigationTitle(tab.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private extension View {
    @ViewBuilder func scrollEdgeEffectStyleSoftIfAvailable() -> some View {
        if #available(macOS 26.0, *) { scrollEdgeEffectStyle(.soft, for: .all) } else { self }
    }
}
