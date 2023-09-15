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
    
   
}
