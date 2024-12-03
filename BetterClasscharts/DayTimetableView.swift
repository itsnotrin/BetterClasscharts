import SwiftUI

struct DayTimetableView: View {
    let day: String
    let lessons: [Lesson]
    @Binding var selectedDay: String?
    
    // Define the period time ranges
    private let periodTimes: [(start: String, end: String, number: Int)] = [
        ("08:45", "09:10", 0),
        ("09:10", "10:10", 1),
        ("10:10", "11:10", 2),
        ("11:25", "12:25", 3),
        ("13:15", "14:15", 4),
        ("14:15", "15:15", 5)
    ]
    
    // Create a struct to hold a lesson with a unique identifier
    private struct UniqueLesson: Identifiable {
        let id: String // Combine lesson id and start time for uniqueness
        let lesson: Lesson
        
        init(_ lesson: Lesson) {
            self.id = "\(lesson.id)_\(lesson.startTime)"
            self.lesson = lesson
        }
    }
    
    // Convert lessons array to unique lessons
    private var uniqueLessons: [UniqueLesson] {
        lessons.map { UniqueLesson($0) }
    }
    
    // Helper function to get period number based on start time
    private func getPeriodNumber(for startTimeString: String) -> Int {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        guard let lessonTime = formatTimeToHHmm(from: startTimeString) else { return 1 }
        
        for period in periodTimes {
            if lessonTime >= period.start && lessonTime < period.end {
                return period.number
            }
        }
        
        return 1 // Default to period 1 if no match found
    }
    
    // Helper function to format ISO8601 time to HH:mm
    private func formatTimeToHHmm(from dateTimeString: String) -> String? {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: dateTimeString) else { return nil }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
    }
    
    // Helper function to format time for display
    private func formatTime(from dateTimeString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateTimeString) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a" // Format to show only time
            return timeFormatter.string(from: date)
        }
        return dateTimeString // Return original if parsing fails
    }
    
    // Helper function to get period display text
    private func getPeriodDisplay(for startTimeString: String) -> String {
        let periodNumber = getPeriodNumber(for: startTimeString)
        return periodNumber == 0 ? "Tutor" : "Period \(periodNumber)"
    }
    
    var body: some View {
        ZStack {  // Add ZStack for proper background layering
            Theme.base.ignoresSafeArea()  // Full screen background
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(day)'s Timetable")
                        .font(.largeTitle)
                        .foregroundColor(Theme.text)
                        .padding()
                    
                    if lessons.isEmpty {
                        Text("No lessons for this day.")
                            .font(.subheadline)
                            .foregroundColor(Theme.subtext0)
                            .padding()
                    } else {
                        ForEach(lessons) { lesson in
                            VStack(spacing: 12) {
                                // Header row
                                HStack {
                                    Text(lesson.periodName)
                                        .font(.headline)
                                        .foregroundColor(Theme.text)
                                    Spacer()
                                    Text(lesson.subject)
                                        .font(.headline)
                                        .foregroundColor(Theme.text)
                                }
                                
                                // Time row
                                HStack {
                                    Label(formatTime(from: lesson.startTime), systemImage: "clock")
                                    Text("→")
                                    Label(formatTime(from: lesson.endTime), systemImage: "clock")
                                }
                                .font(.subheadline)
                                .foregroundColor(Theme.subtext0)
                                
                                // Location and teacher row
                                HStack {
                                    Label(lesson.roomName, systemImage: "building.2")
                                    Spacer()
                                    Label(lesson.teacherName, systemImage: "person")
                                }
                                .font(.subheadline)
                                .foregroundColor(Theme.subtext0)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Theme.surface0)
                            .cornerRadius(8)
                            .shadow(color: Theme.crust.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            selectedDay = nil
        }
    }
} 