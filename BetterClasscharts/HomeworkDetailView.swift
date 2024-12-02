import SwiftUI

struct HomeworkDetailView: View {
    let homework: HomeworkTask
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(homework.title.processHTML())
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    if homework.completed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
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
}
