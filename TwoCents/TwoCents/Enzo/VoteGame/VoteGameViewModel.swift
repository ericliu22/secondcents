//
//  CreateProfileViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import Foundation
import SwiftUI
import PhotosUI



@MainActor
final class VoteGameViewModel: ObservableObject{
    
    @Published private(set) var user:  DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
    
    
    @Published private(set) var space:  DBSpace? = nil
    
    func loadCurrentSpace(spaceId: String) async throws {
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
    
}
