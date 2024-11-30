//
//  SignInEmailViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation

enum SignInError: Error {
    case emptyField
}

extension SignInError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyField:
            return NSLocalizedString("No email or password found.", comment: "")
        }
    }
}

@Observable @MainActor
final class SignInEmailViewModel {
   
    var email: String = ""
    var password: String = ""
    var errorMessage: String = ""
    
  
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw SignInError.emptyField
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    
    
}
