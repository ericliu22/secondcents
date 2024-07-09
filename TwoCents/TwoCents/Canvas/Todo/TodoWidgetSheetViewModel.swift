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
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func loadUser(userId: String) async throws {
        self.user = try await UserManager.shared.getUser(userId: userId)
    }
    
    @Published private(set) var todo: Todo?
    @Published var mentionedUsers: [DBUser?] = []
    
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
                        
                        // Update mentionedUsers to match the size of todoList
                        self.mentionedUsers = Array(repeating: nil, count: todoData.todoList.count)
                        
                        for (index, todoItem) in todoData.todoList.enumerated() {
                            if !todoItem.mentionedUserId.isEmpty {
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
    
    func updateMentionedUser(spaceId: String, todoId: String, index: Int, mentionedUserId: String) {
        let db = Firestore.firestore()
        let ref = db.collection("spaces").document(spaceId).collection("todo").document(todoId)
        
        ref.getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data(), var todoList = data["todoList"] as? [[String: Any]] else {
                print("Document does not exist or is not valid")
                return
            }
            
            // Update the mentionedUserId at the specific index
            if index < todoList.count {
                todoList[index]["mentionedUserId"] = mentionedUserId
                
                // Set the updated todoList back to Firestore
                ref.updateData(["todoList": todoList]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Document successfully updated.")
                    }
                }
            } else {
                print("Index out of bounds")
            }
        }
    }
}
