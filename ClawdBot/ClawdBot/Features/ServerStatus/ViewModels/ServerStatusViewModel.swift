import Foundation

@Observable
final class ServerStatusViewModel {
    var runningModels: OllamaRunningModels?
    var isLoading = false
    var error: String?

    func fetchStatus(using networkService: NetworkService) async {
        isLoading = true
        error = nil

        do {
            runningModels = try await networkService.fetchRunningModels()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    var runningModelNames: [String] {
        runningModels?.models?.map(\.name) ?? []
    }

    var totalVRAMUsage: String {
        guard let models = runningModels?.models else { return "N/A" }
        let total = models.compactMap(\.sizeVram).reduce(0, +)
        guard total > 0 else { return "N/A" }
        let gb = Double(total) / 1_073_741_824
        return String(format: "%.1f GB", gb)
    }
}
