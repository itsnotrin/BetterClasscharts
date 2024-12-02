import Foundation

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