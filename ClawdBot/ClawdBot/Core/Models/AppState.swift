import SwiftUI

@Observable
final class AppState {
    enum Screen: Hashable {
        case conversations
        case chat(conversationID: String)
        case modelPicker
        case serverStatus
        case settings
    }

    var currentScreen: Screen = .conversations
    var previousScreen: Screen?

    func navigate(to screen: Screen) {
        previousScreen = currentScreen
        currentScreen = screen
    }

    func goBack() {
        if let previous = previousScreen {
            currentScreen = previous
            previousScreen = nil
        } else {
            currentScreen = .conversations
        }
    }
}
