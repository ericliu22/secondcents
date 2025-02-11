import Foundation
import SwiftUI
import FirebaseFirestore

struct TodoWidget: View {
    
    let widget: CanvasWidget // Assuming CanvasWidget is a defined type
    private var spaceId: String
    let cutoff: Int
    
    @State var todo: Todo?

    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .todo)
        self.widget = widget
        self.spaceId = spaceId
        self.cutoff = Int((widget.height-50) / 20)
    }
    
    
    @Environment(CanvasPageViewModel.self) var canvasViewModel: CanvasPageViewModel?
    
    
    func fetchTodo() {
        spaceReference(spaceId: spaceId)
            .collection("todo")
            .document(widget.id.uuidString)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error getting document: \(error)")
                    return
                }
                
                do {
                    if let todoData = try snapshot?.data(as: Todo.self) {
                        self.todo = todoData
                    } else {
                        print("Document data is empty.")
                    }
                } catch {
                    print("Error decoding document: \(error)")
                }
            }
    }

    var body: some View {
        ZStack {
            if let todo = todo {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(todo.name)
                            .font(.subheadline)
                            .foregroundColor(Color.accentColor)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 3)
                    .padding(.trailing, 16)
                    
                    
                    
                    if todo.todoList.filter({ !$0.completed }).count == 0 {
                        
                       
                        Spacer()
                            .frame(height: 32)
                        
                        Text("All tasks are done!")
                            .font(.caption)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Too easyyy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                           
                    }
                    
                    ForEach(todo.todoList.filter { !$0.completed }.prefix(todo.todoList.filter { !$0.completed }.count == cutoff ? cutoff : cutoff-1), id: \.self) { item in
                        TaskItemView(item: item)
                            .padding(.horizontal, 16)
                    }

                    let filteredList = todo.todoList.filter { !$0.completed }

                    if filteredList.count > cutoff {
                        let additionalTaskCount = filteredList.count - (cutoff-1)

                        HStack(spacing: 3) {
                            Color.secondary
                                .frame(width: 3, height: 12)
                                .cornerRadius(3)

                            Text("+\(additionalTaskCount) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .truncationMode(.tail)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 16)
                    }

                    
                    Spacer()
                }
                .frame(width: widget.width, height: widget.height)
//                .background(.ultraThickMaterial)
             
                .background(Color(UIColor.systemBackground))
              
                .cornerRadius(CORNER_RADIUS)
                .overlay(
                    
                  
                    Text("\(todo.todoList.filter { !$0.completed }.count)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.top, 12)
                            .padding(.trailing, 16)
                            .frame(width: widget.width, height: widget.height, alignment: .topTrailing)
                    
                )
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .aspectRatio(1, contentMode: .fit)
                  
                    .cornerRadius(CORNER_RADIUS)
                    .frame(maxWidth: widget.width, maxHeight: widget.height)
                    .onAppear {
                        fetchTodo()
                    }
                    .background(.thinMaterial)
            }
        }
        .onTapGesture {
            guard let canvasViewModel = canvasViewModel else { return }
            canvasViewModel.activeSheet = .todo
            canvasViewModel.activeWidget = widget
        }
    
        
        
    }
    
    
    
    
    
}


struct TaskItemView: View {
    let item: TodoItem
    @State private var user: DBUser?
    @State private var userColor: Color?

    var body: some View {
        HStack(spacing: 3) {
            Color(userColor ?? .gray)
                .frame(width: 3, height: 12)
                .cornerRadius(3)
            
            Text(item.task)
                .font(.caption)
                .foregroundColor(Color(UIColor.label))
                .truncationMode(.tail)
                .lineLimit(1)
        }
        .task {
            if item.mentionedUserId != "" {
                do {
                    user = try await UserManager.shared.getUser(userId: item.mentionedUserId)
                    withAnimation {
                        userColor = Color.fromString(name: user?.userColor ?? "")
                    }
                } catch {
                    print("Failed to fetch user: \(error.localizedDescription)")
                }
            }
        }
        .padding(.bottom, 3)
    }
}




struct TodoWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodoWidget(widget: CanvasWidget(width: .infinity, height: .infinity, borderColor: .red, userId: "jisookim", media: .todo, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"), spaceId: "099E9885-EE75-401D-9045-0F6DA64D29B1")
    }
}
