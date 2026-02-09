import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isStreaming: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 48)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: Theme.spacingXS) {
                messageContent
                    .textSelection(.enabled)
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.vertical, Theme.spacingSM + 4)
                    .background(bubbleColor, in: bubbleShape)

                // Timestamps hidden for cleaner aesthetic
            }

            if message.role == .assistant {
                Spacer(minLength: 48)
            }
        }
        .padding(.horizontal, Theme.spacingSM)
    }

    // MARK: - Message Content

    @ViewBuilder
    private var messageContent: some View {
        if message.role == .user {
            Text(message.content)
                .font(Theme.font(.body))
                .foregroundStyle(textColor)
        } else {
            MarkdownTextView(content: message.content, foregroundColor: textColor)
                .font(Theme.font(.body))
        }
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
