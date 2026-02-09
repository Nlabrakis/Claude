import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(ConnectionManager.self) private var connectionManager
    @Environment(NetworkService.self) private var networkService
    @Environment(ModelService.self) private var modelService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            switch appState.currentScreen {
            case .conversations:
                ConversationsListView()

            case .chat(let conversationID):
                ChatView(conversationID: conversationID)

            case .modelPicker:
                ModelPickerView()

            case .serverStatus:
                ServerStatusView()

            case .settings:
                SettingsView()
            }
        }
        .animation(Theme.conditionalAnimation(reduceMotion), value: appState.currentScreen)
        .task {
            await autoConnect()
        }
    }

    private func autoConnect() async {
        // Try to reconnect to last saved server
        if let savedServer = connectionManager.loadSavedServer() {
            await connectionManager.connect(to: savedServer, using: networkService)
            if connectionManager.status == .connected {
                await modelService.fetchModels(using: networkService)
            }
        }

        connectionManager.startNetworkMonitoring()
    }
}
