import Foundation
import SwiftData

@MainActor
@Observable
final class ConversationsListViewModel {
    var editingConversation: Conversation?
    var editTitle = ""

    private var modelContext: ModelContext?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Create

    func createConversation(modelName: String?) -> Conversation {
        let defaultPrompt = SettingsViewModel.savedSystemPrompt
        let conversation = Conversation(
            systemPrompt: defaultPrompt.isEmpty ? nil : defaultPrompt,
            modelName: modelName
        )
        modelContext?.insert(conversation)
        try? modelContext?.save()
        return conversation
    }

    // MARK: - Delete

    func delete(_ conversation: Conversation) {
        modelContext?.delete(conversation)
        try? modelContext?.save()
    }

    // MARK: - Rename

    func startRenaming(_ conversation: Conversation) {
        editingConversation = conversation
        editTitle = conversation.title
    }

    func confirmRename() {
        guard let conversation = editingConversation else { return }
        let trimmed = editTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            conversation.title = trimmed
            conversation.updatedAt = .now
            try? modelContext?.save()
        }
        editingConversation = nil
        editTitle = ""
    }
}
