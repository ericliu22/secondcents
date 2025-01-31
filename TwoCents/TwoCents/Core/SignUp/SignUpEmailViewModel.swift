//
//  SignInEmailViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation

enum SignUpError: Error {
    case emptyField, passwordNotEqual
}

extension SignUpError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyField:
            return NSLocalizedString("Fields are empty", comment: "")
        case .passwordNotEqual:
            return NSLocalizedString("Password and Confirm password are not the same", comment: "")
        }
    }
}
@Observable @MainActor
final class SignUpEmailViewModel {
    
    
    var name = ""
//    var username = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var errorMessage = ""
  
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty, /*!username.isEmpty,*/ !confirmPassword.isEmpty else {
            throw SignUpError.emptyField
        }
        
        guard password == confirmPassword else {
            throw SignUpError.passwordNotEqual
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult, name: name/*, username: username*/)
        
        try await UserManager.shared.createNewUser(user: user)
      
    }
    
}
