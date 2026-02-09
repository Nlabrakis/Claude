import Foundation
import Network

@Observable
final class ConnectionManager {
    enum ConnectionStatus: Equatable {
        case disconnected
        case connecting
        case connected
        case error(String)

        var label: String {
            switch self {
            case .disconnected: "Disconnected"
            case .connecting: "Connecting..."
            case .connected: "Connected"
            case .error(let msg): "Error: \(msg)"
            }
        }
    }

    var status: ConnectionStatus = .disconnected
    var currentServer: ServerConfig?
    var latency: TimeInterval?

    private var healthCheckTask: Task<Void, Never>?
    private var networkMonitor: NWPathMonitor?
    private var networkService: NetworkService?

    // MARK: - Connect

    func connect(to server: ServerConfig, using networkService: NetworkService) async {
        self.networkService = networkService
        self.currentServer = server
        self.status = .connecting

        networkService.baseURL = server.baseURL

        let isHealthy = await networkService.healthCheck()

        if isHealthy {
            status = .connected
            startHealthChecking()
        } else {
            status = .error("Could not reach server at \(server.host):\(server.port)")
        }
    }

    // MARK: - Disconnect

    func disconnect() {
        stopHealthChecking()
        networkService?.baseURL = nil
        currentServer = nil
        status = .disconnected
        latency = nil
    }

    // MARK: - Reconnect

    func reconnect() async {
        guard let server = currentServer, let networkService else { return }
        await connect(to: server, using: networkService)
    }

    // MARK: - Health Check Polling

    func startHealthChecking() {
        stopHealthChecking()

        healthCheckTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))

                guard let self, let networkService = self.networkService else { break }

                let start = CFAbsoluteTimeGetCurrent()
                let isHealthy = await networkService.healthCheck()
                let elapsed = CFAbsoluteTimeGetCurrent() - start

                if isHealthy {
                    self.latency = elapsed
                    if self.status != .connected {
                        self.status = .connected
                    }
                } else {
                    self.latency = nil
                    self.status = .error("Server unreachable")
                }
            }
        }
    }

    func stopHealthChecking() {
        healthCheckTask?.cancel()
        healthCheckTask = nil
    }

    // MARK: - Network Path Monitoring

    func startNetworkMonitoring() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                if path.status == .satisfied {
                    // Network came back — try to reconnect
                    if self?.status != .connected {
                        await self?.reconnect()
                    }
                } else {
                    self?.status = .disconnected
                    self?.latency = nil
                }
            }
        }
        monitor.start(queue: DispatchQueue(label: "com.clawdbot.network"))
        networkMonitor = monitor
    }

    func stopNetworkMonitoring() {
        networkMonitor?.cancel()
        networkMonitor = nil
    }

    // MARK: - Persistence

    private static let savedServerKey = "savedServerConfig"

    func saveCurrentServer() {
        guard let server = currentServer,
              let data = try? JSONEncoder().encode(server) else { return }
        UserDefaults.standard.set(data, forKey: Self.savedServerKey)
    }

    func loadSavedServer() -> ServerConfig? {
        guard let data = UserDefaults.standard.data(forKey: Self.savedServerKey) else { return nil }
        return try? JSONDecoder().decode(ServerConfig.self, from: data)
    }
}
