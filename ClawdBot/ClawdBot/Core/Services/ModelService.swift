import Foundation

@Observable
final class ModelService {
    var availableModels: [LLMModel] = []
    var selectedModelName: String?
    var isLoading = false
    var error: String?

    private static let selectedModelKey = "selectedModelName"

    var selectedModel: LLMModel? {
        availableModels.first { $0.name == selectedModelName }
    }

    // MARK: - Fetch Models

    func fetchModels(using networkService: NetworkService) async {
        isLoading = true
        error = nil

        do {
            availableModels = try await networkService.fetchModels()

            // Restore previous selection or select first model
            if selectedModelName == nil {
                selectedModelName = loadSavedModelName() ?? availableModels.first?.name
            }

            // Validate selection still exists
            if let selected = selectedModelName,
               !availableModels.contains(where: { $0.name == selected }) {
                selectedModelName = availableModels.first?.name
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Selection

    func selectModel(_ model: LLMModel) {
        selectedModelName = model.name
        saveSelectedModel()
    }

    // MARK: - Persistence

    private func saveSelectedModel() {
        UserDefaults.standard.set(selectedModelName, forKey: Self.selectedModelKey)
    }

    private func loadSavedModelName() -> String? {
        UserDefaults.standard.string(forKey: Self.selectedModelKey)
    }
}
