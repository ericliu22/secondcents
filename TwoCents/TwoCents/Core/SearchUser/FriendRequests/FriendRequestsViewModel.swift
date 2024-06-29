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
final class FriendRequestsViewModel: ObservableObject {
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    
    @Published private(set) var allRequests: [DBUser] = []
//    @State private(set) var requestLoaded: Bool = false
    
    func getAllRequests(targetUserId: String) async throws {
       
        try? await loadCurrentUser()
        self.allRequests = try await UserManager.shared.getAllRequests(userId: targetUserId)
        
//        requestLoaded = true
        
//        self.allRequests = try await UserManager.shared.getAllUsers(userId: targetUserId, friendsOnly: true)
    }
    
    func acceptFriendRequest(friendUserId: String)  {
        guard !friendUserId.isEmpty else { return }
        
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            try? await UserManager.shared.acceptFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
            
            
        }
    }
    
    func declineFriendRequest(friendUserId: String)  {
        guard !friendUserId.isEmpty else { return }
        
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            try? await UserManager.shared.acceptFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
            
            
        }
    }
    
    
    func getUserColor(userColor: String) -> Color{

        return Color.fromString(name: userColor)
        
    }
    
    
    
    
    
    
    
}



