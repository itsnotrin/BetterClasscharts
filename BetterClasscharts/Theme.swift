import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct Theme {
    static let light = ThemeColors(
        background: Color(UIColor.systemBackground),
        surface: Color(UIColor.secondarySystemBackground),
        text: Color(UIColor.label),
        subtext: Color(UIColor.secondaryLabel),
        primary: Color.blue,
        secondary: Color.gray,
        accent: Color.blue,
        success: Color.green,
        error: Color.red
    )
    
    static let dark = ThemeColors(
        background: Color(UIColor.systemBackground),
        surface: Color(UIColor.secondarySystemBackground),
        text: Color(UIColor.label),
        subtext: Color(UIColor.secondaryLabel),
        primary: Color.blue,
        secondary: Color.gray,
        accent: Color.blue,
        success: Color.green,
        error: Color.red
    )
    
    // Catppuccin Latte (Light)
    static let catppuccinLatte = ThemeColors(
        background: Color(hex: "#EFF1F5"),
        surface: Color(hex: "#E6E9EF"),
        text: Color(hex: "#4C4F69"),
        subtext: Color(hex: "#6C6F85"),
        primary: Color(hex: "#1E66F5"),
        secondary: Color(hex: "#7287FD"),
        accent: Color(hex: "#8839EF"),
        success: Color(hex: "#40A02B"),
        error: Color(hex: "#D20F39")
    )
    
    // Catppuccin Frappé
    static let catppuccinFrappe = ThemeColors(
        background: Color(hex: "#303446"),
        surface: Color(hex: "#292C3C"),
        text: Color(hex: "#C6D0F5"),
        subtext: Color(hex: "#B5BFE2"),
        primary: Color(hex: "#8CAAEE"),
        secondary: Color(hex: "#BABBF1"),
        accent: Color(hex: "#CA9EE6"),
        success: Color(hex: "#A6D189"),
        error: Color(hex: "#E78284")
    )
    
    // Catppuccin Macchiato
    static let catppuccinMacchiato = ThemeColors(
        background: Color(hex: "#24273A"),
        surface: Color(hex: "#1E2030"),
        text: Color(hex: "#CAD3F5"),
        subtext: Color(hex: "#B8C0E0"),
        primary: Color(hex: "#8AADF4"),
        secondary: Color(hex: "#B7BDF8"),
        accent: Color(hex: "#C6A0F6"),
        success: Color(hex: "#A6DA95"),
        error: Color(hex: "#ED8796")
    )
    
    // Catppuccin Mocha
    static let catppuccinMocha = ThemeColors(
        background: Color(hex: "#1E1E2E"),
        surface: Color(hex: "#181825"),
        text: Color(hex: "#CDD6F4"),
        subtext: Color(hex: "#BAC2DE"),
        primary: Color(hex: "#89B4FA"),
        secondary: Color(hex: "#B4BEFE"),
        accent: Color(hex: "#CBA6F7"),
        success: Color(hex: "#A6E3A1"),
        error: Color(hex: "#F38BA8")
    )
}

// Environment key for theme colors
struct ThemeColorsKey: EnvironmentKey {
    static let defaultValue: ThemeColors = Theme.light
}

extension EnvironmentValues {
    var themeColors: ThemeColors {
        get { self[ThemeColorsKey.self] }
        set { self[ThemeColorsKey.self] = newValue }
    }
}

// Helper extension to create colors from hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 