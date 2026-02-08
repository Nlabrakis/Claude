import Foundation
import SwiftData

@Model
final class Conversation {
    var id: String
    var title: String
    var systemPrompt: String?
    var modelName: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message] = []

    init(
        title: String = "New Chat",
        systemPrompt: String? = nil,
        modelName: String? = nil
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.systemPrompt = systemPrompt
        self.modelName = modelName
        self.createdAt = .now
        self.updatedAt = .now
    }

    var sortedMessages: [Message] {
        messages.sorted { $0.createdAt < $1.createdAt }
    }

    var lastMessage: Message? {
        sortedMessages.last
    }

    var preview: String {
        lastMessage?.content.prefix(100).description ?? "No messages yet"
    }
}
