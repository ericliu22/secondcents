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
    

    
    func getAllUsers() async throws {
        try await loadCurrentUser()
        
        guard let user = user else {
            return
        }

        self.allUsers = try await UserManager.shared.getAllUsers(userId: user.userId)
        
        // Loop through all users and update the clickedStates dictionary
        for eachUser in allUsers {
            if let incomingRequests = user.incomingFriendRequests {
                clickedStates[eachUser.userId] = incomingRequests.contains(eachUser.userId)
            } else {
                clickedStates[eachUser.userId] = false
            }
            
            
        
        }
    }
    
    
    
    
    func sendFriendRequest(friendUserId: String)  {
        
        guard !friendUserId.isEmpty else { return }
    
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            try? await UserManager.shared.sendFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
            
            await friendRequestNotification(userUID: authDataResultUserId, friendUID: friendUserId)
            
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
    
    
    
    
    
    
    
}



