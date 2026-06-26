import Foundation

struct NetworkSample: Identifiable, Codable, Hashable {
    var id = UUID()
    let timestamp: Date
    let uploadBytesPerSecond: UInt64
    let downloadBytesPerSecond: UInt64
    let uploadTotalBytes: UInt64
    let downloadTotalBytes: UInt64
    let interfaceName: String
}

struct NetworkTotals: Codable, Hashable {
    var uploaded: UInt64 = 0
    var downloaded: UInt64 = 0
}

struct NetworkInterfaceStats: Hashable {
    let name: String
    let displayName: String
    let uploaded: UInt64
    let downloaded: UInt64
    let isRunning: Bool
    let isLoopback: Bool
}
