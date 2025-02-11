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
    
    
    
    var error: String? = nil
    @Published var listName: String = ""
    var newItemName: String = ""
    var newTodoItem: [TodoItem] = []
    
    var isLoading = false
    
    
    private var spaceId: String
    
    
    @Published private(set) var space:  DBSpace? = nil
    @Published var allUsers: [DBUser] = []
    @Published var mentionedUsers: [DBUser?] = [nil, nil, nil, nil]
    
    @Published var todoArray: [String] = ["", "", "", ""]
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    
    @MainActor
    func createNewTodo() async -> CanvasWidget? {
        
        isLoading = true
        
        defer {isLoading = false}
        
        let uid: String
        let user: DBUser
        do {
            uid = try AuthenticationManager.shared.getAuthenticatedUser().uid
            user = try await UserManager.shared.getUser(userId: uid)
        } catch {
            print("Error getting user in ViewModel")
            return nil
        }

        let (width, height) = getMultipliedSize(widthMultiplier: 1, heightMultiplier: 2)
        
        let newCanvasWidget: CanvasWidget = CanvasWidget(
            width: width,
            height: height,
            borderColor: Color.fromString(name: user.userColor ?? "gray"),
            userId: uid,
            media: .todo,
            widgetName: listName
            
        )
        
        
        print(newTodoItem)
        let todo = Todo(canvasWidget: newCanvasWidget, todoList: newTodoItem)
        todo.uploadTodo(spaceId: spaceId)
        self.listName = ""
        self.newItemName = ""
        self.newTodoItem = []
        
        //@TODO: Dismiss after submission
        return newCanvasWidget
    }
    
    
    func getUserName(userId: String) async throws -> String {
     
        return try await UserManager.shared.getUser(userId: userId).name ?? ""
    }
    
    func addItem(todoArray: [String], userArray: [DBUser?]) {
        for (index, object) in todoArray.enumerated() {
            if object.trimmingCharacters(in: .whitespacesAndNewlines) == "" { continue }
            let newItem = TodoItem(task: object.trimmingCharacters(in: .whitespacesAndNewlines), mentionedUserId: userArray[index]?.userId ?? "")
            self.newTodoItem.append(newItem)
        }
    }
    
    func autoAssignTasks(spaceId: String) {
        print("autoAssignTasks called")
        
        // Filter out users who are already assigned to tasks
        let usersWithoutMention = allUsers.filter { user in
            !newTodoItem.contains { $0.mentionedUserId == user.userId }
        }
        
        print("Users without mention: \(usersWithoutMention)")
        
        // Ensure there are users available for assignment
        guard !usersWithoutMention.isEmpty else {
            print("No users to assign tasks to")
            return
        }
        
        // Create a frequency dictionary to track the number of tasks per user, including existing mentions
        var userTaskFrequency: [String: Int] = [:]
        
        // Initialize frequency from existing mentions
        for item in mentionedUsers {
            if item != nil {
                userTaskFrequency[item!.userId, default: 0] += 1
            }
        }
        
        // Initialize the frequency dictionary for users who have no mentions
        for user in usersWithoutMention {
            userTaskFrequency[user.userId] = userTaskFrequency[user.userId] ?? 0
        }

        print("Initial user task frequency: \(userTaskFrequency)")

        // Function to get the user with the least tasks assigned
        func getLeastFrequentUser() -> DBUser? {
            let sortedUsers = usersWithoutMention.sorted {
                (userTaskFrequency[$0.userId] ?? 0) < (userTaskFrequency[$1.userId] ?? 0)
            }
            return sortedUsers.first
        }
        
        // Assign tasks
        print("Assigning tasks...")
        for (index, item) in mentionedUsers.enumerated() {
            
            
            if item == nil && todoArray[index] != ""  {
                if let user = getLeastFrequentUser() {
                    mentionedUsers[index] = user
                    userTaskFrequency[user.userId, default: 0] += 1
                   
                }
            }
        }
        
       
    }

     
     func getAllUsers(spaceId: String) async throws {
         try await loadCurrentSpace(spaceId: spaceId)
         guard let members = space?.members else { return }
         
         self.allUsers = try await UserManager.shared.getMembersInfo(members: members)
     }

    
 
   
    
    func loadCurrentSpace(spaceId: String) async throws {
        
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
}
