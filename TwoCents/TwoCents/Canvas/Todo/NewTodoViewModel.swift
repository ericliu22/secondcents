//
//  NewPollModel.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class NewTodoModel: ObservableObject {
    
    
    
    let db = Firestore.firestore()
    
    var error: String? = nil
    @Published var listName: String = ""
    var newItemName: String = ""
    var newTodoItem: [TodoItem] = []
    
    var isLoading = false
    
    private var spaceId: String

    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    
    @MainActor
    func createNewTodo() async {
        
        isLoading = true
        
        defer {isLoading = false}
        
        let uid: String
        let user: DBUser
        do {
            uid = try AuthenticationManager.shared.getAuthenticatedUser().uid
            user = try await UserManager.shared.getUser(userId: uid)
        } catch {
            print("Error getting user in ViewModel")
            return
        }

        let newCanvasWidget: CanvasWidget = CanvasWidget(
            borderColor: Color.fromString(name: user.userColor!),
            userId: uid,
            media: .todo,
            widgetName: listName
            
        )
        
        
        print(newTodoItem)
        let todo = Todo(canvasWidget: newCanvasWidget, todoList: newTodoItem)
        todo.uploadPoll(spaceId: spaceId)
        self.listName = ""
        self.newItemName = ""
        self.newTodoItem = []
        
        saveWidget(widget: newCanvasWidget)
        //@TODO: Dismiss after submission
        
    }
    
    func saveWidget(widget: CanvasWidget) {
        //Need to copy to variable before uploading (something about actor-isolate whatever)
        var uploadWidget: CanvasWidget = widget
        //ensure shits are right dimensions
        uploadWidget.width = TILE_SIZE
        uploadWidget.height = TILE_SIZE
        //space call should never fail so we manly exclamation mark
        SpaceManager.shared.uploadWidget(spaceId: spaceId, widget: uploadWidget)
    }
    
    
    
    
    
//    func addOption() {
//        let newOption = Option(name: newOptionName.trimmingCharacters(in: .whitespacesAndNewlines))
//        self.newPollOptions.append(newOption)
//        self.newOptionName = ""
//    }
    
    func addItem(todoArray: [String]) {
        for object in todoArray {
            if object.trimmingCharacters(in: .whitespacesAndNewlines) == "" { continue }
            let newItem = TodoItem(name: object.trimmingCharacters(in: .whitespacesAndNewlines))
            self.newTodoItem.append(newItem)
        }
    }
    
    
}
