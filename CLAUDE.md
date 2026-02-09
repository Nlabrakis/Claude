# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ClawdBot is an iOS 26 chat client for interacting with a local LLM running on an Ollama server (RTX 5080 GPU at home). Phase 1 targets same-network communication. Phase 2 will add remote access via Tailscale.

## Tech Stack

| Layer          | Technology                                      |
|----------------|------------------------------------------------|
| UI Framework   | SwiftUI (iOS 26 SDK)                           |
| Language       | Swift 6.2                                       |
| Architecture   | MVVM with `@Observable` (Observation framework) |
| Networking     | URLSession (SSE streaming via `bytes.lines`)    |
| Persistence    | SwiftData (`Conversation`, `Message` models)    |
| Discovery      | Network.framework (`NWBrowser` for Bonjour)     |
| Haptics        | Core Haptics                                    |
| State          | `@Observable` + `@State` + Environment injection|
| Navigation     | Custom screen enum (no deep navigation stacks)  |
| Backend        | Ollama (OpenAI-compatible `/v1/chat/completions`)|
| Min Target     | iOS 26                                          |

## Key Patterns

### State Management

- Use `@Observable` macro on all ViewModels and services — **never** `ObservableObject`/`@Published`
- Use `@State private var` to hold `@Observable` instances in views
- Inject shared services via `.environment()` at the app root
- Access shared services with `@Environment(ServiceType.self)`

### Architecture

- **MVVM**: Views own no business logic. ViewModels hold state and logic. Services handle system resources.
- **NetworkService**: HTTP client + SSE streaming via `AsyncThrowingStream`, targets Ollama's OpenAI-compatible API
- **ServerDiscoveryService**: Bonjour/mDNS auto-discovery using `NWBrowser` with local network scan fallback
- **ConnectionManager**: Connection state machine (`disconnected -> connecting -> connected -> error`) with health polling
- **ChatService**: Conversation orchestration with 30Hz token batching to prevent UI jank
- **ModelService**: Fetches and caches available Ollama models
- **HapticsService**: Centralized haptic feedback patterns
- **AppState**: Screen enum navigation and app-level state

### Environment Injection Pattern

```swift
// In App.swift — create and inject at root
@State private var networkService = NetworkService()
ContentView()
    .environment(networkService)

// In any child view — access via environment
@Environment(NetworkService.self) private var networkService
```

### Streaming Pattern

Token streaming uses SSE over HTTP with `URLSession.shared.bytes(for:)`. Tokens are batched at ~30Hz before flushing to `@Observable` properties to avoid per-token SwiftUI re-renders.

## Design Guidelines

### Accessibility

- Minimum tap target: **80pt**
- Simple, clear icons with high contrast
- No small text as interactive elements
- Forgiving gesture recognition (large hit areas, no precision required)
- No time-pressure interactions

### Colors

All colors defined in asset catalogs using semantic token names throughout the app.

### Typography

- **SF Pro Rounded** throughout — use `.system(.largeTitle, design: .rounded)` and similar
- All text generously sized for readability

### Animation

- Gentle, slow animations (0.4–0.6s duration)
- Bouncy spring animations for interactive feedback
- Always respect `accessibilityReduceMotion`
- No sudden or startling visual changes

## Project Structure

```
ClawdBot/
├── ClawdBot/
│   ├── App.swift                              # @main entry, environment injection
│   ├── ContentView.swift                      # Root view with screen routing
│   ├── Features/
│   │   ├── Chat/Views/                        # ChatView, MessageBubbleView, ChatInputBar
│   │   ├── Chat/ViewModels/                   # ChatViewModel
│   │   ├── Conversations/Views/               # ConversationsListView
│   │   ├── Conversations/ViewModels/          # ConversationsListViewModel
│   │   ├── Models/Views/                      # ModelPickerView
│   │   ├── Models/ViewModels/                 # ModelPickerViewModel
│   │   ├── ServerStatus/Views/                # ServerStatusView
│   │   ├── ServerStatus/ViewModels/           # ServerStatusViewModel
│   │   ├── Settings/Views/                    # SettingsView, ConnectionSettingsView
│   │   └── Settings/ViewModels/               # SettingsViewModel
│   ├── Core/
│   │   ├── Services/                          # NetworkService, ConnectionManager, etc.
│   │   ├── Design/                            # Theme (colors, spacing, animation constants)
│   │   ├── Models/                            # AppState, ServerConfig, ChatCompletionTypes, SwiftData models
│   │   └── Helpers/                           # SSEParser, Extensions
│   └── Resources/
├── CHANGELOG.md
└── CLAUDE.md
```

## API Integration

ClawdBot targets Ollama's OpenAI-compatible API:

| Endpoint | Purpose |
|---|---|
| `GET /` | Health check |
| `GET /api/tags` | List available models |
| `GET /api/ps` | Running models and VRAM usage |
| `POST /v1/chat/completions` | Chat (SSE streaming with `stream: true`) |

Request/response types are in `Core/Models/ChatCompletionTypes.swift`.

## Git Workflow

### Branch Naming
- Features: `claude/feature-description-{sessionId}`
- Bug fixes: `claude/fix-description-{sessionId}`
- Hotfixes: `claude/hotfix-description-{sessionId}`

### Commit Messages
Conventional commits with imperative mood:
```
type: Brief description
```
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`

Update `CHANGELOG.md` with every meaningful change. Keep commits atomic and focused.

## Gotchas

Add new gotchas here as discovered during development.

- Bonjour discovery requires `NSBonjourServices` and `NSLocalNetworkUsageDescription` in Info.plist
- Ollama's `/api/tags` returns models under a `models` key (not `data` like the OpenAI `/v1/models` endpoint)
- Token streaming can overwhelm SwiftUI at high tok/s rates — always batch via `ChatService` at 30Hz
