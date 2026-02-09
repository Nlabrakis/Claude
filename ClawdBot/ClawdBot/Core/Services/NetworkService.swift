import Foundation

@MainActor
@Observable
final class NetworkService {
    var baseURL: URL?

    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }

    // MARK: - Health Check

    func healthCheck() async -> Bool {
        guard let baseURL else { return false }
        do {
            var request = URLRequest(url: baseURL)
            request.timeoutInterval = 5
            let (_, response) = try await session.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

    // MARK: - Fetch Available Models

    func fetchModels() async throws -> [LLMModel] {
        guard let baseURL else { throw NetworkError.noServer }

        let url = baseURL.appendingPathComponent("/api/tags")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }

        let ollamaResponse = try JSONDecoder().decode(OllamaModelsResponse.self, from: data)
        return ollamaResponse.models?.map(\.toLLMModel) ?? []
    }

    // MARK: - Fetch Running Models

    func fetchRunningModels() async throws -> OllamaRunningModels {
        guard let baseURL else { throw NetworkError.noServer }

        let url = baseURL.appendingPathComponent("/api/ps")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }

        return try JSONDecoder().decode(OllamaRunningModels.self, from: data)
    }

    // MARK: - Streaming Chat Completion

    func streamChatCompletion(
        messages: [ChatMessageParam],
        model: String,
        temperature: Double = 0.7,
        maxTokens: Int? = nil
    ) -> AsyncThrowingStream<String, Error> {
        // Extract self's properties into local variables so the closure
        // does not capture `self` (which is non-Sendable / @MainActor-isolated).
        let localBaseURL = self.baseURL
        let localSession = self.session

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    guard let baseURL = localBaseURL else {
                        continuation.finish(throwing: NetworkError.noServer)
                        return
                    }

                    let url = baseURL.appendingPathComponent("/v1/chat/completions")
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.timeoutInterval = 300

                    let body = ChatCompletionRequest(
                        model: model,
                        messages: messages,
                        stream: true,
                        temperature: temperature,
                        maxTokens: maxTokens
                    )
                    request.httpBody = try JSONEncoder().encode(body)

                    let (bytes, response) = try await localSession.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        continuation.finish(throwing: NetworkError.badResponse)
                        return
                    }

                    for try await line in bytes.lines {
                        if Task.isCancelled { break }

                        guard let event = SSEParser.parse(line: line) else {
                            continue
                        }

                        switch event {
                        case .token(let token):
                            continuation.yield(token)
                        case .done:
                            break
                        case .error(let error):
                            continuation.finish(throwing: error)
                            return
                        }
                    }

                    continuation.finish()
                } catch {
                    if !Task.isCancelled {
                        continuation.finish(throwing: error)
                    }
                }
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    // MARK: - Non-Streaming Chat Completion

    func chatCompletion(
        messages: [ChatMessageParam],
        model: String,
        temperature: Double = 0.7,
        maxTokens: Int? = nil
    ) async throws -> String {
        guard let baseURL else { throw NetworkError.noServer }

        let url = baseURL.appendingPathComponent("/v1/chat/completions")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 300

        let body = ChatCompletionRequest(
            model: model,
            messages: messages,
            stream: false,
            temperature: temperature,
            maxTokens: maxTokens
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }

        let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        return completion.choices.first?.message.content ?? ""
    }

    // MARK: - Cancellation

    /// Cancellation is handled through the stream's onTermination callback.
    /// When ChatService.stopGeneration() cancels its streamTask, the
    /// AsyncThrowingStream's onTermination fires and cancels the inner
    /// network Task automatically.
    func cancelCurrentStream() {
        // No-op: cancellation flows through the stream's onTermination handler.
    }
}

// MARK: - Errors

enum NetworkError: LocalizedError {
    case noServer
    case badResponse
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .noServer:
            return "No server configured. Add a server in Settings."
        case .badResponse:
            return "The server returned an unexpected response."
        case .decodingFailed:
            return "Failed to decode the server response."
        }
    }
}
