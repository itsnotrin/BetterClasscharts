import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case dracula = "Dracula"
    case gruvboxLight = "Gruvbox Light"
    case gruvboxDark = "Gruvbox Dark"
    case tokyoNight = "Tokyo Night"
    case synthwave = "Synthwave '84"
    case rosePine = "Rosé Pine"
    case catppuccin = "Catppuccin"
}

enum CatppuccinVariant: String, CaseIterable {
    case latte = "Latte"
    case frappe = "Frappé"
    case macchiato = "Macchiato"
    case mocha = "Mocha"
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

    // Gruvbox Dark colors
    static let gruvboxDarkBase = Color(hex: "282828")
    static let gruvboxDarkText = Color(hex: "ebdbb2")
    static let gruvboxDarkSubtext0 = Color(hex: "928374")
    static let gruvboxDarkSurface0 = Color(hex: "3c3836")
    static let gruvboxDarkMauve = Color(hex: "d3869b")  // Pink in Gruvbox
    static let gruvboxDarkGreen = Color(hex: "b8bb26")
    static let gruvboxDarkRed = Color(hex: "fb4934")

    // Gruvbox Light colors
    static let gruvboxLightBase = Color(hex: "fbf1c7")
    static let gruvboxLightText = Color(hex: "3c3836")
    static let gruvboxLightSubtext0 = Color(hex: "928374")
    static let gruvboxLightSurface0 = Color(hex: "ebdbb2")
    static let gruvboxLightMauve = Color(hex: "b16286")  // Pink in Gruvbox
    static let gruvboxLightGreen = Color(hex: "98971a")
    static let gruvboxLightRed = Color(hex: "cc241d")

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

    // Tokyo Night colors
    static let tokyoNightBase = Color(hex: "1a1b26")
    static let tokyoNightText = Color(hex: "a9b1d6")
    static let tokyoNightSubtext0 = Color(hex: "565f89")
    static let tokyoNightSurface0 = Color(hex: "24283b")
    static let tokyoNightMauve = Color(hex: "bb9af7")  // Purple in Tokyo Night
    static let tokyoNightGreen = Color(hex: "9ece6a")
    static let tokyoNightRed = Color(hex: "f7768e")

    // Synthwave colors
    static let synthwaveBase = Color(hex: "262335")
    static let synthwaveText = Color(hex: "ff7edb")
    static let synthwaveSubtext0 = Color(hex: "848bbd")
    static let synthwaveSurface0 = Color(hex: "241b2f")
    static let synthwaveMauve = Color(hex: "b381c5")  // Purple in Synthwave
    static let synthwaveGreen = Color(hex: "72f1b8")
    static let synthwaveRed = Color(hex: "fe4450")

    // Rosé Pine colors
    static let rosePineBase = Color(hex: "191724")
    static let rosePineText = Color(hex: "e0def4")
    static let rosePineSubtext0 = Color(hex: "908caa")
    static let rosePineSurface0 = Color(hex: "1f1d2e")
    static let rosePineMauve = Color(hex: "c4a7e7")  // Purple in Rosé Pine
    static let rosePineGreen = Color(hex: "9ccfd8")
    static let rosePineRed = Color(hex: "eb6f92")

    // Update the theme functions to include all variants
    static func backgroundColor(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .tokyoNight: return tokyoNightBase
        case .synthwave: return synthwaveBase
        case .rosePine: return rosePineBase
        case .gruvboxDark: return gruvboxDarkBase
        case .gruvboxLight: return gruvboxLightBase
        case .dracula: return draculaBase
        case .catppuccin:
            switch UserDefaults.standard.string(forKey: "catppuccinVariant").flatMap(CatppuccinVariant.init) ?? .macchiato {
            case .latte: return latteBase
            case .frappe: return frappeBase
            case .macchiato: return base
            case .mocha: return mochaBase
            }
        case .light: return .white
        case .dark: return Color(uiColor: .systemBackground)
        }
    }

    static func textColor(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .tokyoNight: return tokyoNightText
        case .synthwave: return synthwaveText
        case .rosePine: return rosePineText
        case .gruvboxDark: return gruvboxDarkText
        case .gruvboxLight: return gruvboxLightText
        case .dracula: return draculaText
        case .catppuccin:
            switch UserDefaults.standard.string(forKey: "catppuccinVariant").flatMap(CatppuccinVariant.init) ?? .macchiato {
            case .latte: return latteText
            case .frappe: return frappeText
            case .macchiato: return text
            case .mocha: return mochaText
            }
        case .light: return Color(hex: "1e2030")
        case .dark: return .white
        }
    }

    static func surfaceColor(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .tokyoNight: return tokyoNightSurface0
        case .synthwave: return synthwaveSurface0
        case .rosePine: return rosePineSurface0
        case .gruvboxDark: return gruvboxDarkSurface0
        case .gruvboxLight: return gruvboxLightSurface0
        case .dracula: return draculaSurface0
        case .catppuccin:
            switch UserDefaults.standard.string(forKey: "catppuccinVariant").flatMap(CatppuccinVariant.init) ?? .macchiato {
            case .latte: return latteSurface0
            case .frappe: return frappeSurface0
            case .macchiato: return surface0
            case .mocha: return mochaSurface0
            }
        case .light: return Color(hex: "f0f0f5")
        case .dark: return Color(uiColor: .systemGray5)
        }
    }

    static func accentColor(for theme: AppTheme) -> Color {
        switch theme {
        case .tokyoNight: return tokyoNightMauve
        case .synthwave: return synthwaveMauve
        case .rosePine: return rosePineMauve
        case .gruvboxDark: return gruvboxDarkMauve
        case .gruvboxLight: return gruvboxLightMauve
        case .dracula: return draculaMauve
        case .catppuccin:
            switch UserDefaults.standard.string(forKey: "catppuccinVariant").flatMap(CatppuccinVariant.init) ?? .macchiato {
            case .latte: return latteMauve
            case .frappe: return frappeMauve
            case .macchiato: return mauve
            case .mocha: return mochaMauve
            }
        case .light: return Color(hex: "2563eb")
        case .dark: return .blue
        }
    }

    static func secondaryTextColor(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .tokyoNight: return tokyoNightSubtext0
        case .synthwave: return synthwaveSubtext0
        case .rosePine: return rosePineSubtext0
        case .gruvboxDark: return gruvboxDarkSubtext0
        case .gruvboxLight: return gruvboxLightSubtext0
        case .dracula: return draculaSubtext0
        case .catppuccin:
            switch UserDefaults.standard.string(forKey: "catppuccinVariant").flatMap(CatppuccinVariant.init) ?? .macchiato {
            case .latte: return latteSubtext0
            case .frappe: return frappeSubtext0
            case .macchiato: return subtext0
            case .mocha: return mochaSubtext0
            }
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
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccin
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .toolbarColorScheme(isDarkTheme ? .dark : nil, for: .navigationBar)
            .toolbarBackground(Theme.backgroundColor(for: appTheme, colorScheme: colorScheme), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(appTheme == .catppuccin ? Theme.textColor(for: appTheme, colorScheme: colorScheme) : color)
    }
    
    private var isDarkTheme: Bool {
        switch appTheme {
        case .light, .gruvboxLight:
            return false
        case .catppuccin:
            switch UserDefaults.standard.string(forKey: "catppuccinVariant").flatMap(CatppuccinVariant.init) ?? .macchiato {
            case .latte:
                return false
            case .frappe, .macchiato, .mocha:
                return true
            }
        case .dracula, .gruvboxDark, .tokyoNight, .synthwave, .rosePine, .dark:
            return true
        }
    }
} 