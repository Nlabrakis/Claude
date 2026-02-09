import Foundation

struct LLMModel: Identifiable, Hashable, Codable {
    var id: String { name }
    let name: String
    let modifiedAt: Date?
    let size: Int64?
    let digest: String?

    var displayName: String {
        name.replacingOccurrences(of: ":latest", with: "")
    }

    var formattedSize: String {
        guard let size else { return "" }
        let gb = Double(size) / 1_073_741_824
        return String(format: "%.1f GB", gb)
    }
}
