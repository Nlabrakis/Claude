import Foundation

// MARK: - Request Types

struct ChatCompletionRequest: Encodable {
    let model: String
    let messages: [ChatMessageParam]
    let stream: Bool
    let temperature: Double?
    let maxTokens: Int?

    enum CodingKeys: String, CodingKey {
        case model, messages, stream, temperature
        case maxTokens = "max_tokens"
    }
}

struct ChatMessageParam: Codable {
    let role: String
    let content: String

    static func system(_ content: String) -> ChatMessageParam {
        ChatMessageParam(role: "system", content: content)
    }

    static func user(_ content: String) -> ChatMessageParam {
        ChatMessageParam(role: "user", content: content)
    }

    static func assistant(_ content: String) -> ChatMessageParam {
        ChatMessageParam(role: "assistant", content: content)
    }
}

// MARK: - Streaming Response Types

struct ChatCompletionChunk: Decodable {
    let id: String?
    let choices: [ChunkChoice]

    struct ChunkChoice: Decodable {
        let delta: Delta
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case delta
            case finishReason = "finish_reason"
        }
    }

    struct Delta: Decodable {
        let role: String?
        let content: String?
    }
}

// MARK: - Non-Streaming Response

struct ChatCompletionResponse: Decodable {
    let id: String?
    let choices: [ResponseChoice]
    let usage: Usage?

    struct ResponseChoice: Decodable {
        let message: ResponseMessage
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }

    struct ResponseMessage: Decodable {
        let role: String
        let content: String
    }

    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

// MARK: - Models API Response

struct OllamaModelsResponse: Decodable {
    let models: [OllamaModelInfo]?
}

struct OllamaModelInfo: Decodable {
    let name: String
    let modifiedAt: String?
    let size: Int64?
    let digest: String?

    enum CodingKeys: String, CodingKey {
        case name
        case modifiedAt = "modified_at"
        case size, digest
    }

    var toLLMModel: LLMModel {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = modifiedAt.flatMap { formatter.date(from: $0) }
        return LLMModel(name: name, modifiedAt: date, size: size, digest: digest)
    }
}

// MARK: - Ollama Status

struct OllamaRunningModels: Decodable {
    let models: [RunningModel]?

    struct RunningModel: Decodable {
        let name: String
        let size: Int64?
        let sizeVram: Int64?

        enum CodingKeys: String, CodingKey {
            case name, size
            case sizeVram = "size_vram"
        }
    }
}
