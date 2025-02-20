//
//  TodoWidgetViewModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/2/19.
//
import Foundation
import FirebaseFirestore

@Observable @MainActor
class TodoWidgetViewModel {
    
    let widget: CanvasWidget
    let spaceId: String
    var todo: Todo?
    @ObservationIgnored private var todoListener: ListenerRegistration?
    
    init(widget: CanvasWidget, spaceId: String) {
        self.widget = widget
        self.spaceId = spaceId
    }
    
    deinit {
        todoListener?.remove()
    }
    
    func fetchTodo() {
        todoListener = spaceReference(spaceId: spaceId)
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
}
