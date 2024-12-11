import SwiftUI

struct DayTimetableView: View {
    let day: String
    let lessons: [Lesson]
    @Binding var selectedDay: String?
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccin
    @AppStorage("catppuccinVariant") private var catppuccinVariant: CatppuccinVariant = .macchiato
    @Environment(\.colorScheme) var colorScheme
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
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
    
    private func isCurrentLesson(_ lesson: Lesson) -> Bool {
        guard let startTime = formatTimeToDate(from: lesson.startTime),
              let endTime = formatTimeToDate(from: lesson.endTime) else {
            return false
        }
        return currentTime >= startTime && currentTime <= endTime
    }
    
    private func lessonProgress(_ lesson: Lesson) -> Double {
        guard let startTime = formatTimeToDate(from: lesson.startTime),
              let endTime = formatTimeToDate(from: lesson.endTime) else {
            return 0
        }
        
        let totalDuration = endTime.timeIntervalSince(startTime)
        let elapsed = currentTime.timeIntervalSince(startTime)
        return min(max(elapsed / totalDuration, 0), 1)
    }
    
    private func formatTimeToDate(from dateTimeString: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: dateTimeString)
    }
    
    private func isCurrentDay(_ day: String) -> Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        
        switch today {
        case 2: return day == "Monday"
        case 3: return day == "Tuesday"
        case 4: return day == "Wednesday"
        case 5: return day == "Thursday"
        case 6: return day == "Friday"
        default: return false
        }
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
                                
                                // Progress bar for current lesson
                                if isCurrentLesson(lesson) {
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Theme.textColor(for: appTheme, colorScheme: colorScheme).opacity(0.1))
                                                .frame(height: 4)
                                            
                                            Rectangle()
                                                .fill(Theme.accentColor(for: appTheme))
                                                .frame(width: geometry.size.width * lessonProgress(lesson), height: 4)
                                        }
                                    }
                                    .frame(height: 4)
                                    .padding(.top, 8)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Theme.surfaceColor(for: appTheme, colorScheme: colorScheme)
                                    .opacity(isCurrentDay(day) ? 1 : 0.7)
                            )
                            .cornerRadius(8)
                            .shadow(color: Theme.crust.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
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