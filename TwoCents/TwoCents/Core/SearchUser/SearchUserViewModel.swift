//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI


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
    
    
    
    @Published private(set) var allUsers: [DBUser] = []
    
    
    
    func getAllUsers() async throws {
        try? await loadCurrentUser()
      
        self.allUsers = try await UserManager.shared.getAllUsers(userId: user!.userId, friendsOnly: false)
       
    }
    
    func getAllFriends(targetUserId: String) async throws {
        print(targetUserId)
        try? await loadCurrentUser()
        self.allUsers = try await UserManager.shared.getAllUsers(userId: targetUserId, friendsOnly: true)
    }
    
    
    func getUserColor(userColor: String) -> Color{

        switch userColor {
            
        case "red":
            return Color.red
        case "orange":
            return Color.orange
        case "yellow":
            return Color.yellow
        case "green":
            return Color.green
        case "mint":
            return Color.mint
        case "teal":
            return Color.teal
        case "cyan":
            return Color.cyan
        case "blue":
            return Color.blue
        case "indigo":
            return Color.indigo
        case "purple":
            return Color.purple
        case "pink":
            return Color.pink
        case "brown":
            return Color.brown
        default:
            return Color.gray
        }
        
        
        
    }
    
    
    
    
    
    
    
}



