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
    var count: Int = 0
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func toDictionary() -> [String: Any] {
           return [
               "id": id,
               "count": count,
               "name": name
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

    /* Don't know if this is necessary maybe for sorting by lastUpdated -Eric
     
    var lastUpdatedOptionId: String?
    var lastUpdatedOption: Option?{
        guard let lastUpdatedOptionId else {return nil}
        return options.first{ $0.id == lastUpdatedOptionId}
    }
     */
    

    mutating func incrementOption(index: Int) {
        todoList[index].count += 1
    }
    
    
    
    
    func updateTodo(spaceId: String) {
        // Convert options to an array of dictionaries
        let optionsData = todoList.map { $0.toDictionary() }
        
        let data: [String: Any] = [
            "options": optionsData
        ]
     
            try db.collection("spaces")
                .document(spaceId)
                .collection("todo")
                .document(id.uuidString)
                .updateData(data)
      
    }

    
    func uploadTodo(spaceId: String) {
        do {
            try db.collection("spaces")
                .document(spaceId)
                .collection("todo")
                .document(id.uuidString)
                .setData(from: self)
        } catch {
            print("Error uploading poll")
        }
    }
    
 
    
    
    func totalVotes() -> Int {
           return todoList.reduce(0) { $0 + $1.count }
       }
    
    init(canvasWidget: CanvasWidget, todoList: [TodoItem]) {
        assert(canvasWidget.media == .todo)
        self.id = canvasWidget.id
        self.todoList = todoList
        //Theoretically all polls will have names so we manly exclamation mark
        self.name = canvasWidget.widgetName!
    }
}


func deleteTodoList(spaceId: String, todoId: String) {
    do {
        try db.collection("spaces")
            .document(spaceId)
            .collection("todo")
            .document(todoId)
            .delete()
    } catch {
        print("Error deleting poll")
    }
}
