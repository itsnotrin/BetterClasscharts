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
            Button(action: {
                isLoading = true
                isCompleted.toggle()
                onCompletionToggled(isCompleted)
                StudentClient.toggleHomeworkCompletion(homeworkId: task.id, completed: isCompleted) { result in
                    isLoading = false
                    switch result {
                    case .success(let newState):
                        print("Homework marked as \(newState ? "done" : "not done")")
                    case .failure(let error):
                        print("Error marking homework: \(error)")
                    }
                }
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .gray)
                    .font(.title)
            }
            .disabled(isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
} 