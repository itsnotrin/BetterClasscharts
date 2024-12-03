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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title.processHTML())
                        .font(.headline)
                        .foregroundColor(Theme.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(task.subject)
                        .font(.subheadline)
                        .foregroundColor(Theme.subtext0)
                    
                    Text("Due: \(task.dueDate.formatted(.dateTime.day().month()))")
                        .font(.caption)
                        .foregroundColor(Theme.subtext1)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Theme.surface1)
                        .cornerRadius(6)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .frame(width: 24, height: 24)
                        .tint(Theme.mauve)
                } else {
                    Button(action: toggleCompletion) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isCompleted ? Theme.green : Theme.surface2)
                            .background(
                                Circle()
                                    .fill(isCompleted ? Theme.green.opacity(0.2) : Theme.surface0)
                                    .frame(width: 32, height: 32)
                            )
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Theme.surface0)
        .cornerRadius(12)
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