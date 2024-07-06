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
final class MentionFriendsViewModel: ObservableObject {
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    
    @Published private(set) var allFriends: [DBUser] = []
    
    
    func getAllFriends(targetUserId: String) async throws {
        print(targetUserId)
        try? await loadCurrentUser()
        self.allFriends = try await UserManager.shared.getAllFriends(userId: targetUserId)
    }
    
  
    
    
    
    
}



