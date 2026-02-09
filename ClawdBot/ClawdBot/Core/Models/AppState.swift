import SwiftUI

@Observable
final class AppState {
    enum Screen: Hashable {
        case conversations
        case chat(conversationID: String)
        case modelPicker
        case serverStatus
        case settings
        case connectionSettings
        case onboarding
    }

    var currentScreen: Screen = .conversations
    var navigationStack: [Screen] = []

    var showOnboarding: Bool {
        currentScreen == .onboarding
    }

    func navigate(to screen: Screen) {
        navigationStack.append(currentScreen)
        currentScreen = screen
    }

    func goBack() {
        if let previous = navigationStack.popLast() {
            currentScreen = previous
        } else {
            currentScreen = .conversations
        }
    }

    func popToRoot() {
        navigationStack.removeAll()
        currentScreen = .conversations
    }
}
