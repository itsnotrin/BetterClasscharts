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
}

// Helper for parsing JSON
enum JSONParser {
    static func parseResponse(_ data: Data) throws -> [[String: Any]] {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if let dict = json as? [String: Any],
           let data = dict["data"] as? [[String: Any]] {
            return data
        }
        throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid JSON structure"))
    }
} 
