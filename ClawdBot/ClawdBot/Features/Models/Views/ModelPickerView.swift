import SwiftUI

struct ModelPickerView: View {
    @Environment(AppState.self) private var appState
    @Environment(ModelService.self) private var modelService
    @Environment(NetworkService.self) private var networkService
    @Environment(HapticsService.self) private var hapticsService

    @State private var viewModel = ModelPickerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    appState.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: Theme.iconSize, weight: .medium))
                }
                .frame(minWidth: Theme.minTapTarget, minHeight: Theme.minTapTarget)

                Text("Models")
                    .font(Theme.font(.largeTitle).bold())

                Spacer()

                Button {
                    Task { await viewModel.refresh(modelService: modelService, networkService: networkService) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: Theme.iconSize))
                        .rotationEffect(.degrees(viewModel.isRefreshing ? 360 : 0))
                }
                .frame(minWidth: Theme.minTapTarget, minHeight: Theme.minTapTarget)
                .disabled(viewModel.isRefreshing)
            }
            .padding(.horizontal, Theme.spacingMD)

            // Search
            TextField("Search models...", text: $viewModel.searchText)
                .font(Theme.font(.body))
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM + 2)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)

            // Model List
            ScrollView {
                LazyVStack(spacing: Theme.spacingSM) {
                    let filtered = viewModel.filteredModels(from: modelService.availableModels)

                    if filtered.isEmpty {
                        emptyState
                    } else {
                        ForEach(filtered) { model in
                            modelRow(model)
                        }
                    }
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
            }
        }
        .task {
            if modelService.availableModels.isEmpty {
                await viewModel.refresh(modelService: modelService, networkService: networkService)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Theme.spacingMD) {
            Spacer(minLength: 80)

            Image(systemName: "cpu")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No models found")
                .font(Theme.font(.headline))
                .foregroundStyle(.secondary)

            Text("Make sure Ollama is running and has models pulled.")
                .font(Theme.font(.subheadline))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Model Row

    private func modelRow(_ model: LLMModel) -> some View {
        Button {
            hapticsService.tap()
            modelService.selectModel(model)
            appState.goBack()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text(model.displayName)
                        .font(Theme.font(.headline))
                        .foregroundStyle(.primary)

                    HStack(spacing: Theme.spacingSM) {
                        if !model.formattedSize.isEmpty {
                            Text(model.formattedSize)
                                .font(Theme.font(.caption))
                                .foregroundStyle(.secondary)
                        }

                        if let date = model.modifiedAt {
                            Text(date.relativeFormatted)
                                .font(Theme.font(.caption))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Spacer()

                if model.name == modelService.selectedModelName {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }
            }
            .padding(Theme.spacingMD)
            .background(
                model.name == modelService.selectedModelName
                    ? Color.blue.opacity(0.1)
                    : Color(.systemGray6),
                in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous)
            )
        }
        .frame(minHeight: Theme.minTapTarget)
    }
}
