//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore

struct ImageModel {
    var id = UUID()
    var quote : String
    var url: String
}


@MainActor
final class SearchUserViewModel: ObservableObject {
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
 
    
    @Published private(set) var friends: [DBUser] = []
    
    
    
    func getAllFriends() async throws {
        
        self.friends = try await UserManager.shared.getAllFriends()
        
        
    }
    
    
  
    
}
    
    
 
