# Changelog

All notable changes to ClawdBot will be documented in this file.

## [Unreleased]

### Added
- Project scaffolding with MVVM architecture, feature-based directory structure
- `NetworkService` with SSE streaming for Ollama's OpenAI-compatible chat completions API
- `ServerDiscoveryService` with Bonjour/mDNS auto-discovery and local network scanning
- `ConnectionManager` with connection state machine and health check polling
- `ChatService` with 30Hz token batching for smooth streaming display
- `ModelService` for fetching and selecting available Ollama models
- `HapticsService` for haptic feedback throughout the app
- `AppState` with screen enum navigation
- SwiftData persistence models (`Conversation`, `Message`)
- Chat interface with streaming token display, message bubbles, and input bar
- Conversations list with create, rename, delete, and context menus
- Model picker with search and selection
- Server status dashboard showing connection info, running models, and VRAM usage
- Settings screen with connection management, temperature control, and system prompt
- Connection settings with Bonjour discovery list and manual IP/port entry
- SSE parser for server-sent event streams
- Theme system with SF Pro Rounded typography, 80pt tap targets, gentle animations

### Improved (Phase 1.1)
- **Navigation**: Replaced single `previousScreen` with proper navigation stack array in `AppState`, supporting unlimited back history and `popToRoot()`
- **Markdown rendering**: New `MarkdownTextView` renders assistant responses with fenced code blocks, headers, lists, inline code, bold, and italic
- **Typing indicator**: New `TypingIndicatorView` with bouncing dots animation shown while waiting for first LLM token
- **Chat UX**: Welcome state for empty conversations, context menus on messages (Copy, Retry), improved scroll-to-bottom targeting
- **Settings integration**: Temperature and system prompt from Settings now flow into chat requests; new conversations inherit the default system prompt
- **Input bar polish**: Dynamic placeholder when disconnected, animated send/stop button transition
- **Onboarding**: New `OnboardingView` shown on first launch when no saved server exists, with feature highlights and connect/skip options
- **Connection banner**: Inline warning bar in chat when server connection is lost, with retry button for error states
- **Conversations list**: Disconnect-aware empty state with "Connect to Server" prompt when not connected
