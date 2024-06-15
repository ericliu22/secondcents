//
//  SignInEmailViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation


@MainActor
final class VerifyCodeViewModel: ObservableObject{
   
    @Published var verificationCode = ""
//    @Published var password = ""
    
  
    
    func verifyCode(completion: @escaping (Bool) -> Void) {
        AuthenticationManager.shared.verifyCode(smsCode: verificationCode) { [weak self] success in
            completion(success)
        }
    }
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
//    
//    func signUp() async throws {
//        guard !verificationCode.isEmpty else {
//            print("Fields are empty")
//            throw URLError(.badServerResponse)
//
//        }
//        
////        let phoneNumber = 
////        
//        
//        
//        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
////        try await UserManager.shared.createNewUser(auth: authDataResult)
//        
//        let user = DBUser(auth: authDataResult, name: name, username: username)
//        
//        
//        try await UserManager.shared.createNewUser(user: user)
//      
//        
//    }

}
