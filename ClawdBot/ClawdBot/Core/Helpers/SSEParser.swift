import Foundation

/// Parses Server-Sent Events (SSE) lines from an HTTP stream.
/// Expects lines in the format: "data: {json}" or "data: [DONE]"
struct SSEParser {
    enum SSEEvent {
        case token(String)
        case done
        case error(Error)
    }

    enum SSEError: LocalizedError {
        case invalidJSON(String)
        case unexpectedFormat(String)

        var errorDescription: String? {
            switch self {
            case .invalidJSON(let raw):
                return "Failed to parse SSE JSON: \(raw)"
            case .unexpectedFormat(let line):
                return "Unexpected SSE format: \(line)"
            }
        }
    }

    static func parse(line: String) -> SSEEvent? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

        // Skip empty lines and comments
        guard !trimmed.isEmpty, !trimmed.hasPrefix(":") else {
            return nil
        }

        // Handle "data: " prefix
        guard trimmed.hasPrefix("data: ") else {
            return nil
        }

        let payload = String(trimmed.dropFirst(6))

        // Check for stream termination
        if payload == "[DONE]" {
            return .done
        }

        // Parse JSON chunk
        guard let data = payload.data(using: .utf8) else {
            return .error(SSEError.invalidJSON(payload))
        }

        do {
            let chunk = try JSONDecoder().decode(ChatCompletionChunk.self, from: data)
            if let content = chunk.choices.first?.delta.content {
                return .token(content)
            }
            // Chunk with no content (e.g., role-only delta) — skip
            return nil
        } catch {
            return .error(SSEError.invalidJSON(payload))
        }
    }
}
