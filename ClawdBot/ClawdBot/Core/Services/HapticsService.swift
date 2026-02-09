import CoreHaptics
import UIKit

@MainActor
@Observable
final class HapticsService {
    private var engine: CHHapticEngine?

    init() {
        prepareEngine()
    }

    // MARK: - Simple Feedback

    func messageSent() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func responseComplete() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func connectionEstablished() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func connectionLost() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Engine Setup

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            try engine?.start()
        } catch {
            // Haptics unavailable — degrade gracefully
        }
    }
}
