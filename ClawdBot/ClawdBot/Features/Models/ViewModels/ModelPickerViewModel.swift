import Foundation

@MainActor
@Observable
final class ModelPickerViewModel {
    var searchText = ""
    var isRefreshing = false

    func filteredModels(from models: [LLMModel]) -> [LLMModel] {
        guard !searchText.isEmpty else { return models }
        return models.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
    }

    func setRefreshing(_ value: Bool) {
        isRefreshing = value
    }
}
