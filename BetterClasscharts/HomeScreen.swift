import SwiftUI

struct HomeScreen: View {
    let studentName: String
    
    var body: some View {
        MainTabView(studentName: studentName)
    }
}

#Preview {
    HomeScreen(studentName: "Test User")
}
