import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

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
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
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