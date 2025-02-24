import SwiftUI

struct MainTabView: View {
    let studentName: String
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccin
    @AppStorage("catppuccinVariant") private var catppuccinVariant: CatppuccinVariant = .macchiato
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
                break
            case .failure(let error):
                // If token refresh fails, we should log out and print the error
                print("Token refresh failed: \(error)")
                StudentClient.clearSavedCredentials()
                dismiss()
            }
        }
    }
    
    private func getPreferredColorScheme() -> ColorScheme? {
        switch appTheme {
        case .light, .gruvboxLight:
            return .light
        case .catppuccin:
            switch UserDefaults.standard.string(forKey: "catppuccinVariant").flatMap(CatppuccinVariant.init) ?? .macchiato {
            case .latte:
                return .light
            case .frappe, .macchiato, .mocha:
                return .dark
            }
        case .dracula, .gruvboxDark, .tokyoNight, .synthwave, .rosePine, .dark:
            return .dark
        }
    }
}

struct HomeworkView: View {
    @State private var homeworkTasks: [HomeworkTask] = []
    @State private var isLoadingHomework = false
    @State private var homeworkError: String?
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccin
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
                
                if isLoadingHomework && homeworkTasks.isEmpty {
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
                    .refreshable {
                        await refreshHomework()
                    }
                }
            }
        }
        .onAppear {
            // Only load if we haven't loaded any homework yet
            if homeworkTasks.isEmpty {
                loadHomework()
            }
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
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccin
    @Environment(\.colorScheme) var colorScheme
    
    private func getDateForDay(_ day: String) -> Date? {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)
        components.weekday = 2  // Monday is 2 in Calendar
        guard let monday = calendar.date(from: components) else { return nil }
        
        let dayOffset: Int
        switch day {
        case "Monday": dayOffset = 0
        case "Tuesday": dayOffset = 1
        case "Wednesday": dayOffset = 2
        case "Thursday": dayOffset = 3
        case "Friday": dayOffset = 4
        default: return nil
        }
        
        return calendar.date(byAdding: .day, value: dayOffset, to: monday)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private func isCurrentDay(_ day: String) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        
        // First check if we're in the current week
        let todayComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        let selectedComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)
        
        guard todayComponents.yearForWeekOfYear == selectedComponents.yearForWeekOfYear,
              todayComponents.weekOfYear == selectedComponents.weekOfYear else {
            return false
        }
        
        // Then check if it's the current day
        let weekday = calendar.component(.weekday, from: today)
        
        switch weekday {
        case 2: return day == "Monday"
        case 3: return day == "Tuesday"
        case 4: return day == "Wednesday"
        case 5: return day == "Thursday"
        case 6: return day == "Friday"
        default: return false
        }
    }
    
    private func getWeekLabel() -> String {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)
        components.weekday = 2 // Monday
        guard let monday = calendar.date(from: components) else { return "" }
        
        components.weekday = 6 // Friday
        guard let friday = calendar.date(from: components) else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        
        return "\(formatter.string(from: monday)) - \(formatter.string(from: friday))"
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundColor(for: appTheme, colorScheme: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Large Title and Week Selection
                VStack(spacing: 8) {
                    Text("Timetable")
                        .font(.largeTitle.bold())
                        .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Week selector
                    HStack {
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
                                selectedDate = newDate
                                selectedDay = nil  // Clear selected day
                                if let monday = getDateForDay("Monday") {
                                    loadTimetable(for: "Monday", date: monday, shouldSelect: false)
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                        }
                        
                        Button(action: { showingDatePicker = true }) {
                            Text(getWeekLabel())
                                .font(.headline)
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                                .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
                                selectedDate = newDate
                                selectedDay = nil  // Clear selected day
                                if let monday = getDateForDay("Monday") {
                                    loadTimetable(for: "Monday", date: monday, shouldSelect: false)
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                Spacer()
                
                VStack(spacing: 16) {
                    ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], id: \.self) { day in
                        NavigationLink {
                            if isLoadingLessons {
                                ProgressView()
                                    .tint(Theme.accentColor(for: appTheme))
                            } else {
                                DayTimetableView(day: day, lessons: lessons, selectedDay: $selectedDay)
                            }
                        } label: {
                            HStack {
                                Text(day)
                                    .font(.title2)
                                if let date = getDateForDay(day) {
                                    Text(formatDate(date))
                                        .font(.title3)
                                        .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme).opacity(0.7))
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .padding(.horizontal)
                            .background(
                                Group {
                                    if isCurrentDay(day) {
                                        Theme.surfaceColor(for: appTheme, colorScheme: colorScheme)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.purple, lineWidth: 3)
                                            )
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
                            if let date = getDateForDay(day) {
                                loadTimetable(for: day, date: date)
                            }
                        })
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                DatePicker("Select Week", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .tint(Theme.accentColor(for: appTheme))
                    .padding()
                    .onChange(of: selectedDate, initial: false) { oldValue, newValue in
                        selectedDay = nil  // Clear selected day
                        if let monday = getDateForDay("Monday") {
                            loadTimetable(for: "Monday", date: monday, shouldSelect: false)
                        }
                    }
                    .navigationTitle("Select Week")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingDatePicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func loadTimetable(for day: String, date: Date, shouldSelect: Bool = true) {
        isLoadingLessons = true
        
        StudentClient.fetchTimetable(for: date) { result in
            DispatchQueue.main.async {
                isLoadingLessons = false
                switch result {
                case .success(let fetchedLessons):
                    lessons = fetchedLessons
                    if shouldSelect {
                        selectedDay = day
                    }
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