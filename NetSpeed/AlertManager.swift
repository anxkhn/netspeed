import Foundation
import UserNotifications

@MainActor
final class AlertManager {
    static let shared = AlertManager()

    private var lastAlert: Date = .distantPast
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func evaluate(_ sample: NetworkSample) {
        guard UserDefaults.standard.bool(forKey: AppDefaults.alertEnabled) else { return }
        guard Date().timeIntervalSince(lastAlert) > 60 else { return }

        let downloadLimit = UInt64(UserDefaults.standard.double(forKey: AppDefaults.downloadAlertMBps) * 1024 * 1024)
        let uploadLimit = UInt64(UserDefaults.standard.double(forKey: AppDefaults.uploadAlertMBps) * 1024 * 1024)
        guard sample.downloadBytesPerSecond >= downloadLimit || sample.uploadBytesPerSecond >= uploadLimit else { return }

        lastAlert = .now
        let content = UNMutableNotificationContent()
        content.title = "NetSpeed spike detected"
        content.body = "Down \(SpeedFormatter.speed(sample.downloadBytesPerSecond, unit: .bytes)) · Up \(SpeedFormatter.speed(sample.uploadBytesPerSecond, unit: .bytes))"
        content.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }
}
