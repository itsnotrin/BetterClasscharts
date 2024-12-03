import SwiftUI

struct HomeworkDetailView: View {
    let homework: HomeworkTask
    @State private var isCompleted: Bool
    @State private var isLoading = false
    
    init(homework: HomeworkTask) {
        self.homework = homework
        self._isCompleted = State(initialValue: homework.completed)
    }
    
    var body: some View {
        ZStack {
            Theme.base.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title and completion status
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            Text(homework.title.processHTML())
                                .font(.title2.bold())
                                .foregroundColor(Theme.text)
                            
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
                        
                        // Subject and due date
                        HStack(spacing: 12) {
                            Text(homework.subject)
                                .font(.headline)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                                .background(Theme.surface1)
                                .cornerRadius(8)
                            
                            Text("Due: \(homework.dueDate.formatted(date: .long, time: .omitted))")
                                .font(.subheadline)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                                .background(Theme.surface0)
                                .cornerRadius(8)
                        }
                        .foregroundColor(Theme.subtext0)
                    }
                    .padding()
                    .background(Theme.surface0.opacity(0.5))
                    .cornerRadius(16)
                    
                    // Description section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                        
                        Text(homework.description.processHTML())
                            .font(.body)
                            .foregroundColor(Theme.subtext0)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surface0.opacity(0.5))
                    .cornerRadius(16)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitleTextColor(Theme.text)
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
