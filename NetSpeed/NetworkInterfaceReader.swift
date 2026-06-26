import Foundation

enum NetworkInterfaceReader {
    static func readAll() -> [NetworkInterfaceStats] {
        var addresses: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addresses) == 0 else { return [] }
        defer { freeifaddrs(addresses) }

        var result: [NetworkInterfaceStats] = []
        var cursor = addresses
        while let interface = cursor?.pointee {
            defer { cursor = interface.ifa_next }
            guard let address = interface.ifa_addr,
                  address.pointee.sa_family == AF_LINK,
                  let dataPointer = interface.ifa_data else { continue }

            let flags = Int32(interface.ifa_flags)
            let name = String(cString: interface.ifa_name)
            let data = dataPointer.assumingMemoryBound(to: if_data.self).pointee
            result.append(NetworkInterfaceStats(
                name: name,
                displayName: displayName(for: name),
                uploaded: UInt64(data.ifi_obytes),
                downloaded: UInt64(data.ifi_ibytes),
                isRunning: (flags & IFF_RUNNING) != 0,
                isLoopback: (flags & IFF_LOOPBACK) != 0
            ))
        }
        return result
    }

    static func activeTotals() -> (name: String, uploaded: UInt64, downloaded: UInt64) {
        let active = readAll().filter { $0.isRunning && !$0.isLoopback && ($0.name.hasPrefix("en") || $0.name.hasPrefix("bridge") || $0.name.hasPrefix("utun")) }
        let uploaded = active.reduce(UInt64(0)) { $0 &+ $1.uploaded }
        let downloaded = active.reduce(UInt64(0)) { $0 &+ $1.downloaded }
        let name = active.map(\.displayName).joined(separator: ", ")
        return (name.isEmpty ? "No active interface" : name, uploaded, downloaded)
    }

    private static func displayName(for name: String) -> String {
        if name.hasPrefix("en") { return "Wi-Fi / Ethernet (\(name))" }
        if name.hasPrefix("utun") { return "VPN (\(name))" }
        if name.hasPrefix("bridge") { return "Bridge (\(name))" }
        return name
    }
}
