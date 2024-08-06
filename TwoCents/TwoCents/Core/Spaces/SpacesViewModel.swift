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
final class SpacesViewModel: ObservableObject {
    
    @Published var user:  DBUser? = nil
    @Published var allSpaces: [DBSpace] = []
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func getAllSpaces(userId: String) async throws {
        try? await loadCurrentUser()

        self.allSpaces = try await UserManager.shared.getAllSpaces(userId: userId)

    }
    
    func getUserColor(userColor: String) -> Color{

        return Color.fromString(name: userColor)
        
    }
    
    
    
    
    
    
    
}



