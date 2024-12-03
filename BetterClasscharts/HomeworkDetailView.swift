import SwiftUI
import Foundation

struct HomeworkDetailView: View {
    let homework: HomeworkTask
    @State private var isCompleted: Bool
    @State private var isLoading = false
    
    init(homework: HomeworkTask) {
        self.homework = homework
        self._isCompleted = State(initialValue: homework.completed)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(homework.title.processHTML())
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .frame(width: 24, height: 24)
                    } else {
                        Button(action: toggleCompletion) {
                            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(isCompleted ? .green : .gray)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                Text(homework.subject)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Due: \(homework.dueDate.formatted(date: .long, time: .omitted))")
                    .font(.subheadline)
                
                Divider()
                
                Text("Description")
                    .font(.headline)
                
                Text(homework.description.processHTML())
                    .font(.body)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleCompletion() {
        isLoading = true
        StudentClient.toggleHomeworkCompletion(homeworkId: homework.id, completed: isCompleted) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let newState):
                    isCompleted = newState
                case .failure:
                    // You might want to show an error message here
                    break
                }
            }
        }
    }
}
