import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(ConnectionManager.self) private var connectionManager
    @Environment(ModelService.self) private var modelService
    @Environment(HapticsService.self) private var hapticsService

    @State private var viewModel = SettingsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    viewModel.saveDefaults()
                    appState.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: Theme.iconSize, weight: .medium))
                }
                .frame(minWidth: Theme.minTapTarget, minHeight: Theme.minTapTarget)

                Text("Settings")
                    .font(Theme.font(.largeTitle).bold())

                Spacer()
            }
            .padding(.horizontal, Theme.spacingMD)

            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    // Connection Section
                    settingsSection("Connection") {
                        settingsButton(
                            icon: "network",
                            title: "Server Connection",
                            subtitle: connectionManager.currentServer?.id ?? "Not connected"
                        ) {
                            appState.navigate(to: .settings) // TODO: sub-navigation to ConnectionSettingsView
                        }

                        settingsButton(
                            icon: "chart.bar",
                            title: "Server Status",
                            subtitle: connectionManager.status.label
                        ) {
                            appState.navigate(to: .serverStatus)
                        }
                    }

                    // Model Section
                    settingsSection("Model") {
                        settingsButton(
                            icon: "cpu",
                            title: "Selected Model",
                            subtitle: modelService.selectedModel?.displayName ?? "None"
                        ) {
                            appState.navigate(to: .modelPicker)
                        }

                        // Temperature
                        VStack(alignment: .leading, spacing: Theme.spacingSM) {
                            HStack {
                                Text("Temperature")
                                    .font(Theme.font(.subheadline))
                                Spacer()
                                Text(String(format: "%.1f", viewModel.temperature))
                                    .font(Theme.font(.subheadline).monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }

                            Slider(value: $viewModel.temperature, in: 0...2, step: 0.1)
                                .tint(.blue)

                            Text("Lower = more focused, Higher = more creative")
                                .font(Theme.font(.caption2))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(Theme.spacingMD)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                    }

                    // Default System Prompt
                    settingsSection("Default System Prompt") {
                        TextEditor(text: $viewModel.systemPrompt)
                            .font(Theme.font(.body))
                            .frame(minHeight: 120)
                            .padding(Theme.spacingSM)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                    }

                    // About Section
                    settingsSection("About") {
                        VStack(alignment: .leading, spacing: Theme.spacingSM) {
                            HStack {
                                Text("ClawdBot")
                                    .font(Theme.font(.headline))
                                Spacer()
                                Text("v1.0.0")
                                    .font(Theme.font(.subheadline))
                                    .foregroundStyle(.secondary)
                            }
                            Text("Local AI chat client for Ollama")
                                .font(Theme.font(.subheadline))
                                .foregroundStyle(.secondary)
                        }
                        .padding(Theme.spacingMD)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                    }
                }
                .padding(Theme.spacingMD)
            }
        }
        .onDisappear {
            viewModel.saveDefaults()
        }
    }

    // MARK: - Components

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text(title)
                .font(Theme.font(.headline))
                .foregroundStyle(.secondary)

            content()
        }
    }

    private func settingsButton(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button {
            hapticsService.tap()
            action()
        } label: {
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .frame(width: 32)
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.font(.subheadline))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(Theme.font(.caption))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(Theme.spacingMD)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
        }
        .frame(minHeight: Theme.minTapTarget)
    }
}
