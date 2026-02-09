import SwiftUI
import SwiftData

@main
struct ClawdBotApp: App {
    @State private var appState = AppState()
    @State private var networkService = NetworkService()
    @State private var discoveryService = ServerDiscoveryService()
    @State private var connectionManager = ConnectionManager()
    @State private var chatService = ChatService()
    @State private var modelService = ModelService()
    @State private var hapticsService = HapticsService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(networkService)
                .environment(discoveryService)
                .environment(connectionManager)
                .environment(chatService)
                .environment(modelService)
                .environment(hapticsService)
        }
        .modelContainer(for: [Conversation.self, Message.self])
    }
}
