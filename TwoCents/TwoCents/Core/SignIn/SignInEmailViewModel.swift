//
//  SignInEmailViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation


@MainActor
final class SignInEmailViewModel: ObservableObject{
   
    @Published var email = ""
    @Published var password = ""
    
  
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            throw URLError(.badServerResponse)
            
//            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
      
        
    }
    
    
    
}
