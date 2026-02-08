import Foundation

@Observable
final class ModelPickerViewModel {
    var searchText = ""
    var isRefreshing = false

    func filteredModels(from models: [LLMModel]) -> [LLMModel] {
        guard !searchText.isEmpty else { return models }
        return models.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
    }

    func refresh(modelService: ModelService, networkService: NetworkService) async {
        isRefreshing = true
        await modelService.fetchModels(using: networkService)
        isRefreshing = false
    }
}
