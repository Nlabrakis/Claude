# ClawdBot v2.0 Feature Roadmap

## Context

ClawdBot is a solid MVP — streaming chat, conversation persistence, server discovery, model selection, and a polished dark UI all work. This roadmap plans the v2.0 feature set across **chat experience**, **server & model management**, and **platform polish**. Features are prioritized by user impact relative to implementation effort, sequenced to minimize dependencies.

---

## Phase 1: Core Experience Upgrades (Ship First)

### 1. Code Syntax Highlighting
- Colorize code blocks by language (Swift, Python, JS, etc.) using regex-based tokenization into `AttributedString`
- The `language` param is already parsed in `MarkdownTextView` but unused — wire it up
- Add a "Copy Code" button overlay on code blocks and a language label chip
- **Files:** `Core/Helpers/MarkdownTextView.swift`, new `Core/Helpers/SyntaxHighlighter.swift`, `Core/Design/Theme.swift` (add `Theme.Code` color tokens)
- **Complexity:** Low-Medium

### 2. Streaming Markdown Rendering
- Replace the plain `Text(chatService.currentResponse + " |")` streaming bubble with `MarkdownTextView` so formatting appears as tokens arrive
- Handle incomplete markdown gracefully (unclosed code fences, partial bold)
- **Files:** `Features/Chat/Views/ChatView.swift` (streaming bubble), `Core/Helpers/MarkdownTextView.swift` (add `isStreaming` mode)
- **Complexity:** Medium

### 3. Message Edit & Regenerate
- Tap edit on a user message → populates input bar, re-sends, replaces all subsequent messages
- Add `isEdited: Bool`, `editedAt: Date?` to `Message` model; show "Edited" indicator
- Existing `retryLast()` in `ChatViewModel` already demonstrates the delete-and-resend pattern
- **Files:** `Message.swift`, `ChatViewModel.swift`, `ChatView.swift`, `ChatInputBar.swift`, `MessageBubbleView.swift`
- **Complexity:** Medium

### 4. Model Management (Pull / Delete / Details)
- Pull new models by name with streaming download progress bar (`POST /api/pull`)
- Swipe-to-delete models with confirmation (`DELETE /api/delete`)
- Tap for model details: parameters, template, license (`POST /api/show`)
- `/api/pull` streams JSON lines (not SSE) — needs a new line-by-line parser
- **Files:** `NetworkService.swift` (3 new methods), `ModelService.swift`, `ChatCompletionTypes.swift` (new types), `ModelPickerView.swift`, new `ModelDetailView.swift`, new `PullModelView.swift`
- **Complexity:** Medium

### 5. Advanced Generation Parameters
- Expose `top_p`, `frequency_penalty`, `presence_penalty`, `seed`, `max_tokens` beyond just temperature
- New `GenerationParameters` Codable struct bundling all params with sensible defaults
- Settings UI: temperature stays prominent, advanced params behind a disclosure group
- **Files:** `ChatCompletionTypes.swift`, `NetworkService.swift`, new `Core/Models/GenerationParameters.swift`, `SettingsView.swift`, `SettingsViewModel.swift`, `ChatViewModel.swift`
- **Complexity:** Low-Medium

### 6. Enhanced Context Menu & Swipe Actions
- Expand message context menu: Copy, Share, Edit (user), Retry (assistant), Delete
- Add swipe-right-to-reply (quote into input bar) and swipe-left-to-copy
- **Files:** `ChatView.swift`, `ChatViewModel.swift`, new `Features/Chat/Views/SwipeableMessageView.swift`, `ChatInputBar.swift`
- **Complexity:** Low-Medium

### 7. Conversation Export
- Export as Markdown, JSON, or plain text via `ShareLink`
- Action button in chat nav bar or conversation context menu
- **Files:** new `Core/Services/ExportService.swift`, `ChatView.swift`, `ConversationsListView.swift`
- **Complexity:** Low

---

## Phase 2: Search, Performance & Personalization

### 8. Conversation & Message Search
- `.searchable()` on conversations list filtering by title + message content
- In-chat search bar with highlighted matches and `ScrollViewReader.scrollTo()` navigation
- **Files:** `ConversationsListView.swift`, `ConversationsListViewModel.swift`, `ChatView.swift`, `ChatViewModel.swift`, `MessageBubbleView.swift`
- **Complexity:** Medium

### 9. Token Count & Generation Stats
- Track tokens/sec during streaming, store on `Message` model
- Show "142 tokens, 23.4 tok/s" below assistant bubbles
- **Files:** `Message.swift`, `ChatService.swift`, `MessageBubbleView.swift`, `ChatView.swift`
- **Complexity:** Low-Medium

### 10. Server Diagnostics Dashboard
- Enrich `ServerStatusView`: per-model VRAM breakdown, latency history chart (SwiftUI Charts `LineMark`), total disk usage
- Track latency history in `ConnectionManager` (last 60 samples)
- **Files:** `ServerStatusView.swift`, `ServerStatusViewModel.swift`, `ConnectionManager.swift`, `ChatCompletionTypes.swift`, new `LatencyChartView.swift`
- **Complexity:** Medium

### 11. Scroll Position & "Jump to Bottom" FAB
- Floating chevron-down button when scrolled up, with unread message count badge
- Use `onScrollGeometryChange` (iOS 26) for position detection
- **Files:** `ChatView.swift`, `ChatViewModel.swift`
- **Complexity:** Low-Medium

### 12. Accent Color Personalization
- Curated palette (blue, teal, purple, orange, pink, green) in Settings
- `Theme.accentBlue` becomes `Theme.accent` reading from a `ThemeManager`
- **Files:** `Theme.swift`, new `Core/Design/ThemeManager.swift`, `SettingsView.swift`, `App.swift`
- **Complexity:** Low

### 13. Dynamic Type / Font Size Control
- Slider in Settings scaling all `Theme.font()` calls
- Single modification point in `Theme.font(_ style:)` propagates everywhere
- **Files:** `Theme.swift`, `SettingsView.swift`, `SettingsViewModel.swift`
- **Complexity:** Low

### 14. Message Pagination
- Load messages in pages of 50 for long conversations, load older on scroll-to-top
- Replace `conversation?.sortedMessages` with paginated `FetchDescriptor`
- **Files:** `ChatViewModel.swift`, `ChatView.swift`
- **Complexity:** Medium

---

## Phase 3: Platform Integration

### 15. Multi-Server Management
- Save multiple server configs, switch between them, per-server model selection
- Migrate from single `savedServerConfig` to array of `savedServers` + `activeServerID`
- **Files:** `ServerConfig.swift`, `ConnectionManager.swift`, `ConnectionSettingsView.swift`, `AppState.swift`, new `ServerListView.swift`
- **Complexity:** Medium

### 16. App Lock (FaceID / TouchID)
- Optional biometric auth on app launch, blur overlay until authenticated
- Toggle in Settings, uses `LAContext.evaluatePolicy`
- **Files:** new `Core/Services/AuthService.swift`, `ContentView.swift`, `SettingsView.swift`, `Info.plist`
- **Complexity:** Low

### 17. Voice Input (iOS 26 SpeechAnalyzer)
- Mic button in input bar for voice-to-text using iOS 26 `SpeechAnalyzer` + `DictationTranscriber`
- On-device, dramatically faster than old `SFSpeechRecognizer`
- Requires `NSSpeechRecognitionUsageDescription` and `NSMicrophoneUsageDescription`
- **Files:** new `Core/Services/VoiceInputService.swift`, `ChatInputBar.swift`, `Info.plist`, `App.swift`
- **Complexity:** Medium

### 18. Image Attachment for Vision Models
- PhotosPicker / camera → base64 encode → send via Ollama `/api/chat` with `images` array
- Auto-detect vision-capable models (llava, gemma3, etc.) and switch API endpoint
- **Files:** `Message.swift`, `ChatCompletionTypes.swift`, `NetworkService.swift`, `ChatService.swift`, `ChatInputBar.swift`, `MessageBubbleView.swift`
- **Complexity:** Medium-High

### 19. App Intents & Siri Shortcuts
- "Start a new chat with Llama", "What's my server status?", "Send a message"
- Surfaces automatically in Shortcuts app
- **Files:** new `Core/Intents/NewChatIntent.swift`, `ServerStatusIntent.swift`, `SendMessageIntent.swift`, `ClawdBotShortcuts.swift`
- **Complexity:** Medium

---

## Phase 4: Delight & Ecosystem

### 20. Conversation Pinning
- Pin conversations to top of list, "Pinned" section above "Recent"
- Add `isPinned: Bool` to `Conversation` model, pin/unpin in context menu
- **Files:** `Conversation.swift`, `ConversationsListView.swift`
- **Complexity:** Low

### 21. Rich Markdown (Links, Tables, Strikethrough, HR)
- Clickable `[text](url)` links via `AttributedString` `.link` attribute
- GFM tables rendered as `Grid`, horizontal rules as `Divider()`
- **Files:** `MarkdownTextView.swift`, `Theme.swift`
- **Complexity:** Medium

### 22. Conversation Branching
- Fork from any message — creates a new conversation sharing history up to the branch point
- **Files:** `Conversation.swift`, `ChatViewModel.swift`, `ChatView.swift`, `ConversationsListView.swift`
- **Complexity:** High

### 23. Alternate App Icons
- 4-6 icon variants in Settings, uses `UIApplication.setAlternateIconName`
- **Files:** `Assets.xcassets`, `Info.plist`, `SettingsView.swift`
- **Complexity:** Low

### 24. Widgets (Home Screen & Lock Screen)
- Server status widget, quick "New Chat" launcher, last conversation preview
- Requires Widget Extension target + App Groups for shared data
- **Files:** new `ClawdBotWidget/` target, `project.yml`, `ClawdBot.entitlements`, `ConnectionManager.swift`
- **Complexity:** Medium-High

### 25. Liquid Glass Design Refresh
- Replace `.thinMaterial` with `.glassEffect()` on nav bar, input bar, and chrome elements
- Evaluate on message bubbles vs chrome-only
- **Files:** `ChatView.swift`, `ChatInputBar.swift`, `Theme.swift`
- **Complexity:** Low-Medium

### 26. iCloud Sync
- SwiftData + CloudKit via `ModelConfiguration(cloudKitDatabase: .automatic)`
- Conversations sync across iPhone/iPad automatically
- **Files:** `App.swift`, `ClawdBot.entitlements`, `Conversation.swift`, `Message.swift`
- **Complexity:** High

---

## SwiftData Migration Note

Features 3, 9, 18, 20, and 22 all add properties to `Message` or `Conversation`. These should be batched into a single `VersionedSchema` migration. All new properties are optional, enabling lightweight migration.

---

## Summary Table

| # | Feature | Complexity | Phase |
|---|---------|-----------|-------|
| 1 | Code Syntax Highlighting | Low-Med | 1 |
| 2 | Streaming Markdown | Medium | 1 |
| 3 | Message Edit & Regenerate | Medium | 1 |
| 4 | Model Management (Pull/Delete) | Medium | 1 |
| 5 | Advanced Gen Parameters | Low-Med | 1 |
| 6 | Context Menu & Swipe Actions | Low-Med | 1 |
| 7 | Conversation Export | Low | 1 |
| 8 | Search | Medium | 2 |
| 9 | Token Stats | Low-Med | 2 |
| 10 | Server Diagnostics | Medium | 2 |
| 11 | Jump to Bottom FAB | Low-Med | 2 |
| 12 | Accent Colors | Low | 2 |
| 13 | Font Size Control | Low | 2 |
| 14 | Message Pagination | Medium | 2 |
| 15 | Multi-Server | Medium | 3 |
| 16 | App Lock | Low | 3 |
| 17 | Voice Input | Medium | 3 |
| 18 | Image Attachment (Vision) | Med-High | 3 |
| 19 | Siri Shortcuts | Medium | 3 |
| 20 | Pinning | Low | 4 |
| 21 | Rich Markdown | Medium | 4 |
| 22 | Branching | High | 4 |
| 23 | Alt App Icons | Low | 4 |
| 24 | Widgets | Med-High | 4 |
| 25 | Liquid Glass | Low-Med | 4 |
| 26 | iCloud Sync | High | 4 |

---

## Verification

After implementing each feature:
1. Build in Xcode — zero errors, zero warnings
2. Run on iPhone 17 Pro Max — verify UI fits, no layout overflow
3. Test the specific feature end-to-end
4. Verify existing features still work (chat streaming, connection, model selection)
5. Check Swift 6 strict concurrency — no data race warnings
