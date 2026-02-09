import Foundation

@MainActor
@Observable
final class ChatService {
    var currentResponse = ""
    var isStreaming = false
    var error: String?

    private var streamTask: Task<Void, Never>?
    private var tokenBuffer = ""
    private var flushTask: Task<Void, Never>?

    // MARK: - Send Message (Streaming)

    func sendMessage(
        _ content: String,
        conversation: Conversation,
        networkService: NetworkService,
        modelName: String,
        temperature: Double = 0.7
    ) async {
        // Build message history
        var params: [ChatMessageParam] = []

        if let systemPrompt = conversation.systemPrompt, !systemPrompt.isEmpty {
            params.append(.system(systemPrompt))
        }

        for message in conversation.sortedMessages {
            params.append(message.toChatMessageParam)
        }

        // Add the new user message
        params.append(.user(content))

        // Reset state
        currentResponse = ""
        tokenBuffer = ""
        error = nil
        isStreaming = true

        let stream = networkService.streamChatCompletion(
            messages: params,
            model: modelName,
            temperature: temperature
        )

        streamTask = Task {
            do {
                for try await token in stream {
                    if Task.isCancelled { break }
                    accumulateToken(token)
                }
                // Final flush
                flushBuffer()
            } catch {
                if !Task.isCancelled {
                    self.error = error.localizedDescription
                }
            }

            isStreaming = false
        }
    }

    // MARK: - Stop Generation

    func stopGeneration() {
        streamTask?.cancel()
        streamTask = nil
        flushTask?.cancel()
        flushTask = nil

        // Flush any remaining buffer
        if !tokenBuffer.isEmpty {
            currentResponse += tokenBuffer
            tokenBuffer = ""
        }

        isStreaming = false
    }

    // MARK: - Token Batching

    /// Accumulates tokens and flushes to `currentResponse` at ~30Hz
    /// to avoid overwhelming SwiftUI with per-token re-renders.
    private func accumulateToken(_ token: String) {
        tokenBuffer += token

        if flushTask == nil {
            flushTask = Task { [weak self] in
                try? await Task.sleep(for: .milliseconds(33))
                self?.flushBuffer()
            }
        }
    }

    private func flushBuffer() {
        currentResponse += tokenBuffer
        tokenBuffer = ""
        flushTask = nil
    }
}
