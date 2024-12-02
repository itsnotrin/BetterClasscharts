import SwiftUI

struct HomeScreen: View {
    let studentName: String
    @State private var homeworkTasks: [HomeworkTask] = []
    @State private var isLoadingHomework = false
    @State private var homeworkError: String?
    @State private var isHomeworkExpanded = false
    @State private var hasLoadedInitialData = false
    
    @State private var selectedDay: String?
    @State private var lessons: [Lesson] = []
    @State private var isLoadingLessons = false
    @State private var isTimetableExpanded = false
    @State private var navigateToDayTimetable = false  // New state variable for navigation
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                welcomeHeader
                homeworkSection
                timetableSection
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .refreshable {
                await refreshHomework()
            }
            .background(
                NavigationLink(destination: DayTimetableView(day: selectedDay ?? "", lessons: lessons, selectedDay: $selectedDay), isActive: $navigateToDayTimetable) {
                    EmptyView()
                }
            )
        }
        .onAppear {
            if !hasLoadedInitialData {
                loadHomework()
                hasLoadedInitialData = true
            }
        }
    }
    
    private var welcomeHeader: some View {
        Text("Welcome \(studentName.processHTML())")
            .font(.title)
            .padding(.horizontal)
            .padding(.top)
    }
    
    private var homeworkSection: some View {
        DisclosureGroup(
            isExpanded: $isHomeworkExpanded,
            content: { homeworkContent },
            label: { homeworkLabel }
        )
        .padding(.horizontal)
    }
    
    private var homeworkContent: some View {
        Group {
            if isLoadingHomework {
                ProgressView()
                    .padding()
            } else if let error = homeworkError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if homeworkTasks.isEmpty {
                Text("No homework tasks")
                    .padding()
            } else {
                homeworkList
            }
        }
    }
    
    private var homeworkList: some View {
        ScrollView {
            ForEach(homeworkTasks) { task in
                NavigationLink(destination: HomeworkDetailView(homework: task)) {
                    HomeworkListItemView(task: task) { newState in
                        if let index = homeworkTasks.firstIndex(where: { $0.id == task.id }) {
                            homeworkTasks[index].completed = newState // Update the completed state directly
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var homeworkLabel: some View {
        HStack {
            Text("Homework")
                .font(.headline)
            if isLoadingHomework {
                Spacer()
                ProgressView()
            }
        }
        .padding(.horizontal)
    }
    
    private var timetableSection: some View {
        DisclosureGroup(
            isExpanded: $isTimetableExpanded,
            content: {
                VStack {
                    VStack(spacing: 10) {
                        ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], id: \.self) { day in
                            Button(action: {
                                loadTimetable(for: day)  // Load the timetable for the selected day
                            }) {
                                Text(day)
                                    .font(.title2)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(selectedDay == day ? Color.blue.opacity(0.7) : Color.gray.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                    .padding(5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if isLoadingLessons {
                        ProgressView()
                    }
                }
            },
            label: {
                Text("Timetable")
                    .font(.headline)
                    .padding(.horizontal)
            }
        )
        .padding()
    }
    
    private func loadTimetable(for day: String) {
        isLoadingLessons = true
        
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate the date for the selected day
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        
        switch day {
        case "Monday":
            components.weekday = 2 // Monday
        case "Tuesday":
            components.weekday = 3 // Tuesday
        case "Wednesday":
            components.weekday = 4 // Wednesday
        case "Thursday":
            components.weekday = 5 // Thursday
        case "Friday":
            components.weekday = 6 // Friday
        default:
            break
        }
        
        if let selectedDate = calendar.date(from: components) {
            print("Loading timetable for date: \(selectedDate)")  // Log the selected date
            StudentClient.fetchTimetable(for: selectedDate) { result in
                DispatchQueue.main.async {
                    isLoadingLessons = false
                    switch result {
                    case .success(let fetchedLessons):
                        lessons = fetchedLessons
                        selectedDay = dateFormatter.string(from: selectedDate) // Set the selected day as a formatted string
                        print("Fetched \(fetchedLessons.count) lessons for \(selectedDay ?? "")")  // Log the number of lessons fetched
                        navigateToDayTimetable = true  // Trigger navigation
                    case .failure(let error):
                        print("Error fetching timetable: \(error)")
                    }
                }
            }
        } else {
            isLoadingLessons = false
            print("Could not calculate date for \(day)")
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
        
        print("Starting homework fetch")
        StudentClient.fetchHomework { result in
            print("Received homework result")
            DispatchQueue.main.async {
                isLoadingHomework = false
                switch result {
                case .success(let tasks):
                    print("Got \(tasks.count) homework tasks")
                    homeworkTasks = tasks
                case .failure(let error):
                    print("Homework fetch error:", error)
                    homeworkError = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    HomeScreen(studentName: "Test User")
}
