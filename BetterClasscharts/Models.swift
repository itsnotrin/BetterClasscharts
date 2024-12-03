import Foundation
import SwiftUI

// Data Models
struct HomeworkTask: Identifiable {
    let id: Int
    let title: String
    let subject: String
    let dueDate: Date
    let description: String
    var completed: Bool
}

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let subject: String
    let startTime: String
    let endTime: String
    let teacherName: String
    let roomName: String
    let periodName: String
}

// Theme Models
enum ThemeMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    case catppuccin = "Catppuccin"
}

enum CatppuccinFlavor: String, CaseIterable {
    case latte = "Latte"
    case frappe = "Frappé"
    case macchiato = "Macchiato"
    case mocha = "Mocha"
}
