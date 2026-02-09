import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isStreaming: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: Theme.spacingXS) {
                Text(message.content + streamingCursor)
                    .font(Theme.font(.body))
                    .foregroundStyle(textColor)
                    .textSelection(.enabled)
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.vertical, Theme.spacingSM + 4)
                    .background(bubbleColor, in: bubbleShape)

                Text(message.createdAt.shortFormatted)
                    .font(Theme.font(.caption2))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, Theme.spacingXS)
            }

            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, Theme.spacingSM)
    }

    // MARK: - Appearance

    private var bubbleColor: Color {
        message.role == .user ? Theme.userBubbleColor : Theme.assistantBubbleColor
    }

    private var textColor: Color {
        message.role == .user ? Theme.userTextColor : Theme.assistantTextColor
    }

    private var bubbleShape: some Shape {
        RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
    }

    private var streamingCursor: String {
        isStreaming ? "  \u{258C}" : ""
    }
}
