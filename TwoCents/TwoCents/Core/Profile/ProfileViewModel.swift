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
    
    
    
    func removeFriend(friendUserId: String)  {
        guard !friendUserId.isEmpty else { return }
        isFriend = false
        requestSent = false
        
        
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            try? await UserManager.shared.removeFriend(userId: authDataResultUserId, friendUserId: friendUserId)
            
            
        }
    }
    
    
    
    func sendFriendRequest(friendUserId: String)  {
        
        guard !friendUserId.isEmpty else { return }
        isFriend = false
        requestSent = true
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            try? await UserManager.shared.sendFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
        }
    }
    
    
    func unsendFriendRequest(friendUserId: String)  {
        
        guard !friendUserId.isEmpty else { return }
        isFriend = false
        requestSent = false
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            try? await UserManager.shared.unsendFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
        }
    }
    
    
    
    
    func acceptFriendRequest(friendUserId: String)  {
        
        guard !friendUserId.isEmpty else { return }
        isFriend = true
        requestSent = false
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            try? await UserManager.shared.acceptFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
        }
    }
    
    
    
    
    @Published private(set) var isFriend:  Bool? 
    
    func checkFriendshipStatus() {
        do {
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            isFriend =  user?.friends?.contains(authDataResultUserId)
          
            
                
             
        } catch {
            print(error)
        }
        
    }
    
    
    
    @Published private(set) var requestSent:  Bool?
    
    func checkRequestStatus() {
        do {
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            requestSent =  user?.incomingFriendRequests?.contains(authDataResultUserId)
          
   
                
             
        } catch {
            print(error)
        }
        
    }
    
    @Published private(set) var requestedMe:  Bool?
    
    
   
    func checkRequestedMe() {
        do {
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            requestedMe =  user?.outgoingFriendRequests?.contains(authDataResultUserId)
          
   
                
             
        } catch {
            print(error)
        }
        
    }
    
}
