import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusController: StatusItemController?
    private let updater = UpdaterManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.registerNetSpeedDefaults()
        NSApp.setActivationPolicy(.accessory)
        ConnectionMonitor.shared.start()
        NetworkMonitor.shared.start()
        AlertManager.shared.requestAuthorization()
        updater.start()
        statusController = StatusItemController()
        if !UserDefaults.standard.bool(forKey: AppDefaults.onboardingCompleted) {
            OnboardingWindowController.show()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        NetworkMonitor.shared.stop()
    }
}
