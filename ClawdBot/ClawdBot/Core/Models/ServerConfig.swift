import Foundation

struct ServerConfig: Codable, Hashable, Identifiable {
    var id: String { "\(host):\(port)" }
    var host: String
    var port: Int
    var name: String
    var isManual: Bool

    var baseURL: URL? {
        URL(string: "http://\(host):\(port)")
    }

    static let defaultPort = 11434

    static func manual(host: String, port: Int = defaultPort) -> ServerConfig {
        ServerConfig(host: host, port: port, name: host, isManual: true)
    }
}
