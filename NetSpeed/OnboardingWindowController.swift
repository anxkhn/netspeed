import AppKit
import SwiftUI

@MainActor
final class OnboardingWindowController: NSWindowController, NSWindowDelegate {
    private static var shared: OnboardingWindowController?

    static func show() {
        if shared == nil { shared = OnboardingWindowController() }
        shared?.showWindow(nil)
    }

    private init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 680, height: 500), styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        super.init(window: window)
        window.title = "Welcome to NetSpeed"
        window.toolbarStyle = .unifiedCompact
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.contentViewController = NSHostingController(rootView: OnboardingView())
        window.delegate = self
        window.center()
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func showWindow(_ sender: Any?) {
        AppActivationPolicy.enter()
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        Self.shared = nil
        AppActivationPolicy.leave()
    }
}

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(AppDefaults.onboardingCompleted) private var onboardingCompleted = false
    @AppStorage(AppDefaults.showPublicIP) private var showPublicIP = false
    @AppStorage(AppDefaults.surfaceStyle) private var surfaceStyle = SurfaceStyle.system.rawValue
    @State private var step = 0
    @State private var launchMessage: String?

    private let steps = OnboardingStep.allCases

    var body: some View {
        VStack(spacing: 22) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NetSpeed")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("Menu bar network intelligence, without noise.")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: steps[step].symbol)
                    .font(.system(size: 46, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text(steps[step].title).font(.title2.bold())
                Text(steps[step].message).font(.body).foregroundStyle(.secondary)
                actionView(for: steps[step])
            }
            .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
            .padding(22)
            .adaptiveGlassBackground()

            HStack {
                ForEach(steps.indices, id: \.self) { index in
                    Capsule().fill(index == step ? Color.accentColor : Color.secondary.opacity(0.25)).frame(width: index == step ? 28 : 8, height: 8)
                }
                Spacer()
                Button("Skip") { finish() }.buttonStyle(.borderless)
                Button(step == steps.count - 1 ? "Start Monitoring" : "Continue") { next() }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(28)
        .background(.regularMaterial)
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: step)
    }

    @ViewBuilder
    private func actionView(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            Picker("Surface", selection: $surfaceStyle) { ForEach(SurfaceStyle.allCases) { Text($0.title).tag($0.rawValue) } }.pickerStyle(.segmented).frame(maxWidth: 360)
        case .notifications:
            Button("Allow Notifications") { AlertManager.shared.requestAuthorization() }.controlSize(.large)
        case .login:
            HStack { Button("Enable Launch at Login") { enableLogin() }.controlSize(.large); if let launchMessage { Text(launchMessage).font(.caption).foregroundStyle(.secondary) } }
        case .privacy:
            Toggle("Show public IP in dashboard", isOn: $showPublicIP).toggleStyle(.switch).onChange(of: showPublicIP) { _, _ in ConnectionMonitor.shared.refreshPublicIPIfNeeded() }
        case .finish:
            HStack { Button("Open Settings") { SettingsWindowController.show(tab: .general) }; Button("Open Visualizer") { VisualizerWindowController.show() } }
        }
    }

    private func next() { step == steps.count - 1 ? finish() : (step += 1) }
    private func finish() { onboardingCompleted = true; NSApp.keyWindow?.close() }
    private func enableLogin() {
        do { try LaunchAtLoginManager.setEnabled(true); launchMessage = "Enabled" }
        catch { launchMessage = error.localizedDescription }
    }
}

private enum OnboardingStep: CaseIterable {
    case welcome, notifications, login, privacy, finish
    var title: String {
        switch self {
        case .welcome: "Choose your surface"
        case .notifications: "Get useful spike alerts"
        case .login: "Start automatically"
        case .privacy: "Decide what IP data appears"
        case .finish: "You're ready"
        }
    }
    var message: String {
        switch self {
        case .welcome: "Use transparent Liquid Glass, an opaque high-contrast surface, or follow the system's accessibility setting."
        case .notifications: "NetSpeed can notify you when download or upload traffic crosses your configured thresholds."
        case .login: "Keep the monitor available immediately after you sign in. You can change this any time in Settings."
        case .privacy: "Local IP stays on-device. Public IP is optional and only fetched when enabled."
        case .finish: "Use the menu bar item for the dashboard, charts, exports, and advanced customization."
        }
    }
    var symbol: String {
        switch self {
        case .welcome: "sparkles"
        case .notifications: "bell.badge"
        case .login: "power.circle"
        case .privacy: "lock.shield"
        case .finish: "checkmark.circle"
        }
    }
}
