import SwiftUI

struct TypingIndicatorView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var activeDot = 0
    @State private var animationTask: Task<Void, Never>?

    private let dotCount = 3
    private let dotSize: CGFloat = 10
    private let bounceHeight: CGFloat = -6

    var body: some View {
        HStack {
            HStack(spacing: Theme.spacingSM) {
                ForEach(0..<dotCount, id: \.self) { index in
                    Circle()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: dotSize, height: dotSize)
                        .offset(y: activeDot == index ? bounceHeight : 0)
                }
            }
            .padding(.horizontal, Theme.spacingMD + 4)
            .padding(.vertical, Theme.spacingSM + 8)
            .background(
                Theme.assistantBubbleColor,
                in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
            )
            .accessibilityLabel("ClawdBot is thinking")

            Spacer(minLength: 60)
        }
        .padding(.horizontal, Theme.spacingSM)
        .onAppear { startAnimation() }
        .onDisappear { stopAnimation() }
    }

    // MARK: - Animation

    private func startAnimation() {
        guard !reduceMotion else {
            activeDot = -1
            return
        }

        animationTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(0.4))
                guard !Task.isCancelled else { break }
                withAnimation(Theme.gentleAnimation) {
                    activeDot = (activeDot + 1) % dotCount
                }
            }
        }
    }

    private func stopAnimation() {
        animationTask?.cancel()
        animationTask = nil
    }
}
