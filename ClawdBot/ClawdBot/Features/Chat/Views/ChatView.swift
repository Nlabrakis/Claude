import SwiftUI
import SwiftData

struct ChatView: View {
    let conversationID: String

    @Environment(AppState.self) private var appState
    @Environment(NetworkService.self) private var networkService
    @Environment(ChatService.self) private var chatService
    @Environment(ModelService.self) private var modelService
    @Environment(ConnectionManager.self) private var connectionManager
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewModel = ChatViewModel()
    @State private var scrollProxy: ScrollViewProxy?

    /// Whether the typing indicator is visible (streaming started, no tokens yet).
    private var isWaitingForFirstToken: Bool {
        chatService.isStreaming && chatService.currentResponse.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            chatNavBar

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    if viewModel.messages.isEmpty && !chatService.isStreaming {
                        welcomeState
                    } else {
                        messageList
                    }
                }
                .onAppear { scrollProxy = proxy }
                .onChange(of: chatService.currentResponse) {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.messages.count) {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: chatService.isStreaming) {
                    scrollToBottom(proxy: proxy)
                }
            }

            // Connection warning
            if connectionManager.status != .connected {
                connectionBanner
            }

            // Input
            ChatInputBar(
                text: $viewModel.inputText,
                isStreaming: chatService.isStreaming,
                isConnected: connectionManager.status == .connected,
                onSend: { sendMessage() },
                onStop: { stopGeneration() }
            )
        }
        .background(Theme.backgroundPrimary)
        .onAppear {
            viewModel.configure(conversationID: conversationID, modelContext: modelContext)
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "")
        }
    }

    // MARK: - Nav Bar

    private var chatNavBar: some View {
        HStack {
            Button {
                appState.goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: Theme.iconSize, weight: .medium))
            }
            .frame(minWidth: Theme.minTapTarget, minHeight: Theme.minTapTarget)

            VStack(spacing: 2) {
                Text(viewModel.conversationTitle)
                    .font(Theme.font(.headline))
                    .lineLimit(1)

                if let model = modelService.selectedModelName {
                    Text(model.replacingOccurrences(of: ":latest", with: ""))
                        .font(Theme.font(.caption))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)

            Button {
                appState.navigate(to: .modelPicker)
            } label: {
                Image(systemName: "cpu")
                    .font(.system(size: Theme.iconSize, weight: .medium))
            }
            .frame(minWidth: Theme.minTapTarget, minHeight: Theme.minTapTarget)
        }
        .padding(.horizontal, Theme.spacingSM)
        .background(.thinMaterial)
    }

    // MARK: - Welcome State

    private var welcomeState: some View {
        VStack(spacing: Theme.spacingMD) {
            Spacer()

            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.secondary.opacity(0.6))

            Text("Start a conversation")
                .font(Theme.font(.title3))
                .foregroundStyle(.secondary)

            Text("Type a message below to chat with your model.")
                .font(Theme.font(.subheadline))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingXL)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, Theme.spacingXL * 2)
    }

    // MARK: - Message List

    private var messageList: some View {
        LazyVStack(spacing: Theme.spacingSM) {
            ForEach(viewModel.messages) { message in
                MessageBubbleView(
                    message: message,
                    isStreaming: false
                )
                .id(message.id)
                .contextMenu {
                    contextMenuItems(for: message)
                }
            }

            // Typing indicator with model loading hint
            if isWaitingForFirstToken {
                VStack(spacing: 8) {
                    TypingIndicatorView()
                    Text("Loading model into GPU...")
                        .font(Theme.font(.caption))
                        .foregroundStyle(.tertiary)
                }
                .id("typing")
                .transition(.opacity)
            }

            // Streaming response (tokens arriving)
            if chatService.isStreaming, !chatService.currentResponse.isEmpty {
                streamingBubble
                    .id("streaming")
            }
        }
        .padding(.vertical, Theme.spacingSM)
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func contextMenuItems(for message: Message) -> some View {
        Button {
            UIPasteboard.general.string = message.content
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }

        if message.role == .assistant {
            Button {
                hapticsService.tap()
                Task {
                    await viewModel.retryLast(
                        chatService: chatService,
                        networkService: networkService,
                        modelName: modelService.selectedModelName
                    )
                    hapticsService.responseComplete()
                }
            } label: {
                Label("Retry", systemImage: "arrow.counterclockwise")
            }
        }
    }

    // MARK: - Streaming Bubble

    private var streamingBubble: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(chatService.currentResponse + "  \u{258C}")
                    .font(Theme.font(.body))
                    .foregroundStyle(Theme.assistantTextColor)
                    .textSelection(.enabled)
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.vertical, Theme.spacingSM + 4)
                    .background(
                        Theme.assistantBubbleColor,
                        in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    )
            }

            Spacer(minLength: 60)
        }
        .padding(.horizontal, Theme.spacingSM)
    }

    // MARK: - Connection Banner

    private var connectionBanner: some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: "wifi.slash")
                .font(Theme.font(.caption))

            Text(connectionManager.status.label)
                .font(Theme.font(.caption))

            Spacer()

            if case .error = connectionManager.status {
                Button("Retry") {
                    Task { await connectionManager.reconnect() }
                }
                .font(Theme.font(.caption).bold())
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, Theme.spacingSM)
        .background(Color.orange.opacity(0.1))
    }

    // MARK: - Actions

    private func sendMessage() {
        hapticsService.messageSent()
        Task {
            await viewModel.send(
                chatService: chatService,
                networkService: networkService,
                modelName: modelService.selectedModelName
            )
            hapticsService.responseComplete()
        }
    }

    private func stopGeneration() {
        chatService.stopGeneration()
        networkService.cancelCurrentStream()
        hapticsService.tap()
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        let targetID: String? = if isWaitingForFirstToken {
            "typing"
        } else if chatService.isStreaming {
            "streaming"
        } else {
            viewModel.messages.last?.id
        }

        guard let id = targetID else { return }
        withAnimation(reduceMotion ? .none : .easeOut(duration: 0.2)) {
            proxy.scrollTo(id, anchor: .bottom)
        }
    }
}
