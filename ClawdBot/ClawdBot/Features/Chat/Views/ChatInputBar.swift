import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    let isStreaming: Bool
    let isConnected: Bool
    let onSend: () -> Void
    let onStop: () -> Void

    @FocusState private var isFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var placeholder: String {
        isConnected ? "Message ClawdBot..." : "Connect to a server first..."
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: Theme.spacingSM) {
            TextField(placeholder, text: $text, axis: .vertical)
                .font(Theme.font(.body))
                .lineLimit(1...6)
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM + 2)
                .background(Theme.surfaceColor, in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
                .focused($isFocused)
                .disabled(!isConnected)
                .onSubmit {
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSend()
                    }
                }

            Button {
                if isStreaming {
                    onStop()
                } else {
                    onSend()
                }
            } label: {
                Image(systemName: isStreaming ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(buttonColor)
                    .contentTransition(.symbolEffect(.replace))
                    .animation(reduceMotion ? .none : Theme.gentleAnimation, value: isStreaming)
            }
            .frame(minWidth: Theme.minTapTarget, minHeight: Theme.minTapTarget)
            .disabled(!isStreaming && !canSend)
            .accessibilityLabel(isStreaming ? "Stop generating" : "Send message")
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, Theme.spacingSM)
        .background(.thinMaterial)
    }

    private var canSend: Bool {
        isConnected && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var buttonColor: Color {
        if isStreaming {
            return .red
        }
        return canSend ? Theme.accentBlue : Color(white: 0.3)
    }
}
