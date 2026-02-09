import Foundation

@MainActor
@Observable
final class SettingsViewModel {

    // MARK: - Connection Properties

    var hostInput = ""
    var portInput = "11434"
    var isTestingConnection = false
    var connectionTestResult: String?

    // MARK: - Defaults Properties

    var temperature: Double = 0.7
    var systemPrompt = ""

    // MARK: - Keys

    private static let temperatureKey = "defaultTemperature"
    private static let systemPromptKey = "defaultSystemPrompt"

    // MARK: - Static Accessors

    static var savedTemperature: Double {
        let val = UserDefaults.standard.double(forKey: temperatureKey)
        return val == 0 ? 0.7 : val
    }

    static var savedSystemPrompt: String {
        UserDefaults.standard.string(forKey: systemPromptKey) ?? ""
    }

    // MARK: - Init

    init() {
        temperature = UserDefaults.standard.double(forKey: Self.temperatureKey)
        if temperature == 0 { temperature = 0.7 }
        systemPrompt = UserDefaults.standard.string(forKey: Self.systemPromptKey) ?? ""
    }

    // MARK: - Connection Testing

    func testConnection() async -> ServerConfig? {
        let host = hostInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !host.isEmpty, let port = Int(portInput) else {
            connectionTestResult = "Invalid host or port"
            return nil
        }

        isTestingConnection = true
        connectionTestResult = nil

        let config = ServerConfig.manual(host: host, port: port)

        guard let url = config.baseURL else {
            connectionTestResult = "Invalid URL"
            isTestingConnection = false
            return nil
        }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 5
            let (_, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                connectionTestResult = "Connected successfully"
                isTestingConnection = false
                return config
            } else {
                connectionTestResult = "Server returned unexpected status"
            }
        } catch {
            connectionTestResult = "Connection failed: \(error.localizedDescription)"
        }

        isTestingConnection = false
        return nil
    }

    // MARK: - Populate from Current

    func populateFromServer(_ server: ServerConfig?) {
        if let server {
            hostInput = server.host
            portInput = "\(server.port)"
        }
    }

    // MARK: - Persistence

    func saveDefaults() {
        UserDefaults.standard.set(temperature, forKey: Self.temperatureKey)
        UserDefaults.standard.set(systemPrompt, forKey: Self.systemPromptKey)
    }
}
