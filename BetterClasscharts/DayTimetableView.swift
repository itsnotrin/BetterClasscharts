import SwiftUI

struct DayTimetableView: View {
    let day: String
    let lessons: [Lesson]
    @Binding var selectedDay: String?
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccin
    @Environment(\.colorScheme) var colorScheme
    
    // Define the period time ranges
    private let periodTimes: [(start: String, end: String, number: Int)] = [
        ("08:45", "09:10", 0),
        ("09:10", "10:10", 1),
        ("10:10", "11:10", 2),
        ("11:25", "12:25", 3),
        ("13:15", "14:15", 4),
        ("14:15", "15:15", 5)
    ]
    
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
            timeFormatter.dateFormat = "h:mm a"
            return timeFormatter.string(from: date)
        }
        return dateTimeString
    }
    
    private func getPeriodName(for startTimeString: String) -> String {
        guard let lessonTime = formatTimeToHHmm(from: startTimeString) else { return "Unknown Period" }
        
        for period in periodTimes {
            if lessonTime >= period.start && lessonTime < period.end {
                return period.number == 0 ? "Tutor" : "Period \(period.number)"
            }
        }
        
        return "Unknown Period"
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundColor(for: appTheme, colorScheme: colorScheme).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(day)'s Timetable")
                        .font(.largeTitle)
                        .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                        .padding()
                    
                    if lessons.isEmpty {
                        Text("No lessons for this day.")
                            .font(.subheadline)
                            .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme).opacity(0.7))
                            .padding()
                    } else {
                        ForEach(lessons.sorted { 
                            formatTimeToHHmm(from: $0.startTime) ?? "" < formatTimeToHHmm(from: $1.startTime) ?? "" 
                        }) { lesson in
                            VStack(spacing: 12) {
                                // Header row
                                HStack {
                                    Text(getPeriodName(for: lesson.startTime))
                                        .font(.headline)
                                        .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                                    Spacer()
                                    Text(lesson.subject)
                                        .font(.headline)
                                        .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                                }
                                
                                // Time row
                                HStack {
                                    Label(formatTime(from: lesson.startTime), systemImage: "clock")
                                    Text("→")
                                    Label(formatTime(from: lesson.endTime), systemImage: "clock")
                                }
                                .font(.subheadline)
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme).opacity(0.7))
                                
                                // Location and teacher row
                                HStack {
                                    Label(lesson.roomName, systemImage: "building.2")
                                    Spacer()
                                    Label(lesson.teacherName, systemImage: "person")
                                }
                                .font(.subheadline)
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme).opacity(0.7))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
                            .cornerRadius(8)
                            .shadow(color: Theme.crust.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .navigationBarHidden(false)
        .navigationBarTitleTextColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
        .onDisappear {
            selectedDay = nil
        }
    }
} 