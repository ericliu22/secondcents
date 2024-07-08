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
final class MentionUserViewModel: ObservableObject {
   
    
    @Published private(set) var space:  DBSpace? = nil
    @Published private(set) var allUsers: [DBUser] = []
    
    func loadCurrentSpace(spaceId: String) async throws {
        
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
    
    
    
    func getAllUsers(targetUserId: String, spaceId: String) async throws {
      
        try await loadCurrentSpace(spaceId: spaceId)
        
        guard let space else {return }
       
        self.allUsers = try await UserManager.shared.getMembersInfo(members: (space.members)!)
        
        
        
        
    }
    
  
   
    
    
}



