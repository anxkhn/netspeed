import Foundation
import Observation

@MainActor
@Observable
final class UsageHistoryStore {
    static let shared = UsageHistoryStore()

    private(set) var dailyTotals: [Date: NetworkTotals] = [:]
    private let fileURL: URL
    private let calendar = Calendar.current

    private init() {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appending(path: "NetSpeed", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appending(path: "history.json")
        load()
    }

    func record(_ sample: NetworkSample) {
        let day = calendar.startOfDay(for: sample.timestamp)
        var totals = dailyTotals[day, default: NetworkTotals()]
        totals.uploaded &+= sample.uploadBytesPerSecond
        totals.downloaded &+= sample.downloadBytesPerSecond
        dailyTotals[day] = totals
        prune()
        save()
    }

    func exportCSV() throws -> URL {
        let rows = dailyTotals.keys.sorted().map { day in
            let totals = dailyTotals[day, default: NetworkTotals()]
            return "\(ISO8601DateFormatter().string(from: day)),\(totals.uploaded),\(totals.downloaded)"
        }
        let text = (["date,uploaded_bytes,downloaded_bytes"] + rows).joined(separator: "\n")
        let url = FileManager.default.temporaryDirectory.appending(path: "NetSpeed-History.csv")
        try text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    func exportJSON() throws -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(dailyTotals.mapKeys { ISO8601DateFormatter().string(from: $0) })
        let url = FileManager.default.temporaryDirectory.appending(path: "NetSpeed-History.json")
        try data.write(to: url)
        return url
    }

    func clear() {
        dailyTotals.removeAll()
        save()
    }

    private func prune() {
        let retention = max(1, UserDefaults.standard.integer(forKey: AppDefaults.historyRetentionDays))
        guard let cutoff = calendar.date(byAdding: .day, value: -retention, to: .now) else { return }
        dailyTotals = dailyTotals.filter { $0.key >= cutoff }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let stored = try? JSONDecoder().decode([String: NetworkTotals].self, from: data) else { return }
        let formatter = ISO8601DateFormatter()
        dailyTotals = Dictionary(uniqueKeysWithValues: stored.compactMap { key, value in
            guard let date = formatter.date(from: key) else { return nil }
            return (date, value)
        })
    }

    private func save() {
        let formatter = ISO8601DateFormatter()
        let serializable = dailyTotals.mapKeys { formatter.string(from: $0) }
        if let data = try? JSONEncoder().encode(serializable) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}

private extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        Dictionary<T, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
}
