import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case dracula = "Dracula"
    case catppuccinLatte = "Catppuccin Latte"
    case catppuccinFrappe = "Catppuccin Frappé"
    case catppuccinMacchiato = "Catppuccin Macchiato"
    case catppuccinMocha = "Catppuccin Mocha"
}

enum Theme {
    // Dracula colors
    static let draculaBase = Color(hex: "282a36")
    static let draculaText = Color(hex: "f8f8f2")
    static let draculaSubtext0 = Color(hex: "6272a4")
    static let draculaSurface0 = Color(hex: "44475a")
    static let draculaMauve = Color(hex: "bd93f9")  // Purple in Dracula
    static let draculaGreen = Color(hex: "50fa7b")
    static let draculaPink = Color(hex: "ff79c6")
    static let draculaRed = Color(hex: "ff5555")

    // Catppuccin Latte colors
    static let latteBase = Color(hex: "eff1f5")
    static let latteText = Color(hex: "4c4f69")
    static let latteSubtext0 = Color(hex: "6c6f85")
    static let latteSurface0 = Color(hex: "ccd0da")
    static let latteMauve = Color(hex: "8839ef")

    // Catppuccin Frappé colors
    static let frappeBase = Color(hex: "303446")
    static let frappeText = Color(hex: "c6d0f5")
    static let frappeSubtext0 = Color(hex: "a5adce")
    static let frappeSurface0 = Color(hex: "414559")
    static let frappeMauve = Color(hex: "ca9ee6")

    // Catppuccin Macchiato colors
    static let base = Color(hex: "24273a")
    static let mantle = Color(hex: "1e2030")
    static let crust = Color(hex: "181926")
    
    static let text = Color(hex: "cad3f5")
    static let subtext1 = Color(hex: "b8c0e0")
    static let subtext0 = Color(hex: "a5adcb")
    
    static let surface2 = Color(hex: "5b6078")
    static let surface1 = Color(hex: "494d64")
    static let surface0 = Color(hex: "363a4f")
    
    static let overlay2 = Color(hex: "939ab7")
    static let overlay1 = Color(hex: "8087a2")
    static let overlay0 = Color(hex: "6e738d")
    
    static let blue = Color(hex: "8aadf4")
    static let lavender = Color(hex: "b7bdf8")
    static let sapphire = Color(hex: "7dc4e4")
    static let sky = Color(hex: "91d7e3")
    static let teal = Color(hex: "8bd5ca")
    static let green = Color(hex: "a6da95")
    static let yellow = Color(hex: "eed49f")
    static let peach = Color(hex: "f5a97f")
    static let maroon = Color(hex: "ee99a0")
    static let red = Color(hex: "ed8796")
    static let mauve = Color(hex: "c6a0f6")
    static let pink = Color(hex: "f5bde6")
    static let flamingo = Color(hex: "f0c6c6")
    static let rosewater = Color(hex: "f4dbd6")

    // Catppuccin Mocha colors
    static let mochaBase = Color(hex: "1e1e2e")
    static let mochaText = Color(hex: "cdd6f4")
    static let mochaSubtext0 = Color(hex: "a6adc8")
    static let mochaSurface0 = Color(hex: "313244")
    static let mochaMauve = Color(hex: "cba6f7")

    // Update the theme functions to include all variants
    static func backgroundColor(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .dracula: return draculaBase
        case .catppuccinLatte: return latteBase
        case .catppuccinFrappe: return frappeBase
        case .catppuccinMacchiato: return base
        case .catppuccinMocha: return mochaBase
        case .light: return .white
        case .dark: return Color(uiColor: .systemBackground)
        }
    }

    static func textColor(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .dracula: return draculaText
        case .catppuccinLatte: return latteText
        case .catppuccinFrappe: return frappeText
        case .catppuccinMacchiato: return text
        case .catppuccinMocha: return mochaText
        case .light: return Color(hex: "1e2030")
        case .dark: return .white
        }
    }

    static func surfaceColor(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .dracula: return draculaSurface0
        case .catppuccinLatte: return latteSurface0
        case .catppuccinFrappe: return frappeSurface0
        case .catppuccinMacchiato: return surface0
        case .catppuccinMocha: return mochaSurface0
        case .light: return Color(hex: "f0f0f5")
        case .dark: return Color(uiColor: .systemGray5)
        }
    }

    static func accentColor(for theme: AppTheme) -> Color {
        switch theme {
        case .dracula: return draculaMauve
        case .catppuccinLatte: return latteMauve
        case .catppuccinFrappe: return frappeMauve
        case .catppuccinMacchiato: return mauve
        case .catppuccinMocha: return mochaMauve
        case .light: return Color(hex: "2563eb")
        case .dark: return .blue
        }
    }

    static func secondaryTextColor(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .dracula: return draculaSubtext0
        case .catppuccinLatte: return latteSubtext0
        case .catppuccinFrappe: return frappeSubtext0
        case .catppuccinMacchiato: return subtext0
        case .catppuccinMocha: return mochaSubtext0
        case .light: return Color(hex: "64748b")
        case .dark: return Color.white.opacity(0.7)
        }
    }
}

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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension View {
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        self.modifier(NavigationBarTitleColor(color: color))
    }
}

struct NavigationBarTitleColor: ViewModifier {
    let color: Color
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccinMacchiato
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .toolbarColorScheme(isDarkTheme ? .dark : nil, for: .navigationBar)
            .toolbarBackground(Theme.backgroundColor(for: appTheme, colorScheme: colorScheme), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(appTheme == .catppuccinLatte || appTheme == .light ? Theme.textColor(for: appTheme, colorScheme: colorScheme) : color)
    }
    
    private var isDarkTheme: Bool {
        switch appTheme {
        case .catppuccinLatte, .light:
            return false
        case .dracula, .catppuccinFrappe, .catppuccinMacchiato, .catppuccinMocha, .dark:
            return true
        }
    }
} 