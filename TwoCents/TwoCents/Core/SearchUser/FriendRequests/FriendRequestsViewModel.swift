//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI




@Observable @MainActor
final class FriendRequestsViewModel {
    
    var user:  DBUser? = nil
    var allRequests: [DBUser] = []
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func getAllRequests(targetUserId: String) async throws {
       
        try? await loadCurrentUser()
        self.allRequests = try await UserManager.shared.getAllRequests(userId: targetUserId)
        
    }
    
    func acceptFriendRequest(friendUserId: String)  {
        guard !friendUserId.isEmpty else { return }
        
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            do {
                try await UserManager.shared.acceptFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
                await acceptFriendRequestNotification(userUID: authDataResultUserId, friendUID: friendUserId)
            } catch {
                print(error.localizedDescription)
            }
            
            
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



