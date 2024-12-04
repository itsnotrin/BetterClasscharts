import SwiftUI

struct HomeworkListItemView: View {
    let task: HomeworkTask
    @State private var isCompleted: Bool
    @State private var isLoading = false
    var onCompletionToggled: (Bool) -> Void
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccin
    @AppStorage("catppuccinVariant") private var catppuccinVariant: CatppuccinVariant = .macchiato
    @Environment(\.colorScheme) var colorScheme
    
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
                        .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Text(task.subject)
                            .font(.subheadline)
                            .foregroundColor(Theme.secondaryTextColor(for: appTheme, colorScheme: colorScheme))
                        
                        Text("Due: \(task.dueDate.formatted(.dateTime.day().month()))")
                            .font(.caption)
                            .foregroundColor(Theme.secondaryTextColor(for: appTheme, colorScheme: colorScheme))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
                            .cornerRadius(6)
                    }
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .frame(width: 24, height: 24)
                        .tint(Theme.accentColor(for: appTheme))
                } else {
                    Button(action: toggleCompletion) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isCompleted ? Theme.green : Theme.textColor(for: appTheme, colorScheme: colorScheme).opacity(0.7))
                            .background(
                                Circle()
                                    .fill(isCompleted ? Theme.green.opacity(0.2) : Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
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
        .background(Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
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