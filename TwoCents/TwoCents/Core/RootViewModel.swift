//
//  FrontPageViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/22/23.
//

import Foundation

import SwiftUI



@Observable
final class RootViewModel{
    
    var user:  DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
    
    func getUserColor(userColor: String) -> Color{
        return Color.fromString(name: userColor)
    }
    
    
        
    
    
}
