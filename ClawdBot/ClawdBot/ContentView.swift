import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(ConnectionManager.self) private var connectionManager
    @Environment(NetworkService.self) private var networkService
    @Environment(ModelService.self) private var modelService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Theme.backgroundPrimary.ignoresSafeArea()

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

            case .connectionSettings:
                ConnectionSettingsView()

            case .onboarding:
                OnboardingView()
            }
        }
        .animation(Theme.conditionalAnimation(reduceMotion), value: appState.currentScreen)
        .preferredColorScheme(.dark)
        .task {
            await autoConnect()
        }
    }

    private func autoConnect() async {
        // Check for first launch — show onboarding if no saved server
        guard let savedServer = connectionManager.loadSavedServer() else {
            appState.navigate(to: .onboarding)
            return
        }

        // Try to reconnect to last saved server
        await connectionManager.connect(to: savedServer, using: networkService)
        if connectionManager.status == .connected {
            await modelService.fetchModels(using: networkService)
        }

        connectionManager.startNetworkMonitoring()
    }
}
