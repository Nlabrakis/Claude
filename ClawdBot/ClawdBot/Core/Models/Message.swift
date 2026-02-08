import Foundation
import SwiftData

@Model
final class Message {
    enum Role: String, Codable {
        case system
        case user
        case assistant
    }

    var id: String
    var role: Role
    var content: String
    var createdAt: Date
    var conversation: Conversation?

    init(role: Role, content: String) {
        self.id = UUID().uuidString
        self.role = role
        self.content = content
        self.createdAt = .now
    }

    var toChatMessageParam: ChatMessageParam {
        ChatMessageParam(role: role.rawValue, content: content)
    }
}
