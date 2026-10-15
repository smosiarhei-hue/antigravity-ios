import SwiftUI

public enum AntigravityTheme {
    // MARK: - Colors
    public static let background = Color(red: 0.05, green: 0.07, blue: 0.09) // #0d1117
    public static let surface = Color(red: 0.09, green: 0.11, blue: 0.13)    // #161b22
    public static let surfaceSecondary = Color(red: 0.13, green: 0.15, blue: 0.18) // #21262d
    public static let border = Color(red: 0.19, green: 0.21, blue: 0.24)     // #30363d
    
    public static let accent = Color(red: 0.35, green: 0.65, blue: 1.0)      // #58a6ff
    public static let accentPurple = Color(red: 0.64, green: 0.44, blue: 0.97) // #a371f7
    public static let purple = accentPurple
    public static let success = Color(red: 0.25, green: 0.73, blue: 0.31)    // #3fb950
    public static let warning = Color(red: 0.85, green: 0.65, blue: 0.13)    // #d29922
    public static let danger = Color(red: 0.97, green: 0.32, blue: 0.29)     // #f85149
    
    public static let textPrimary = Color(red: 0.94, green: 0.96, blue: 0.99)   // #f0f6fc
    public static let textSecondary = Color(red: 0.55, green: 0.58, blue: 0.62) // #8b949e
    public static let textTertiary = Color(red: 0.43, green: 0.46, blue: 0.51)  // #6e7681

    // MARK: - Fluid Springs (Apple Design WWDC)
    public static let fluidSpring = Animation.snappy(duration: 0.35)
    public static let snappySpring = Animation.snappy(duration: 0.25, extraBounce: 0.08)
    public static let gentleSpring = Animation.smooth(duration: 0.45)
}
