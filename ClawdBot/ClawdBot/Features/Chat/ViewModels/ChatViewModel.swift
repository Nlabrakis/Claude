import Foundation
import SwiftData

@MainActor
@Observable
final class ChatViewModel {
    var inputText = ""
    var isShowingModelPicker = false
    var error: String?

    private var modelContext: ModelContext?
    private var conversation: Conversation?

    // MARK: - Setup

    func configure(conversationID: String, modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchConversation(id: conversationID)
    }

    var messages: [Message] {
        conversation?.sortedMessages ?? []
    }

    var conversationTitle: String {
        conversation?.title ?? "Chat"
    }

    // MARK: - Send Message

    func send(
        chatService: ChatService,
        networkService: NetworkService,
        modelName: String?
    ) async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // Explicit error feedback instead of silent failures
        guard let conversation else {
            error = "No conversation selected. Go back and create one."
            return
        }
        guard let modelName, !modelName.isEmpty else {
            error = "No model selected. Tap the CPU icon to pick a model."
            return
        }

        // Create and persist user message
        let userMessage = Message(role: .user, content: text)
        userMessage.conversation = conversation
        conversation.messages.append(userMessage)
        conversation.updatedAt = .now
        inputText = ""
        saveContext()

        // Read saved temperature from settings
        let temperature = SettingsViewModel.savedTemperature

        // Start streaming
        await chatService.sendMessage(
            text,
            conversation: conversation,
            networkService: networkService,
            modelName: modelName,
            temperature: temperature
        )

        // Persist assistant response
        let responseContent = chatService.currentResponse
        if !responseContent.isEmpty {
            let assistantMessage = Message(role: .assistant, content: responseContent)
            assistantMessage.conversation = conversation
            conversation.messages.append(assistantMessage)
            conversation.updatedAt = .now

            // Auto-title on first exchange
            if conversation.title == "New Chat" && conversation.messages.count <= 3 {
                conversation.title = generateTitle(from: text)
            }

            saveContext()
        }

        if let err = chatService.error {
            error = err
        }
    }

    // MARK: - Retry Last

    func retryLast(
        chatService: ChatService,
        networkService: NetworkService,
        modelName: String?
    ) async {
        guard let conversation else { return }

        // Remove last assistant message if present
        if let last = conversation.sortedMessages.last, last.role == .assistant {
            modelContext?.delete(last)
            conversation.messages.removeAll { $0.id == last.id }
            saveContext()
        }

        // Re-send last user message
        if let lastUser = conversation.sortedMessages.last, lastUser.role == .user {
            inputText = ""

            // Read saved temperature from settings
            let temperature = SettingsViewModel.savedTemperature

            await chatService.sendMessage(
                lastUser.content,
                conversation: conversation,
                networkService: networkService,
                modelName: modelName ?? "",
                temperature: temperature
            )

            let responseContent = chatService.currentResponse
            if !responseContent.isEmpty {
                let assistantMessage = Message(role: .assistant, content: responseContent)
                assistantMessage.conversation = conversation
                conversation.messages.append(assistantMessage)
                conversation.updatedAt = .now
                saveContext()
            }
        }
    }

    // MARK: - Private

    private func fetchConversation(id: String) {
        let predicate = #Predicate<Conversation> { $0.id == id }
        let descriptor = FetchDescriptor<Conversation>(predicate: predicate)
        conversation = try? modelContext?.fetch(descriptor).first
    }

    private func saveContext() {
        try? modelContext?.save()
    }

    private func generateTitle(from userMessage: String) -> String {
        let words = userMessage.split(separator: " ").prefix(6).joined(separator: " ")
        if words.count > 40 {
            return String(words.prefix(40)) + "..."
        }
        return words
    }
}
