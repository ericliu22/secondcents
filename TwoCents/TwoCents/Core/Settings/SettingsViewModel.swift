//
//  SettingsViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation


@MainActor


        
final class SettingsViewModel: ObservableObject{
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        //NEED TO CHANGE TO BE IN BRACKET ABOVE. BUT NEED TO IMPLEMENT UI
        
        let email = "123"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        
        let password = "123"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}
