//
//  SignInEmailViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation

@MainActor

final class SignUpEmailViewModel: ObservableObject{
    
    
    @Published var name = ""
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
  
    
    
    
  
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !username.isEmpty, !confirmPassword.isEmpty else {
            print("Fields are empty")
            throw URLError(.badServerResponse)
//            return
        }
        
        guard password == confirmPassword else {
            print("password and confirm password are not equal")
            throw URLError(.badServerResponse)
//            return
        }
        
        
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
//        try await UserManager.shared.createNewUser(auth: authDataResult)
        
        let user = DBUser(auth: authDataResult, name: name, username: username)
        
//
//        let userWithName = DBUser(userId: user.userId, email: user.email, photoUrl: user.photoUrl, dateCreated: user.dateCreated, name: name)
////        UserManager.shared.updateUser(user: updatedUser)
        
        
        
        try await UserManager.shared.createNewUser(user: user)
      
        
    }
    
    
    
    
}
