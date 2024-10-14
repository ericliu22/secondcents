//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI
@MainActor
final class TodoWidgetSheetViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
//    func loadCurrentUser() async throws {
//        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
//    }
    
    func loadUser(userId: String) async throws {
        self.user = try await UserManager.shared.getUser(userId: userId)
    }
    
    @Published private(set) var todo: Todo?
    @Published var mentionedUsers: [DBUser?] = []
    @Published var modifiedMentionedUsers: [Int: String] = [:]  // Store changes locally
    @Published var localTodoList: [TodoItem] = []
    
    
    @Published var newTodoItem: TodoItem = TodoItem(task: "", mentionedUserId: "")
    
    
    
    
    
    
    @Published var allUsers: [DBUser] = []
    @Published private(set) var space:  DBSpace? = nil
    
    
    
    @Published var isFilterActive: Bool = false
    @Published private(set) var userId: String? = try? AuthenticationManager.shared.getAuthenticatedUser().uid

    
    
    // Define the new addNewTodoItem function
    func addNewTodoItem(spaceId: String, todoId: String, mentionedUserId: String) {
        guard !newTodoItem.task.isEmpty else {
            print("Task is empty. Cannot add a new todo item.")
            return
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("spaces").document(spaceId).collection("todo").document(todoId)
        
        ref.getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Document does not exist.")
                return
            }
            
            // Retrieve the existing todoList
            var todoList = (document.data()?["todoList"] as? [[String: Any]]) ?? []
            
            // Add the new todo item to the list
            let newTodoItemData: [String: Any] = [
                "task": self.newTodoItem.task,
                "mentionedUserId": mentionedUserId,
                "completed": false,
                "id": UUID().uuidString
            ]
            todoList.append(newTodoItemData)
            
            //clear newTodoItem
            let backUpTodoItem: TodoItem = self.newTodoItem
            self.newTodoItem = TodoItem(task: "", mentionedUserId: "")
            
            
            // Update the Firestore document
            ref.updateData(["todoList": todoList]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                    self.newTodoItem = backUpTodoItem
                } else {
                    print("New todo item successfully added.")
                    // Optionally clear the newTodoItem after adding it to the list
//                    self.newTodoItem = TodoItem(task: "", mentionedUserId: "")
                }
            }
        }
    }
    
    
    func fetchTodo(spaceId: String, widget: CanvasWidget) {
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
                        self.localTodoList = todoData.todoList
                        
                        // Expand the mentionedUsers array only if the new todoList is longer
                        if todoData.todoList.count > self.mentionedUsers.count {
                            let additionalCount = todoData.todoList.count - self.mentionedUsers.count
                            self.mentionedUsers.append(contentsOf: Array(repeating: nil, count: additionalCount))
                        }
                        
                        for (index, todoItem) in todoData.todoList.enumerated() {
                            // Only fetch the user if it's not already fetched
                            if !todoItem.mentionedUserId.isEmpty, self.mentionedUsers[index] == nil {
                                Task {
                                    do {
                                        let user = try await UserManager.shared.getUser(userId: todoItem.mentionedUserId)
                                        DispatchQueue.main.async {
                                            if self.mentionedUsers.indices.contains(index) {
                                                self.mentionedUsers[index] = user
                                            }
                                        }
                                    } catch {
                                        print("Error fetching user: \(error)")
                                    }
                                }
                            }
                        }
                        
                    } else {
                        print("Document data is empty.")
                    }
                } catch {
                    print("Error decoding document: \(error)")
                }
            }
    }

    
    func toggleCompletionStatus(index: Int) {
        localTodoList[index].completed.toggle()
    }
    
    func saveChanges(spaceId: String, todoId: String) {
        let db = Firestore.firestore()
        let ref = db.collection("spaces").document(spaceId).collection("todo").document(todoId)
        
        ref.getDocument { [weak self] document, error in
            guard let self = self else {
                return
            }
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data(), var todoList = data["todoList"] as? [[String: Any]] else {
                print("Document does not exist or is not valid")
                return
            }
            
            for (index, mentionedUserId) in self.modifiedMentionedUsers {
                if index < todoList.count {
                    todoList[index]["mentionedUserId"] = mentionedUserId
                }
            }
            
         
            
            for (index, todoItem) in self.localTodoList.enumerated() {
                if index < todoList.count {
                    todoList[index]["completed"] = todoItem.completed
                    todoList[index]["task"] = todoItem.task
                }
            }
            
            ref.updateData(["todoList": todoList]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated.")
                    self.modifiedMentionedUsers.removeAll()  // Clear the local changes
                }
            }
        }
    }
    
    
    
    func getAllUsers(spaceId: String) async throws {
        try await loadCurrentSpace(spaceId: spaceId)
        guard let space = space else { return }
        self.allUsers = try await UserManager.shared.getMembersInfo(members: (space.members)!)
    }
    
    
    
    
    
    func loadCurrentSpace(spaceId: String) async throws {
        
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
    
    
    func autoAssignTasks(spaceId: String) {
        print("autoAssignTasks called")
        
        // Ensure there are users available for assignment
        guard !allUsers.isEmpty else {
            print("No users available in the space")
            return
        }

        // Create a frequency dictionary to track the number of tasks per user, including existing mentions
        var userTaskFrequency: [String: Int] = [:]
        
        // Initialize frequency from existing mentions
        for item in mentionedUsers {
            if let user = item {
                userTaskFrequency[user.userId, default: 0] += 1
            }
        }
        
        // Initialize the frequency dictionary for all users
        for user in allUsers {
            userTaskFrequency[user.userId, default: 0] += 0
        }
        
        print("Initial user task frequency: \(userTaskFrequency)")
        
        // Function to get the user with the least tasks assigned
        func getLeastFrequentUser() -> DBUser? {
            return allUsers.min {
                (userTaskFrequency[$0.userId] ?? 0) < (userTaskFrequency[$1.userId] ?? 0)
            }
        }
        
        // Assign tasks
        print("Assigning tasks...")
        for (index, item) in mentionedUsers.enumerated() {
            if item == nil {
                if let user = getLeastFrequentUser() {
                    mentionedUsers[index] = user
                    modifiedMentionedUsers[index] = user.userId
                    userTaskFrequency[user.userId, default: 0] += 1
                }
            }
        }
        
        print("Updated user task frequency: \(userTaskFrequency)")
    }

    func deleteItem(index: Int, todoItemId: String, spaceId: String, todoId: String) {
        // Remove the item from the local list
        localTodoList.remove(at: index)
        
        // Remove the corresponding mentioned user
        mentionedUsers.remove(at: index)
        
        let db = Firestore.firestore()
        let ref = db.collection("spaces").document(spaceId).collection("todo").document(todoId)
        
        ref.getDocument { document, error in
            
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }
            
            guard let document = document, document.exists, var todoList = document.data()?["todoList"] as? [[String: Any]] else {
                print("Document does not exist or is not valid")
                return
            }
            
            // Find the index of the item to delete in the Firestore list
            if let firestoreIndex = todoList.firstIndex(where: { $0["id"] as? String == todoItemId }) {
                // Remove the item from the Firestore list
                todoList.remove(at: firestoreIndex)
                
                // Update the Firestore document with the new list
                ref.updateData(["todoList": todoList]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Item successfully deleted from Firestore.")
                    }
                }
            } else {
                print("Item not found in Firestore list.")
            }
        }
    }

    
    
}
