import SwiftUI

struct ServerStatusView: View {
    @Environment(AppState.self) private var appState
    @Environment(ConnectionManager.self) private var connectionManager
    @Environment(NetworkService.self) private var networkService
    @Environment(ModelService.self) private var modelService

    @State private var viewModel = ServerStatusViewModel()

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

                Text("Server Status")
                    .font(Theme.font(.largeTitle).bold())

                Spacer()
            }
            .padding(.horizontal, Theme.spacingMD)

            ScrollView {
                VStack(spacing: Theme.spacingMD) {
                    // Connection Card
                    statusCard("Connection") {
                        statusRow("Status", value: connectionManager.status.label, color: statusColor)
                        if let server = connectionManager.currentServer {
                            statusRow("Host", value: server.host)
                            statusRow("Port", value: "\(server.port)")
                        }
                        if let latency = connectionManager.latency {
                            statusRow("Latency", value: String(format: "%.0f ms", latency * 1000))
                        }
                    }

                    // Models Card
                    statusCard("Running Models") {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else if viewModel.runningModelNames.isEmpty {
                            Text("No models loaded")
                                .font(Theme.font(.subheadline))
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.runningModelNames, id: \.self) { name in
                                statusRow("Model", value: name)
                            }
                            statusRow("VRAM Usage", value: viewModel.totalVRAMUsage)
                        }
                    }

                    // Available Models Card
                    statusCard("Available Models") {
                        if modelService.availableModels.isEmpty {
                            Text("None found")
                                .font(Theme.font(.subheadline))
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(modelService.availableModels.count) models")
                                .font(Theme.font(.subheadline))
                            ForEach(modelService.availableModels.prefix(10)) { model in
                                statusRow(model.displayName, value: model.formattedSize)
                            }
                        }
                    }

                    // Actions
                    VStack(spacing: Theme.spacingSM) {
                        Button {
                            Task { await refresh() }
                        } label: {
                            Text("Refresh Status")
                                .font(Theme.font(.headline))
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: Theme.minTapTarget)
                                .background(Color.blue, in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                                .foregroundStyle(.white)
                        }

                        if connectionManager.status != .connected {
                            Button {
                                Task { await connectionManager.reconnect() }
                            } label: {
                                Text("Reconnect")
                                    .font(Theme.font(.headline))
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: Theme.minTapTarget)
                                    .background(Color.green, in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .padding(Theme.spacingMD)
            }
        }
        .task {
            await refresh()
        }
    }

    // MARK: - Helpers

    private var statusColor: Color {
        switch connectionManager.status {
        case .connected: Theme.connectedColor
        case .connecting: Theme.connectingColor
        case .disconnected, .error: Theme.disconnectedColor
        }
    }

    private func refresh() async {
        await viewModel.fetchStatus(using: networkService)
        await modelService.fetchModels(using: networkService)
    }

    private func statusCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text(title)
                .font(Theme.font(.headline))

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                content()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.spacingMD)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
    }

    private func statusRow(_ label: String, value: String, color: Color? = nil) -> some View {
        HStack {
            Text(label)
                .font(Theme.font(.subheadline))
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: Theme.spacingXS) {
                if let color {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }
                Text(value)
                    .font(Theme.font(.subheadline))
            }
        }
    }
}
