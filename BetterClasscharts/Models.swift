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
    let id: UUID = UUID()
    let apiId: Int
    let title: String
    let subject: String
    let startTime: String
    let endTime: String
    let teacherName: String
    let roomName: String
    
    init(apiId: Int, title: String, subject: String, startTime: String, endTime: String, teacherName: String, roomName: String) {
        self.apiId = apiId
        self.title = title
        self.subject = subject
        self.startTime = startTime
        self.endTime = endTime
        self.teacherName = teacherName
        self.roomName = roomName
    }
} 
