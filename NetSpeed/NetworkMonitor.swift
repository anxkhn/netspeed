import Foundation
import Observation

@MainActor
@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private(set) var current = NetworkSample(timestamp: .now, uploadBytesPerSecond: 0, downloadBytesPerSecond: 0, uploadTotalBytes: 0, downloadTotalBytes: 0, interfaceName: "Starting")
    private(set) var samples: [NetworkSample] = []
    private(set) var sessionTotals = NetworkTotals()

    private var previous: (uploaded: UInt64, downloaded: UInt64)?
    private var timer: Timer?
    private let maxSamples = 21_600

    private init() {}

    func start(interval: TimeInterval = UserDefaults.standard.double(forKey: AppDefaults.sampleInterval)) {
        stop()
        capture(resetBaseline: true)
        let interval = max(0.5, interval)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.capture(resetBaseline: false) }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func resetSession() {
        sessionTotals = NetworkTotals()
        samples.removeAll()
        previous = nil
        capture(resetBaseline: true)
    }

    private func capture(resetBaseline: Bool) {
        let totals = NetworkInterfaceReader.activeTotals()
        if resetBaseline || previous == nil {
            previous = (totals.uploaded, totals.downloaded)
            return
        }

        let uploadSpeed = delta(current: totals.uploaded, previous: previous?.uploaded ?? totals.uploaded)
        let downloadSpeed = delta(current: totals.downloaded, previous: previous?.downloaded ?? totals.downloaded)
        previous = (totals.uploaded, totals.downloaded)

        sessionTotals.uploaded &+= uploadSpeed
        sessionTotals.downloaded &+= downloadSpeed

        let sample = NetworkSample(
            timestamp: .now,
            uploadBytesPerSecond: uploadSpeed,
            downloadBytesPerSecond: downloadSpeed,
            uploadTotalBytes: sessionTotals.uploaded,
            downloadTotalBytes: sessionTotals.downloaded,
            interfaceName: totals.name
        )
        current = sample
        samples.append(sample)
        if samples.count > maxSamples { samples.removeFirst(samples.count - maxSamples) }
        UsageHistoryStore.shared.record(sample)
        AlertManager.shared.evaluate(sample)
    }

    func totals(since date: Date) -> NetworkTotals {
        samples.filter { $0.timestamp >= date }.reduce(NetworkTotals()) { totals, sample in
            NetworkTotals(uploaded: totals.uploaded + sample.uploadBytesPerSecond, downloaded: totals.downloaded + sample.downloadBytesPerSecond)
        }
    }

    var todayTotals: NetworkTotals {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let recent = totals(since: startOfDay)
        let persisted = UsageHistoryStore.shared.dailyTotals[startOfDay, default: NetworkTotals()]
        return NetworkTotals(uploaded: max(recent.uploaded, persisted.uploaded), downloaded: max(recent.downloaded, persisted.downloaded))
    }

    private func delta(current: UInt64, previous: UInt64) -> UInt64 {
        current >= previous ? current - previous : current
    }
}
