import SwiftUI

enum Theme {
    // MARK: - Typography

    static func font(_ style: Font.TextStyle) -> Font {
        .system(style, design: .default)
    }

    // MARK: - Colors (Dark-first, Apple product page aesthetic)

    static let backgroundPrimary = Color(white: 0.0)
    static let backgroundSecondary = Color(white: 0.06)
    static let surfaceColor = Color(white: 0.11)
    static let surfaceColorLight = Color(white: 0.16)
    static let accentBlue = Color(red: 0.04, green: 0.52, blue: 1.0)

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Sizing

    static let minTapTarget: CGFloat = 48
    static let iconSize: CGFloat = 28
    static let avatarSize: CGFloat = 40
    static let inputBarMinHeight: CGFloat = 50
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSM: CGFloat = 10

    // MARK: - Animation

    static let animationDuration: Double = 0.4
    static let animationDurationSlow: Double = 0.6
    static let springAnimation: Animation = .spring(duration: 0.5, bounce: 0.3)
    static let gentleAnimation: Animation = .easeInOut(duration: 0.4)

    static func conditionalAnimation(_ reduceMotion: Bool) -> Animation? {
        reduceMotion ? .none : springAnimation
    }

    // MARK: - Message Bubble Colors

    static let userBubbleColor = accentBlue
    static let assistantBubbleColor = surfaceColor
    static let userTextColor = Color.white
    static let assistantTextColor = Color(white: 0.88)

    // MARK: - Connection Status Colors

    static let connectedColor = Color(red: 0.2, green: 0.84, blue: 0.42)
    static let connectingColor = Color(red: 1.0, green: 0.76, blue: 0.0)
    static let disconnectedColor = Color(red: 1.0, green: 0.32, blue: 0.32)
}
