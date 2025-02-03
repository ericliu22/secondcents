//
//  RequestsViewModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/2/3.
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
    
    let userId: String
    var searchTerm = ""
    var allRequests: [any Requestable] = []
    var filteredSearch: [any Requestable] {
        guard !searchTerm.isEmpty else { return allRequests }
        return allRequests.filter {
            $0.id.localizedCaseInsensitiveContains(searchTerm)
        }
    }
    
    init(userId: String) {
        self.userId = userId
    }

    func attachRequestsListener() {
        Firestore.firestore().collection("users").document(userId).addSnapshotListener({ [weak self] documentSnapshot, error in
            guard let self = self else {
                print("attachRequestsListener: weak self no reference")
                return
            }
            guard let document = documentSnapshot else {
                print("Error fetching query: \(error)")
                return
            }
            
            self.allRequests = []
            if let spaceRequests = document.data()?["spaceRequests"] as? [String] {
                Task {
                    for request in spaceRequests {
                        
                        guard let space = try? await SpaceManager.shared.getSpace(spaceId: request) else {
                            continue
                        }
                        self.allRequests.append(space)
                    }
                }
            }
            if let friendRequests = document.data()?["incomingFriendRequests"] as? [String] {
                Task {
                    for request in friendRequests {
                        guard let user = try? await UserManager.shared.getUser(userId: request) else {
                            continue
                        }
                        self.allRequests.append(user)
                    }
                }
            }

        })
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
            do {
                try await SpaceManager.shared.acceptSpaceRequest(spaceId: spaceId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //decline space request
    func declineSpaceRequest(spaceId: String) {
        guard !spaceId.isEmpty else { return }
        Task{
            do {
                try await SpaceManager.shared.declineSpaceRequest(spaceId: spaceId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getUserColor(userColor: String) -> Color {

        return Color.fromString(name: userColor)
        
    }
    
    
    
    
    
    
    
}


