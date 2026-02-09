import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared = false

    var body: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()

            // App icon and welcome
            VStack(spacing: Theme.spacingMD) {
                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Theme.accentBlue)
                    .symbolEffect(.breathe, options: reduceMotion ? .nonRepeating : .repeating)

                Text("Welcome to ClawdBot")
                    .font(Theme.font(.largeTitle).bold())
                    .multilineTextAlignment(.center)

                Text("Chat with AI models running on your local Ollama server")
                    .font(Theme.font(.body))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacingLG)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            Spacer()

            // Feature highlights
            VStack(alignment: .leading, spacing: Theme.spacingMD) {
                featureRow(
                    icon: "bolt.fill",
                    text: "Stream responses in real-time"
                )
                featureRow(
                    icon: "arrow.triangle.swap",
                    text: "Switch between models"
                )
                featureRow(
                    icon: "internaldrive.fill",
                    text: "Conversations saved locally"
                )
            }
            .padding(.horizontal, Theme.spacingXL)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            Spacer()

            // Actions
            VStack(spacing: Theme.spacingMD) {
                connectButton

                skipButton
            }
            .padding(.horizontal, Theme.spacingLG)
            .padding(.bottom, Theme.spacingLG)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(Theme.conditionalAnimation(reduceMotion) ?? .easeInOut(duration: 0.6)) {
                appeared = true
            }
        }
    }

    // MARK: - Feature Row

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(Theme.accentBlue)
                .frame(width: 32, alignment: .center)

            Text(text)
                .font(Theme.font(.body))
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Connect Button

    private var connectButton: some View {
        Button {
            appState.navigate(to: .connectionSettings)
        } label: {
            HStack {
                Image(systemName: "server.rack")
                    .font(.system(size: 20))
                Text("Connect to Server")
                    .font(Theme.font(.headline))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: Theme.minTapTarget)
            .background(Theme.accentBlue, in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
            .foregroundStyle(.white)
        }
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        Button {
            appState.navigate(to: .conversations)
        } label: {
            Text("Skip for now")
                .font(Theme.font(.subheadline))
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: Theme.minTapTarget)
    }
}
