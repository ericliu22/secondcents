//
//  ProfileViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import Foundation


@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    
    func loadTargetUser(targetUserId: String) async throws {
        
        self.user = try await UserManager.shared.getUser(userId: targetUserId)
    }
    
    
    func addFriend(friendUserId: String)  {
        guard !friendUserId.isEmpty else { return }
        isFriend = true
        
        
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            try? await UserManager.shared.addFriend(userId: authDataResultUserId, friendUserId: friendUserId)
            
            
        }
    }
    
    func removeFriend(friendUserId: String)  {
        guard !friendUserId.isEmpty else { return }
        isFriend = false
        
        
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            try? await UserManager.shared.removeFriend(userId: authDataResultUserId, friendUserId: friendUserId)
            
            
        }
    }
    
    
    
//
//    func removeFriend(friendUserId: String)  {
//        guard !friendUserId.isEmpty else { return }
//        Task {
//            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
//            
//            
//            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
//            
//            guard authDataResultUserId != friendUserId else { return }
//            
//            
//            try? await UserManager.shared.removeFriend(userId: authDataResultUserId, friendUserId: friendUserId)
//        }
//    }
//    
    
    @Published private(set) var isFriend:  Bool? 
    
    func checkFriendshipStatus() {
        do {
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            isFriend =  user?.friends?.contains(authDataResultUserId)
          
            
                
             
        } catch {
            print(error)
        }
        
//        return false
        
    }
    
    
}
