import SwiftUI

struct MainTabView: View {
    let studentName: String
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeworkView()
                .tabItem {
                    Label("Homework", systemImage: "book")
                }
                .tag(0)
            
            TimetableView()
                .tabItem {
                    Label("Timetable", systemImage: "calendar")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Welcome, \(studentName)")
    }
}

// Add these placeholder views that we'll implement later
struct HomeworkView: View {
    var body: some View {
        Text("Homework View")
    }
}

struct TimetableView: View {
    var body: some View {
        Text("Timetable View")
    }
}