import SwiftUI

enum Theme {
    // MARK: - Typography

    static func font(_ style: Font.TextStyle) -> Font {
        .system(style, design: .rounded)
    }

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Sizing

    static let minTapTarget: CGFloat = 80
    static let iconSize: CGFloat = 28
    static let avatarSize: CGFloat = 40
    static let inputBarMinHeight: CGFloat = 50
    static let cornerRadius: CGFloat = 20
    static let cornerRadiusSM: CGFloat = 12

    // MARK: - Animation

    static let animationDuration: Double = 0.4
    static let animationDurationSlow: Double = 0.6
    static let springAnimation: Animation = .spring(duration: 0.5, bounce: 0.3)
    static let gentleAnimation: Animation = .easeInOut(duration: 0.4)

    static func conditionalAnimation(_ reduceMotion: Bool) -> Animation? {
        reduceMotion ? .none : springAnimation
    }

    // MARK: - Message Bubble Colors

    static let userBubbleColor = Color.blue
    static let assistantBubbleColor = Color(.systemGray5)
    static let userTextColor = Color.white
    static let assistantTextColor = Color.primary

    // MARK: - Connection Status Colors

    static let connectedColor = Color.green
    static let connectingColor = Color.yellow
    static let disconnectedColor = Color.red
}
