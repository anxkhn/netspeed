import Foundation
import Network
import Observation

@MainActor
@Observable
final class ConnectionMonitor {
    static let shared = ConnectionMonitor()

    private let pathMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "netspeed.connection-monitor")

    private(set) var status = "Checking"
    private(set) var interface = "Unknown"
    private(set) var localIPAddress = "Unknown"
    private(set) var publicIPAddress = "Disabled"

    private init() {}

    func start() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in self?.update(path: path) }
        }
        pathMonitor.start(queue: queue)
    }

    func refreshPublicIPIfNeeded() {
        guard UserDefaults.standard.bool(forKey: AppDefaults.showPublicIP) else {
            publicIPAddress = "Disabled"
            return
        }
        Task {
            guard let url = URL(string: "https://api.ipify.org") else { return }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                publicIPAddress = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                publicIPAddress = "Unavailable"
            }
        }
    }

    private func update(path: NWPath) {
        status = path.status == .satisfied ? "Online" : "Offline"
        interface = path.availableInterfaces.first?.name ?? "Unknown"
        localIPAddress = localIPv4Address(interfaceName: interface) ?? "Unknown"
        refreshPublicIPIfNeeded()
    }

    private func localIPv4Address(interfaceName: String) -> String? {
        var addresses: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addresses) == 0 else { return nil }
        defer { freeifaddrs(addresses) }

        var cursor = addresses
        while let interface = cursor?.pointee {
            defer { cursor = interface.ifa_next }
            guard String(cString: interface.ifa_name) == interfaceName,
                  let address = interface.ifa_addr,
                  address.pointee.sa_family == sa_family_t(AF_INET) else { continue }

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(address, socklen_t(address.pointee.sa_len), &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST) == 0 {
                let length = host.firstIndex(of: 0) ?? host.count
                return String(decoding: host.prefix(length).map { UInt8(bitPattern: $0) }, as: UTF8.self)
            }
        }
        return nil
    }
}
