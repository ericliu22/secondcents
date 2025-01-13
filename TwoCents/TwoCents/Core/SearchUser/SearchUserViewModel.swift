//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI


struct ImageModel {
    var id = UUID()
    var quote : String
    var url: String
}


@MainActor
final class SearchUserViewModel: ObservableObject {
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    
    @Published private(set) var allUsers: [DBUser] = []
    
    
    @Published var clickedStates = [String: Bool]()
    
    @Published var hasMoreUsers: Bool = true
    private var lastDocument: DocumentSnapshot? = nil
    

    
    
    
    
    func sendFriendRequest(friendUserId: String)  {
        
        guard !friendUserId.isEmpty else { return }
    
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            do {
                try await UserManager.shared.sendFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
            } catch {
                print(error.localizedDescription)
            }
            
            clickedStates[friendUserId] = true
        }
    }
    
    
    
    func unsendFriendRequest(friendUserId: String)  {
        
        guard !friendUserId.isEmpty else { return }
       
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            try? await UserManager.shared.unsendFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
            
            
            
            clickedStates[friendUserId] = false
        }
    }
    
    
    
    
   
    
    func getUserColor(userColor: String) -> Color{

        switch userColor {
            
        case "red":
            return Color.red
        case "orange":
            return Color.orange
        case "yellow":
            return Color.yellow
        case "green":
            return Color.green
        case "mint":
            return Color.mint
        case "teal":
            return Color.teal
        case "cyan":
            return Color.cyan
        case "blue":
            return Color.blue
        case "indigo":
            return Color.indigo
        case "purple":
            return Color.purple
        case "pink":
            return Color.pink
        case "brown":
            return Color.brown
        default:
            return Color.gray
        }
        
        
        
    }
    
    
    
    
    
    
    
    private let userCollection = Firestore.firestore().collection("users")
        
    

    
    
    // Get a query for all messages in a specific space
    func getUsersQuery(count: Int) -> Query {
        
        userCollection
            .limit(to: count)
            .order(by: "name")
        
    }
    
    
    
    
    func getAllUsers(count: Int, lastDocument: DocumentSnapshot?) async throws -> (products: [DBUser], lastDocument: DocumentSnapshot?) {
        var query: Query = getUsersQuery(count: count)

        
        
        return try await query
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: DBUser.self)
    }
    
    
    func loadAllUsers(completion: ((Bool, String?) -> Void)? = nil) {
        Task {
            do {
                let (loadedUsers, lastDocument) = try await getAllUsers(count: 10, lastDocument: self.lastDocument)
           
                if loadedUsers.isEmpty {
                    self.hasMoreUsers = false
                } else {
                    self.hasMoreUsers = true
                    
                    let existingUserIDs = Set(self.allUsers.map { $0.id })
                    let uniqueUsers = loadedUsers.filter { !existingUserIDs.contains($0.id) }
                    self.allUsers.append(contentsOf: uniqueUsers)
                    
                    
                    
                    for eachUser in loadedUsers {
                      
                        if let outgoingRequests = user?.outgoingFriendRequests, outgoingRequests.contains(eachUser.userId) {
                            clickedStates[eachUser.userId] = true
                            
                            
                        } else {
                            clickedStates[eachUser.userId] = false
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                    if let lastDocument = lastDocument {
                        self.lastDocument = lastDocument
                    }
                }
                
                completion?(false, nil)
            } catch {
                print("Failed to fetch more users: \(error)")
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
}



