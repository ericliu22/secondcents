//
//  Poll.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import FirebaseFirestore

struct TodoItem: Codable, Identifiable, Hashable {
    var id = UUID().uuidString
    var mentionedUserId: String
    var task: String
    var completed: Bool
    
    init(task: String, mentionedUserId: String) {
        self.task = task
        self.mentionedUserId = mentionedUserId
        self.completed = false
    }
    
    func toDictionary() -> [String: Any] {
           return [
               "id": id,
               "mentionedUserId": mentionedUserId,
               "task": task,
               "completed": completed
           ]
       }
    
  
    
}

struct Todo: Codable, Identifiable {
//    static func == (lhs: Poll, rhs: Poll) -> Bool {
//        lhs.id == rhs.id
//    }
    
    var id: UUID
    var name: String
    var todoList: [TodoItem] = []
    var userId: String?
    

    func updateTodo(spaceId: String) {
        // Convert options to an array of dictionaries
        let optionsData = todoList.map { $0.toDictionary() }
        
        let data: [String: Any] = [
            "options": optionsData
        ]
     
        Firestore.firestore().collection("spaces")
            .document(spaceId)
            .collection("todo")
            .document(id.uuidString)
            .updateData(data)
      
    }

    
    func uploadTodo(spaceId: String) {
        do {
            try Firestore.firestore().collection("spaces")
                .document(spaceId)
                .collection("todo")
                .document(id.uuidString)
                .setData(from: self)
        } catch {
            print("Error uploading poll")
        }
    }
    

    
    init(canvasWidget: CanvasWidget, todoList: [TodoItem]) {
        assert(canvasWidget.media == .todo)
        self.id = canvasWidget.id
        self.todoList = todoList
        //Theoretically all polls will have names so we manly exclamation mark
        self.name = canvasWidget.widgetName!
        self.userId = canvasWidget.userId
    }
}


func deleteTodoList(spaceId: String, todoId: String) {
    Firestore.firestore().collection("spaces")
        .document(spaceId)
        .collection("todo")
        .document(todoId)
        .delete()
}
