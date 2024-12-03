import SwiftUI

struct MainTabView: View {
    let studentName: String
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccinMacchiato
    @State private var refreshTimer: Timer?
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeworkView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Homework", systemImage: "book.fill")
            }
            
            NavigationStack {
                TimetableView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Timetable", systemImage: "calendar")
            }
            
            NavigationStack {
                SettingsView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .tint(Theme.accentColor(for: appTheme))
        .onAppear {
            startTokenRefresh()
            let unselectedColor = appTheme == .light ? 
                UIColor(Theme.textColor(for: appTheme, colorScheme: colorScheme).opacity(0.6)) : 
                UIColor.gray
            
            UITabBar.appearance().unselectedItemTintColor = unselectedColor
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
        switch appTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .catppuccinLatte:
            return .light  // Latte is a light theme
        case .catppuccinFrappe, .catppuccinMacchiato, .catppuccinMocha:
            return .dark  // These are all dark themes
        }
    }
}

struct HomeworkView: View {
    @State private var homeworkTasks: [HomeworkTask] = []
    @State private var isLoadingHomework = false
    @State private var homeworkError: String?
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccinMacchiato
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Theme.backgroundColor(for: appTheme, colorScheme: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Large Title
                Text("Homework")
                    .font(.largeTitle.bold())
                    .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                if isLoadingHomework {
                    ProgressView()
                        .tint(Theme.accentColor(for: appTheme))
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
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccinMacchiato
    @Environment(\.colorScheme) var colorScheme
    
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
        ZStack {
            Theme.backgroundColor(for: appTheme, colorScheme: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Large Title
                Text("Timetable")
                    .font(.largeTitle.bold())
                    .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                Spacer()  // Add spacer to push content down
                
                // Rest of the view
                VStack(spacing: 16) {  // Increased spacing between buttons
                    ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], id: \.self) { day in
                        NavigationLink {
                            if isLoadingLessons {
                                ProgressView()
                                    .tint(Theme.accentColor(for: appTheme))
                            } else {
                                DayTimetableView(day: day, lessons: lessons, selectedDay: $selectedDay)
                            }
                        } label: {
                            Text(day)
                                .font(.title2)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(
                                    Group {
                                        if isCurrentDay(day) {
                                            Theme.surfaceColor(for: appTheme, colorScheme: colorScheme)
                                        } else {
                                            selectedDay == day ? Theme.accentColor(for: appTheme) : Theme.surfaceColor(for: appTheme, colorScheme: colorScheme)
                                        }
                                    }
                                )
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                                .cornerRadius(12)
                                .shadow(color: Theme.crust.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            loadTimetable(for: day)
                        })
                    }
                }
                .padding(.horizontal)
                
                Spacer()  // Add spacer at bottom
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