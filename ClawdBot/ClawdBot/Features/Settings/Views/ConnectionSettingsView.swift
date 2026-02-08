import SwiftUI

struct ConnectionSettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(NetworkService.self) private var networkService
    @Environment(ConnectionManager.self) private var connectionManager
    @Environment(ServerDiscoveryService.self) private var discoveryService
    @Environment(ModelService.self) private var modelService
    @Environment(HapticsService.self) private var hapticsService

    @State private var viewModel = SettingsViewModel()

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

                Text("Connection")
                    .font(Theme.font(.largeTitle).bold())

                Spacer()
            }
            .padding(.horizontal, Theme.spacingMD)

            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    // Discovered Servers
                    discoveredServersSection

                    // Manual Connection
                    manualConnectionSection
                }
                .padding(Theme.spacingMD)
            }
        }
        .onAppear {
            viewModel.populateFromServer(connectionManager.currentServer)
            discoveryService.startDiscovery()
            Task { await discoveryService.scanLocalNetwork() }
        }
        .onDisappear {
            discoveryService.stopDiscovery()
        }
    }

    // MARK: - Discovered Servers

    private var discoveredServersSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Text("Discovered Servers")
                    .font(Theme.font(.headline))

                Spacer()

                if discoveryService.isSearching {
                    ProgressView()
                }
            }

            if discoveryService.discoveredServers.isEmpty {
                Text("Scanning local network...")
                    .font(Theme.font(.subheadline))
                    .foregroundStyle(.secondary)
                    .padding(Theme.spacingMD)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
            } else {
                ForEach(discoveryService.discoveredServers) { server in
                    Button {
                        connectToDiscovered(server)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                Text(server.name)
                                    .font(Theme.font(.headline))
                                    .foregroundStyle(.primary)
                                Text("\(server.host):\(server.port)")
                                    .font(Theme.font(.caption))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if connectionManager.currentServer?.id == server.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(Theme.spacingMD)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                    }
                    .frame(minHeight: Theme.minTapTarget)
                }
            }
        }
    }

    // MARK: - Manual Connection

    private var manualConnectionSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("Manual Connection")
                .font(Theme.font(.headline))

            VStack(spacing: Theme.spacingSM) {
                TextField("Host (e.g. 192.168.1.100)", text: $viewModel.hostInput)
                    .font(Theme.font(.body))
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.vertical, Theme.spacingSM + 2)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)

                TextField("Port", text: $viewModel.portInput)
                    .font(Theme.font(.body))
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.vertical, Theme.spacingSM + 2)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                    .keyboardType(.numberPad)
            }

            if let result = viewModel.connectionTestResult {
                Text(result)
                    .font(Theme.font(.caption))
                    .foregroundStyle(result.contains("success") ? .green : .red)
            }

            HStack(spacing: Theme.spacingSM) {
                Button {
                    Task { await testAndConnect() }
                } label: {
                    HStack {
                        if viewModel.isTestingConnection {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Connect")
                            .font(Theme.font(.headline))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: Theme.minTapTarget)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                    .foregroundStyle(.white)
                }
                .disabled(viewModel.isTestingConnection || viewModel.hostInput.isEmpty)

                if connectionManager.status == .connected {
                    Button {
                        connectionManager.disconnect()
                        hapticsService.connectionLost()
                    } label: {
                        Text("Disconnect")
                            .font(Theme.font(.headline))
                            .frame(minWidth: 120)
                            .frame(minHeight: Theme.minTapTarget)
                            .background(Color.red, in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func connectToDiscovered(_ server: DiscoveredServer) {
        Task {
            let config = server.toServerConfig
            await connectionManager.connect(to: config, using: networkService)
            if connectionManager.status == .connected {
                connectionManager.saveCurrentServer()
                hapticsService.connectionEstablished()
                await modelService.fetchModels(using: networkService)
            } else {
                hapticsService.error()
            }
        }
    }

    private func testAndConnect() async {
        if let config = await viewModel.testConnection() {
            await connectionManager.connect(to: config, using: networkService)
            if connectionManager.status == .connected {
                connectionManager.saveCurrentServer()
                hapticsService.connectionEstablished()
                await modelService.fetchModels(using: networkService)
            } else {
                hapticsService.error()
            }
        } else {
            hapticsService.error()
        }
    }
}
