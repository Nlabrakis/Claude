import Foundation
import Network

struct DiscoveredServer: Identifiable, Hashable {
    var id: String { "\(host):\(port)" }
    let host: String
    let port: Int
    let name: String

    var toServerConfig: ServerConfig {
        ServerConfig(host: host, port: port, name: name, isManual: false)
    }
}

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

    // MARK: - Scan Common Ports

    /// Scans the local network for Ollama instances on the default port.
    /// Useful as a fallback when Bonjour is not advertised.
    func scanLocalNetwork() async {
        isSearching = true
        var found: [DiscoveredServer] = []

        // Try common local addresses
        let commonHosts = [
            "localhost",
            "127.0.0.1",
            "192.168.1.1",
        ]

        await withTaskGroup(of: DiscoveredServer?.self) { group in
            for host in commonHosts {
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
                // Resolve the endpoint to get host/port
                // For now, store with the service name
                servers.append(DiscoveredServer(
                    host: name,
                    port: ServerConfig.defaultPort,
                    name: name
                ))
            }
        }

        discoveredServers = servers
    }

    private func probeHost(_ host: String, port: Int) async -> DiscoveredServer? {
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
}
