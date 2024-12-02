import SwiftUI

struct DayTimetableView: View {
    let day: String
    let lessons: [Lesson]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(day)'s Timetable")
                    .font(.largeTitle)
                    .padding()
                
                if lessons.isEmpty {
                    Text("No lessons for this day.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(lessons) { lesson in
                        VStack(alignment: .leading) {
                            Text(lesson.title)
                                .font(.headline)
                            Text(lesson.subject)
                                .font(.subheadline)
                            
                            // Format the start and end times
                            let startTime = formatTime(from: lesson.startTime)
                            let endTime = formatTime(from: lesson.endTime)
                            
                            Text("From: \(startTime) To: \(endTime)")
                                .font(.caption)
                            Text("Room: \(lesson.roomName)")
                                .font(.caption)
                            Text("Teacher: \(lesson.teacherName)")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper function to format time
    private func formatTime(from dateTimeString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateTimeString) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a" // Format to show only time
            return timeFormatter.string(from: date)
        }
        return dateTimeString // Return original if parsing fails
    }
} 