import Foundation

enum SpeedFormatter {
    static func speed(_ bytesPerSecond: UInt64, unit: SpeedUnit) -> String {
        switch unit {
        case .autoBytes, .autoBits:
            return autoSpeed(bytesPerSecond, bits: unit == .autoBits)
        case .bytes:
            return fixedSpeed(Double(bytesPerSecond), divisor: 1, suffix: "B/s", decimals: 0)
        case .kilobytes:
            return fixedSpeed(Double(bytesPerSecond), divisor: 1024, suffix: "KB/s")
        case .megabytes:
            return fixedSpeed(Double(bytesPerSecond), divisor: 1024 * 1024, suffix: "MB/s")
        case .gigabytes:
            return fixedSpeed(Double(bytesPerSecond), divisor: 1024 * 1024 * 1024, suffix: "GB/s")
        case .bits:
            return fixedSpeed(Double(bytesPerSecond) * 8, divisor: 1, suffix: "bps", decimals: 0)
        case .kilobits:
            return fixedSpeed(Double(bytesPerSecond) * 8, divisor: 1024, suffix: "Kbps")
        case .megabits:
            return fixedSpeed(Double(bytesPerSecond) * 8, divisor: 1024 * 1024, suffix: "Mbps")
        case .gigabits:
            return fixedSpeed(Double(bytesPerSecond) * 8, divisor: 1024 * 1024 * 1024, suffix: "Gbps")
        }
    }

    private static func autoSpeed(_ bytesPerSecond: UInt64, bits: Bool) -> String {
        let value = Double(bytesPerSecond) * (bits ? 8 : 1)
        let suffixes = bits ? ["bps", "Kbps", "Mbps", "Gbps"] : ["B/s", "KB/s", "MB/s", "GB/s"]
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

    private static func fixedSpeed(_ value: Double, divisor: Double, suffix: String, decimals: Int = 1) -> String {
        let scaled = value / divisor
        if decimals == 0 { return String(format: "%.0f %@", scaled, suffix) }
        if scaled < 10 { return String(format: "%.1f %@", scaled, suffix) }
        return String(format: "%.0f %@", scaled, suffix)
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
