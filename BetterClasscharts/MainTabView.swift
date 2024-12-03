import SwiftUI

struct MainTabView: View {
    let studentName: String
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @State private var refreshTimer: Timer?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        TabView {
            HomeworkView()
                .tabItem {
                    Label("Homework", systemImage: "book.fill")
                }
            
            TimetableView()
                .tabItem {
                    Label("Timetable", systemImage: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(Theme.mauve)
        .onAppear {
            startTokenRefresh()
        }
        .onDisappear {
            stopTokenRefresh()
        }
    }
    
    private func startTokenRefresh() {
        // Initial refresh
        refreshToken()
        
        // Set up timer for subsequent refreshes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 35, repeats: true) { _ in
            refreshToken()
        }
    }
    
    private func stopTokenRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func refreshToken() {
        StudentClient.checkAndRefreshSession { result in
            switch result {
            case .success:
                print("Token refreshed successfully")
            case .failure(let error):
                print("Token refresh failed: \(error)")
                // If token refresh fails, we should log out
                StudentClient.clearSavedCredentials()
                dismiss()
            }
        }
    }
    
    private func getPreferredColorScheme() -> ColorScheme? {
        switch themeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

struct HomeworkView: View {
    @State private var homeworkTasks: [HomeworkTask] = []
    @State private var isLoadingHomework = false
    @State private var homeworkError: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.base.ignoresSafeArea()
                
                VStack {
                    if isLoadingHomework {
                        ProgressView()
                            .tint(Theme.mauve)
                    } else if let error = homeworkError {
                        Text(error)
                            .foregroundColor(Theme.red)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(homeworkTasks) { task in
                                    NavigationLink(destination: HomeworkDetailView(homework: task)) {
                                        HomeworkListItemView(task: task) { newState in
                                            if let index = homeworkTasks.firstIndex(where: { $0.id == task.id }) {
                                                homeworkTasks[index].completed = newState
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Homework")
            .navigationBarTitleTextColor(Theme.text)
        }
        .onAppear {
            loadHomework()
        }
    }
    
    private func refreshHomework() async {
        await withCheckedContinuation { continuation in
            loadHomework()
            continuation.resume()
        }
    }
    
    private func loadHomework() {
        isLoadingHomework = true
        homeworkError = nil
        
        StudentClient.fetchHomework { result in
            DispatchQueue.main.async {
                isLoadingHomework = false
                switch result {
                case .success(let tasks):
                    homeworkTasks = tasks
                case .failure(let error):
                    homeworkError = error.localizedDescription
                }
            }
        }
    }
}

struct TimetableView: View {
    @State private var selectedDay: String?
    @State private var lessons: [Lesson] = []
    @State private var isLoadingLessons = false
    @State private var navigateToDay = false
    
    private func isCurrentDay(_ day: String) -> Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        
        // Convert weekday to our day format
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
        NavigationStack {
            ZStack {  // Add ZStack to ensure background covers entire view
                Theme.base.ignoresSafeArea()  // Full screen background
                
                VStack(spacing: 10) {
                    ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], id: \.self) { day in
                        Button(action: {
                            loadTimetable(for: day)
                        }) {
                            Text(day)
                                .font(.title2)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(
                                    Group {
                                        if isCurrentDay(day) {
                                            Theme.surface0
                                        } else {
                                            selectedDay == day ? Theme.mauve : Theme.surface1
                                        }
                                    }
                                )
                                .foregroundColor(Theme.text)
                                .cornerRadius(12)
                                .shadow(color: Theme.crust.opacity(0.2), radius: 5, x: 0, y: 2)
                                .overlay {
                                    if isLoadingLessons && selectedDay == day {
                                        ProgressView()
                                            .tint(Theme.text)
                                    }
                                }
                        }
                        .disabled(isLoadingLessons)
                    }
                }
                .padding()
            }
            .navigationTitle("Timetable")
            .navigationBarTitleTextColor(Theme.text)  // Make navigation title use theme color
            .navigationDestination(isPresented: $navigateToDay) {
                DayTimetableView(day: selectedDay ?? "", lessons: lessons, selectedDay: $selectedDay)
            }
        }
    }
    
    private func loadTimetable(for day: String) {
        isLoadingLessons = true
        
        let calendar = Calendar.current
        let today = Date()
        
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2  // Monday is 2 in Calendar
        guard let monday = calendar.date(from: components) else {
            isLoadingLessons = false
            return
        }
        
        let dayOffset: Int
        switch day {
        case "Monday": dayOffset = 0
        case "Tuesday": dayOffset = 1
        case "Wednesday": dayOffset = 2
        case "Thursday": dayOffset = 3
        case "Friday": dayOffset = 4
        default:
            isLoadingLessons = false
            return
        }
        
        guard let selectedDate = calendar.date(byAdding: .day, value: dayOffset, to: monday) else {
            isLoadingLessons = false
            return
        }
        
        StudentClient.fetchTimetable(for: selectedDate) { result in
            DispatchQueue.main.async {
                isLoadingLessons = false
                switch result {
                case .success(let fetchedLessons):
                    lessons = fetchedLessons
                    selectedDay = day
                    navigateToDay = true
                case .failure:
                    lessons = []
                }
            }
        }
    }
}

#Preview {
    MainTabView(studentName: "Test User")
} 