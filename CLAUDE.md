# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ClawdBot is an iOS 26 chat client for interacting with a local LLM running on an Ollama server (RTX 5080 GPU at home). Phase 1 targets same-network communication. Phase 2 will add remote access via Tailscale.

## Build & Run

```bash
# Generate/regenerate the Xcode project (requires XcodeGen via Homebrew)
./ClawdBot/generate_xcodeproj.sh

# Open in Xcode — you must set your development team under Signing & Capabilities
open ClawdBot/ClawdBot.xcodeproj
```

The project uses **XcodeGen** with `ClawdBot/project.yml` as the spec. Re-run `generate_xcodeproj.sh` after adding or removing Swift files. No test target exists yet.

## Tech Stack

| Layer          | Technology                                      |
|----------------|------------------------------------------------|
| UI Framework   | SwiftUI (iOS 26 SDK)                           |
| Language       | Swift 6.0 with **strict concurrency** (`SWIFT_STRICT_CONCURRENCY: complete`) |
| Architecture   | MVVM with `@Observable` (Observation framework) |
| Networking     | URLSession (SSE streaming via `bytes.lines`)    |
| Persistence    | SwiftData (`Conversation`, `Message` models)    |
| Discovery      | Network.framework (`NWBrowser` for Bonjour)     |
| Haptics        | Core Haptics                                    |
| State          | `@Observable` + `@MainActor` + Environment injection |
| Navigation     | Custom screen enum (no NavigationStack)         |
| Backend        | Ollama (OpenAI-compatible `/v1/chat/completions`)|
| Min Target     | iOS 26                                          |

## Key Patterns

### Swift 6 Strict Concurrency (Critical)

All core services are `@MainActor @Observable`. This is **required** for Swift 6 strict concurrency — without it, passing services across `Task` boundaries in SwiftUI triggers "Sending non-Sendable type risks data races" errors.

```swift
@MainActor
@Observable
final class SomeService { ... }
```

**Currently `@MainActor`:** ChatService, NetworkService, ConnectionManager, ServerDiscoveryService, ModelService, HapticsService, SettingsViewModel, ConversationsListViewModel, ServerStatusViewModel, ModelPickerViewModel, ChatViewModel

In practice, **every** `@Observable` class in this project is `@MainActor`. When adding new services or ViewModels, always apply it.

### The Service-Passing Anti-Pattern (Biggest Gotcha)

**Never pass `@Environment` services as function parameters to ViewModel async methods.** This triggers Swift 6 "sending" errors because non-Sendable types cross isolation boundaries at `await` suspension points.

```swift
// BAD — causes "Sending 'modelService' risks causing data races"
func refresh(modelService: ModelService) async {
    await modelService.fetchModels(using: networkService)
}

// GOOD — inline the service call in the View
Task {
    viewModel.isRefreshing = true
    await modelService.fetchModels(using: networkService)
    viewModel.isRefreshing = false
}
```

### Network.framework Callbacks

`NWBrowser` and `NWPathMonitor` callbacks predate Swift concurrency. Use `@preconcurrency import Network` to suppress Sendable warnings on their handler closures.

### State Management

- Use `@Observable` macro on all ViewModels and services — **never** `ObservableObject`/`@Published`
- Use `@State private var` to hold `@Observable` instances in views
- Inject shared services via `.environment()` at the app root (`App.swift`)
- Access shared services with `@Environment(ServiceType.self)`

### Architecture

- **MVVM**: Views own no business logic. ViewModels hold state and logic. Services handle system resources.
- **Services are singletons** created in `App.swift` with `@State` and injected via `.environment()`
- **ViewModels are local** to Views, created with `@State private var viewModel = SomeViewModel()`
- **ViewModels do NOT store service references** — services are accessed from `@Environment` in Views and operations are inlined

### Streaming Pattern

Token streaming uses SSE over HTTP. In `NetworkService.streamChatCompletion`, `self` properties are extracted into local `let` variables before the `AsyncThrowingStream` closure to avoid capturing `@MainActor`-isolated `self` in a `sending` closure. Tokens are batched at ~30Hz via `ChatService` to prevent UI jank.

### Navigation

`AppState` uses a manual `[Screen]` navigation stack. Never replace with `NavigationStack`/`NavigationPath` — the custom approach gives full control over transitions. Supports `navigate(to:)`, `goBack()`, and `popToRoot()`.

## Design System — Apple Dark Aesthetic

The UI follows the Apple MacBook Pro product page aesthetic: dark, minimal, premium. All design tokens live in `Core/Design/Theme.swift`.

### Philosophy

- **Dark-first**: Pure black background, dark gray surfaces, no light mode
- **Minimal chrome**: Content speaks for itself, UI elements recede
- **Apple product page vibe**: Clean typography, ample white space, subtle depth via surface colors
- **Forced dark mode**: `ContentView` applies `.preferredColorScheme(.dark)` globally

### Typography

**SF Pro** (system default, not Rounded) — accessed via `Theme.font(.textStyle)`:
```swift
Theme.font(.largeTitle)  // SF Pro, not .rounded
Theme.font(.headline)
Theme.font(.body)
Theme.font(.caption)
```

### Color Palette

| Token | Value | Usage |
|---|---|---|
| `backgroundPrimary` | `Color(white: 0.0)` — pure black | App background, applied in ContentView |
| `backgroundSecondary` | `Color(white: 0.06)` | Subtle elevation above black |
| `surfaceColor` | `Color(white: 0.11)` | Cards, text fields, list rows |
| `surfaceColorLight` | `Color(white: 0.16)` | Hover/pressed states |
| `accentBlue` | `rgb(0.04, 0.52, 1.0)` — Apple blue | Primary buttons, links, selected states |

**Never use raw `.blue`, `.gray`, or `Color(.systemGray6)`.** Always use `Theme.accentBlue`, `Theme.surfaceColor`, etc.

### Message Bubbles

| Token | Value |
|---|---|
| `userBubbleColor` | `accentBlue` (Apple blue) |
| `assistantBubbleColor` | `surfaceColor` (dark gray) |
| `userTextColor` | `Color.white` |
| `assistantTextColor` | `Color(white: 0.88)` — slightly off-white for readability |

Timestamps are hidden on message bubbles for a cleaner aesthetic.

### Status Colors

| Token | Value | Usage |
|---|---|---|
| `connectedColor` | `rgb(0.2, 0.84, 0.42)` — Apple green | Connected indicator |
| `connectingColor` | `rgb(1.0, 0.76, 0.0)` — Apple amber | Connecting spinner |
| `disconnectedColor` | `rgb(1.0, 0.32, 0.32)` — Apple red | Error/disconnected |

### Spacing Scale

`spacingXS: 4` → `spacingSM: 8` → `spacingMD: 16` → `spacingLG: 24` → `spacingXL: 32`

### Sizing

- **Tap targets**: `minTapTarget: 48` — slightly above Apple's 44pt standard
- **Corner radius**: `cornerRadius: 16` (bubbles), `cornerRadiusSM: 10` (cards/fields)
- **Icons**: `iconSize: 28`

### Materials

- Nav bars and input bars use `.thinMaterial` (not `.ultraThinMaterial`) for subtle depth
- Connection banners use `Color.orange.opacity(0.1)` for subtlety

### Animation

- `gentleAnimation`: `.easeInOut(duration: 0.4)` — default for most transitions
- `springAnimation`: `.spring(duration: 0.5, bounce: 0.3)` — for interactive elements
- Always wrap in `Theme.conditionalAnimation(reduceMotion)` to respect accessibility

### Rules When Adding New Views

1. **No raw colors** — always use `Theme.*` tokens
2. **No `.system(.style, design: .rounded)`** — use `Theme.font(.style)` which returns SF Pro default
3. **Surface backgrounds** use `Theme.surfaceColor` in a `RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous)`
4. **Buttons** get `.frame(minHeight: Theme.minTapTarget)` for accessibility
5. **Selected states** use `Theme.accentBlue.opacity(0.15)` background, not full-color highlights

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

- Bonjour discovery requires `NSBonjourServices` and `NSLocalNetworkUsageDescription` in Info.plist (both are now set)
- Server discovery uses `getifaddrs()` to detect the iPhone's WiFi IP, then scans the entire /24 subnet in parallel. This works regardless of whether the server uses ethernet or WiFi — as long as iPhone and server share a subnet
- Ollama's `/api/tags` returns models under a `models` key (not `data` like OpenAI's `/v1/models`)
- Token streaming can overwhelm SwiftUI at high tok/s — always batch via `ChatService` at 30Hz
- `SettingsViewModel` exposes static `savedTemperature` and `savedSystemPrompt` for reading defaults without instantiating the view model
- `Text` concatenation with `+` is deprecated in iOS 26 — `MarkdownTextView` now uses `AttributedString` instead
- `NetworkService.cancelCurrentStream()` is a no-op — cancellation flows through the stream's `onTermination` handler chain: `ChatService.stopGeneration()` → `streamTask.cancel()` → `onTermination` → inner network task cancelled
- SourceKit "Cannot find X in scope" diagnostics in single-file mode are false positives — they resolve on a real Xcode build
