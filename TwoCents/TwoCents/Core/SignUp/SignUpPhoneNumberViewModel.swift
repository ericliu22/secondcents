//
//  SignInEmailViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation

@MainActor

final class SignUpPhoneNumberViewModel: ObservableObject{
    
    
    @Published var name = ""

    
    
    
  
    
    func signUp(userPhoneNumber: String) async throws {
        guard !name.isEmpty else {
            print("Fields are empty")
            throw URLError(.badServerResponse)
//            return
        }
        
        
        let uid = try await AuthenticationManager.shared.getAuthenticatedUser().uid
        

        
        let user = DBUser( uid: uid, name: name.trimmingCharacters(in: .whitespacesAndNewlines), userPhoneNumber: userPhoneNumber)
     
        try await UserManager.shared.createNewUser(user: user)
      
        
    }
    
    
    
    
}
