import SwiftUI
import SwiftData

struct ConversationsListView: View {
    @Environment(AppState.self) private var appState
    @Environment(ConnectionManager.self) private var connectionManager
    @Environment(ModelService.self) private var modelService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Query(sort: \Conversation.updatedAt, order: .reverse)
    private var conversations: [Conversation]

    @State private var viewModel = ConversationsListViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            // List
            if conversations.isEmpty {
                emptyState
            } else {
                conversationList
            }
        }
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
        .alert("Rename Conversation", isPresented: .init(
            get: { viewModel.editingConversation != nil },
            set: { if !$0 { viewModel.editingConversation = nil } }
        )) {
            TextField("Title", text: $viewModel.editTitle)
            Button("Save") { viewModel.confirmRename() }
            Button("Cancel", role: .cancel) { viewModel.editingConversation = nil }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("ClawdBot")
                .font(Theme.font(.largeTitle).bold())

            Spacer()

            connectionIndicator

            Button {
                appState.navigate(to: .settings)
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: Theme.iconSize))
            }
            .frame(minWidth: Theme.minTapTarget, minHeight: Theme.minTapTarget)
        }
        .padding(.horizontal, Theme.spacingMD)
    }

    // MARK: - Connection Indicator

    private var connectionIndicator: some View {
        Button {
            appState.navigate(to: .serverStatus)
        } label: {
            HStack(spacing: Theme.spacingXS) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)

                Text(connectionManager.status.label)
                    .font(Theme.font(.caption))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: Theme.minTapTarget)
    }

    private var statusColor: Color {
        switch connectionManager.status {
        case .connected: Theme.connectedColor
        case .connecting: Theme.connectingColor
        case .disconnected, .error: Theme.disconnectedColor
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()

            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Conversations")
                .font(Theme.font(.title2))
                .foregroundStyle(.secondary)

            Text("Start chatting with your local AI model")
                .font(Theme.font(.body))
                .foregroundStyle(.tertiary)

            newChatButton

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Conversation List

    private var conversationList: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: Theme.spacingSM) {
                    ForEach(conversations) { conversation in
                        conversationRow(conversation)
                    }
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
            }

            Divider()

            // New chat button at bottom
            newChatButton
                .padding(Theme.spacingMD)
        }
    }

    private func conversationRow(_ conversation: Conversation) -> some View {
        Button {
            hapticsService.tap()
            appState.navigate(to: .chat(conversationID: conversation.id))
        } label: {
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                HStack {
                    Text(conversation.title)
                        .font(Theme.font(.headline))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer()

                    Text(conversation.updatedAt.shortFormatted)
                        .font(Theme.font(.caption2))
                        .foregroundStyle(.tertiary)
                }

                Text(conversation.preview)
                    .font(Theme.font(.subheadline))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if let model = conversation.modelName {
                    Text(model.replacingOccurrences(of: ":latest", with: ""))
                        .font(Theme.font(.caption2))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(Theme.spacingMD)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
        }
        .contextMenu {
            Button {
                viewModel.startRenaming(conversation)
            } label: {
                Label("Rename", systemImage: "pencil")
            }

            Button(role: .destructive) {
                viewModel.delete(conversation)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .frame(minHeight: Theme.minTapTarget)
    }

    // MARK: - New Chat Button

    private var newChatButton: some View {
        Button {
            hapticsService.tap()
            let conversation = viewModel.createConversation(modelName: modelService.selectedModelName)
            appState.navigate(to: .chat(conversationID: conversation.id))
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                Text("New Chat")
                    .font(Theme.font(.headline))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: Theme.minTapTarget)
            .background(Color.blue, in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
            .foregroundStyle(.white)
        }
    }
}
