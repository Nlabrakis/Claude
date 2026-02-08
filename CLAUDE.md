# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Tech Stack

| Layer          | Technology                                      |
|----------------|------------------------------------------------|
| UI Framework   | SwiftUI (iOS 26 SDK)                           |
| Language       | Swift 6.2                                       |
| Architecture   | MVVM with `@Observable` (Observation framework) |
| Audio          | AVFoundation                                    |
| Haptics        | Core Haptics                                    |
| State          | `@Observable` + `@State` + Environment injection|
| Navigation     | Custom screen enum (no deep navigation stacks)  |
| Min Target     | iOS 26                                          |

## Key Patterns

### State Management

- Use `@Observable` macro on all ViewModels and services — **never** `ObservableObject`/`@Published`
- Use `@State private var` to hold `@Observable` instances in views
- Inject shared services via `.environment()` at the app root
- Access shared services with `@Environment(ServiceType.self)`

### Architecture

- **MVVM**: Views own no business logic. ViewModels hold state and logic. Services handle system resources.
- **Centralized AudioService**: Single `@Observable` service manages all audio (narration, music, effects) to prevent playback conflicts
- **Centralized HapticsService**: Single service for haptic feedback patterns
- **TimerService**: Manages session time limits
- **AppState**: Centralized navigation and app-level state

### Environment Injection Pattern

```swift
// In App.swift — create and inject at root
@State private var audioService = AudioService()
ContentView()
    .environment(audioService)

// In any child view — access via environment
@Environment(AudioService.self) private var audioService
```

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
ProjectName/
├── ProjectName/
│   ├── App.swift                          # @main entry, environment injection
│   ├── ContentView.swift                  # Root view with screen routing
│   ├── Features/
│   │   ├── FeatureName/Views/             # SwiftUI views per feature
│   │   └── FeatureName/ViewModels/        # Feature logic and state
│   ├── Core/
│   │   ├── Services/                      # AudioService, HapticsService, TimerService
│   │   ├── Design/                        # Color tokens, theme constants
│   │   ├── Models/                        # Data models, AppState
│   │   └── Helpers/                       # Extensions, utilities
│   └── Resources/
│       └── Audio/
│           ├── Narration/                 # Narration audio files
│           ├── Music/                     # Background music tracks
│           └── Effects/                   # Sound effect files
├── CHANGELOG.md
└── CLAUDE.md
```

## Audio Strategy

- **Narration**: Pre-recorded narration (one file per section/page)
- **Background Music**: Gentle, looping ambient tracks
- **Sound Effects**: Positive reinforcement sounds (chimes, applause)
- **Ducking**: Music volume ducks when narration plays
- **Session**: `AVAudioSession` configured for playback, respects silent mode

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

(None yet — project just initialized)
