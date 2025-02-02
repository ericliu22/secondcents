//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI

protocol Requestable: Identifiable {
    var id: String { get }
    var isSpaceRequest: Bool { get }
    //var userColor: String { get }
}

@Observable @MainActor
final class RequestsViewModel {
    
    var user:  DBUser? = nil
    var allFriendRequests: [DBUser] = []
    var allSpaceRequests: [DBSpace] = []
    var allRequests: [any Requestable] = []
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    //friend requests
    func getAllFriendRequests(targetUserId: String) async throws {
        try? await loadCurrentUser()
        self.allFriendRequests = try await UserManager.shared.getFriendRequests(userId: targetUserId)
    }
    
    //Space requests
    func getSpaceRequests(targetUserId: String) async throws {
        try? await loadCurrentUser()
        self.allSpaceRequests = try await UserManager.shared.getSpaceRequests(userId: targetUserId)
    }
    
    //combine Requests
    func getAllRequests(for userId: String) async {
        do {
            // 1. Fetch friend requests
            try await getAllFriendRequests(targetUserId: userId)
            
            // 2. Fetch space requests
            try await getSpaceRequests(targetUserId: userId)
            
            // 3. Combine into one array
            var combined: [any Requestable] = []
            combined.append(contentsOf: allFriendRequests)
            combined.append(contentsOf: allSpaceRequests)
            
            // 4. Assign to the published property
            DispatchQueue.main.async {
                self.allRequests = combined
            }
        } catch {
            print("Failed to load requests: \(error)")
        }
    }
    
    func acceptFriendRequest(friendUserId: String)  {
        guard !friendUserId.isEmpty else { return }
        
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            do {
                try await UserManager.shared.acceptFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
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
            
            
            try? await UserManager.shared.declineFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
            
            
        }
    }
    
    func acceptSpaceRequest(spaceId: String) {
        guard !spaceId.isEmpty else { return }
        Task{
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != spaceId else { return }
            
            
            do {
                try await acceptSpaceRequest(spaceId: spaceId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //decline space request
    func declineSpaceRequest(spaceId: String) {
        guard !spaceId.isEmpty else { return }
        Task{
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != spaceId else { return }
            
            
            do {
                try await declineSpaceRequest(spaceId: spaceId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getUserColor(userColor: String) -> Color{

        return Color.fromString(name: userColor)
        
    }
    
    
    
    
    
    
    
}



