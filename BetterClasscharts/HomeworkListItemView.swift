import SwiftUI

struct HomeworkListItemView: View {
    let task: HomeworkTask
    @State private var isCompleted: Bool
    @State private var isLoading = false
    var onCompletionToggled: (Bool) -> Void
    
    init(task: HomeworkTask, onCompletionToggled: @escaping (Bool) -> Void) {
        self.task = task
        self._isCompleted = State(initialValue: task.completed)
        self.onCompletionToggled = onCompletionToggled
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title.processHTML())
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(task.subject)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Due: \(task.dueDate.formatted(.dateTime.day().month()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isLoading {
                ProgressView()
            } else {
                Button(action: toggleCompletion) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : .gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private func toggleCompletion() {
        isLoading = true
        StudentClient.toggleHomeworkCompletion(homeworkId: task.id, completed: isCompleted) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let newState):
                    isCompleted = newState
                    onCompletionToggled(newState)
                case .failure:
                    // You might want to show an error message here
                    break
                }
            }
        }
    }
} 