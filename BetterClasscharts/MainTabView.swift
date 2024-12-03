import SwiftUI

struct MainTabView: View {
    let studentName: String
    
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
        }
    }
}

struct HomeworkView: View {
    @State private var homeworkTasks: [HomeworkTask] = []
    @State private var isLoadingHomework = false
    @State private var homeworkError: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoadingHomework {
                    ProgressView()
                } else if let error = homeworkError {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    List(homeworkTasks) { task in
                        NavigationLink(destination: HomeworkDetailView(homework: task)) {
                            HomeworkListItemView(task: task) { newState in
                                if let index = homeworkTasks.firstIndex(where: { $0.id == task.id }) {
                                    homeworkTasks[index].completed = newState
                                }
                            }
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Homework")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EmptyView()
                }
            }
            .refreshable {
                await refreshHomework()
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
        NavigationView {
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
                                        Color(.systemBlue).opacity(0.15)
                                    } else {
                                        selectedDay == day ? Color.blue.opacity(0.7) : Color.gray.opacity(0.5)
                                    }
                                }
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            .overlay {
                                if isLoadingLessons && selectedDay == day {
                                    ProgressView()
                                        .tint(.white)
                                }
                            }
                    }
                    .disabled(isLoadingLessons)
                }
            }
            .padding()
            .navigationTitle("Timetable")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EmptyView()
                }
            }
            .background(
                NavigationLink(
                    destination: DayTimetableView(day: selectedDay ?? "", lessons: lessons, selectedDay: $selectedDay),
                    isActive: $navigateToDay
                ) {
                    EmptyView()
                }
            )
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