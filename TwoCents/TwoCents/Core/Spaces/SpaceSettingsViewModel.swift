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
final class SpaceSettingsViewModel: ObservableObject {
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    @Published private(set) var space:  DBSpace? = nil
    func loadCurrentSpace(spaceId: String) async throws {
        
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
    
    func getMembersInfo() async throws {
        
        guard let space else {return }
       
        self.allMembers = try await UserManager.shared.getMembersInfo(members: (space.members)!)
    }
    
    
    
    @Published private(set) var allMembers: [DBUser] = []
    
    
    
    func removeSelf( spaceId: String) async throws  {
  
        let selfId = try AuthenticationManager.shared.getAuthenticatedUser().uid
        try await SpaceManager.shared.removeUserFromSpace(userId: selfId, spaceId: spaceId)
        
    }
    
    func removeUser(userId: String, spaceId: String) async throws  {
  
      
        try await SpaceManager.shared.removeUserFromSpace(userId: userId, spaceId: spaceId)
        
    }
    
    func deleteSpace(spaceId: String) async throws {

        
          
          try await SpaceManager.shared.deleteSpace(spaceId: spaceId)
        
          
      }
    
    
    
    func getUserColor(userColor: String) -> Color{
        
        return Color.fromString(name: userColor)
        
    }
    
    
}



