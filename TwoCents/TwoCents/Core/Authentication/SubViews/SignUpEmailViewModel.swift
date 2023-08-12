//
//  SignInEmailViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation


@MainActor
final class SignUpEmailViewModel: ObservableObject{
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        guard password == confirmPassword else {
            print("password and confirm password are not equal")
            return
        }
        
        
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
//        try await UserManager.shared.createNewUser(auth: authDataResult)
        
        let user = DBUser(auth: authDataResult)
        
        try await UserManager.shared.createNewUser(user: user)
      
        
    }
    
    
}
