import SwiftUI

enum Theme {
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
    
    func body(content: Content) -> some View {
        content
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Theme.base, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(color)
    }
} 