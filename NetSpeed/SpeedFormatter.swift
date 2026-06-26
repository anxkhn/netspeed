import Foundation

enum SpeedFormatter {
    static func speed(_ bytesPerSecond: UInt64, unit: SpeedUnit) -> String {
        let value = Double(bytesPerSecond) * (unit == .bits ? 8 : 1)
        let suffixes = unit == .bits ? ["bps", "Kbps", "Mbps", "Gbps"] : ["B/s", "KB/s", "MB/s", "GB/s"]
        var scaled = value
        var index = 0
        while scaled >= 1024, index < suffixes.count - 1 {
            scaled /= 1024
            index += 1
        }
        if index == 0 { return "\(Int(scaled)) \(suffixes[index])" }
        if scaled < 10 { return String(format: "%.1f %@", scaled, suffixes[index]) }
        return String(format: "%.0f %@", scaled, suffixes[index])
    }

    static func speedValue(_ bytesPerSecond: UInt64, unit: SpeedUnit, showsUnit: Bool) -> String {
        guard showsUnit else {
            let formatted = speed(bytesPerSecond, unit: unit)
            return formatted.split(separator: " ").first.map(String.init) ?? formatted
        }
        return speed(bytesPerSecond, unit: unit)
    }

    static func bytes(_ bytes: UInt64) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }
}
