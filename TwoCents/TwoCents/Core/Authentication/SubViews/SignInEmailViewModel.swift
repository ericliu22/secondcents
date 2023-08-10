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
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
//        try await UserManager.shared.createNewUser(auth: authDataResult)
        
        let user = DBUser(auth: AuthDataResultModel)
        try await UserManager.shared.createNewUser(user: user)
      
        
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
      
        
    }
    
}
