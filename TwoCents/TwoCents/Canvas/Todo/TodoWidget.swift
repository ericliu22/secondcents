import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TodoWidget: View {
    
    let widget: CanvasWidget // Assuming CanvasWidget is a defined type
    private var spaceId: String
    
    @State var todo: Todo?

    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .todo)
        self.widget = widget
        self.spaceId = spaceId
    }
    
    func fetchTodo() {
        let db = Firestore.firestore()
        db.collection("spaces")
            .document(spaceId)
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
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 3)
                    
                    
                    
                    if todo.todoList.filter { !$0.completed }.count == 0 {
                        
                       
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
                    
                    ForEach(todo.todoList.filter { !$0.completed }.prefix(todo.todoList.filter { !$0.completed }.count == 5 ? 5 : 4), id: \.self) { item in
                        TaskItemView(item: item)
                            .padding(.horizontal, 16)
                    }

                    let filteredList = todo.todoList.filter { !$0.completed }

                    if filteredList.count > 5 {
                        let additionalTaskCount = filteredList.count - 4

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
                .frame(width: TILE_SIZE, height: TILE_SIZE)
//                .background(.ultraThickMaterial)
             
                .background(Color(UIColor.systemBackground))
              
                .cornerRadius(CORNER_RADIUS)
                .overlay(
                    
                  
                    Text("\(todo.todoList.filter { !$0.completed }.count)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.top, 12)
                            .padding(.trailing, 16)
                            .frame(width: TILE_SIZE, height: TILE_SIZE, alignment: .topTrailing)
                    
                )
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .aspectRatio(1, contentMode: .fit)
                  
                    .cornerRadius(CORNER_RADIUS)
                    .frame(maxWidth: TILE_SIZE, maxHeight: TILE_SIZE)
                    .onAppear {
                        fetchTodo()
                    }
                    .background(.thinMaterial)
            }
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
