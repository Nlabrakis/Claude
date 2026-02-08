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
