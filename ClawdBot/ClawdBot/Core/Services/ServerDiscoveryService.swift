import Foundation
@preconcurrency import Network

struct DiscoveredServer: Identifiable, Hashable {
    var id: String { "\(host):\(port)" }
    let host: String
    let port: Int
    let name: String

    var toServerConfig: ServerConfig {
        ServerConfig(host: host, port: port, name: name, isManual: false)
    }
}

@MainActor
@Observable
final class ServerDiscoveryService {
    var discoveredServers: [DiscoveredServer] = []
    var isSearching = false

    private var browser: NWBrowser?
    private let queue = DispatchQueue(label: "com.clawdbot.discovery")

    // MARK: - Bonjour Discovery

    func startDiscovery() {
        stopDiscovery()
        isSearching = true
        discoveredServers = []

        let descriptor = NWBrowser.Descriptor.bonjour(type: "_clawdbot._tcp.", domain: nil)
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        let browser = NWBrowser(for: descriptor, using: parameters)

        browser.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                switch state {
                case .ready:
                    self?.isSearching = true
                case .failed, .cancelled:
                    self?.isSearching = false
                default:
                    break
                }
            }
        }

        browser.browseResultsChangedHandler = { [weak self] results, _ in
            Task { @MainActor in
                self?.handleResults(results)
            }
        }

        browser.start(queue: queue)
        self.browser = browser
    }

    func stopDiscovery() {
        browser?.cancel()
        browser = nil
        isSearching = false
    }

    // MARK: - Subnet Scanning

    /// Detects the device's WiFi IP, calculates the /24 subnet, and probes
    /// every address for an Ollama instance on the default port.
    func scanLocalNetwork() async {
        isSearching = true
        var found: [DiscoveredServer] = []

        // Build the list of hosts to probe
        var hostsToProbe: [String] = ["localhost", "127.0.0.1"]

        // Detect device IP and scan the whole /24 subnet
        if let deviceIP = Self.getWiFiIPAddress() {
            let parts = deviceIP.split(separator: ".")
            if parts.count == 4, let prefix = parts.dropLast().joined(separator: ".") as String? {
                for i in 1...254 {
                    let host = "\(prefix).\(i)"
                    if !hostsToProbe.contains(host) {
                        hostsToProbe.append(host)
                    }
                }
            }
        }

        // Probe all hosts in parallel
        await withTaskGroup(of: DiscoveredServer?.self) { group in
            for host in hostsToProbe {
                group.addTask {
                    await self.probeHost(host, port: ServerConfig.defaultPort)
                }
            }

            for await result in group {
                if let server = result {
                    found.append(server)
                }
            }
        }

        discoveredServers = found
        isSearching = false
    }

    // MARK: - Private

    private func handleResults(_ results: Set<NWBrowser.Result>) {
        var servers: [DiscoveredServer] = []

        for result in results {
            if case .service(let name, _, _, _) = result.endpoint {
                servers.append(DiscoveredServer(
                    host: name,
                    port: ServerConfig.defaultPort,
                    name: name
                ))
            }
        }

        discoveredServers = servers
    }

    nonisolated private func probeHost(_ host: String, port: Int) async -> DiscoveredServer? {
        guard let url = URL(string: "http://\(host):\(port)") else { return nil }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 2
            let (_, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                return DiscoveredServer(host: host, port: port, name: host)
            }
        } catch {
            // Host not reachable
        }

        return nil
    }

    // MARK: - Network Helpers

    /// Returns the device's WiFi (en0) IPv4 address, or nil if unavailable.
    nonisolated private static func getWiFiIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }

        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family

            guard addrFamily == UInt8(AF_INET) else { continue } // IPv4 only

            let name = String(cString: interface.ifa_name)
            guard name == "en0" else { continue } // WiFi interface

            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let result = getnameinfo(
                interface.ifa_addr,
                socklen_t(interface.ifa_addr.pointee.sa_len),
                &hostname,
                socklen_t(hostname.count),
                nil, 0,
                NI_NUMERICHOST
            )

            if result == 0 {
                address = String(cString: hostname)
            }
        }

        return address
    }
}
