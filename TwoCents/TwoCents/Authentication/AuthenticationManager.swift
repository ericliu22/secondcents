//
//  AuthenticationManager.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel{
    let uid: String
    let email: String?
//    let photoUrl: String?
  
    
    init (user: User){
        
        self.uid = user.uid
        self.email = user.email
//        self.photoUrl = user.photoURL?.absoluteString
        
    }
    
}

final class AuthenticationManager{
    
    @MainActor static let shared = AuthenticationManager()
    
    private var verificationId: String?

    private init (){
        
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
       
        return AuthDataResultModel(user:user)
        
    }
    
    #warning("Don't use this unless absolutely necessary. This shit is essentially the user's password")
    /**
     CAUTION: Don't use this anywhere in the app unless it's absolutely necessary
    */
    func getJwtToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw AuthErrorCode.nullUser
        }
        
        return try await user.getIDToken()
    }
    
    
    //WITH EMAIL
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        AnalyticsManager.register()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    
    

    public func startAuth(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationId, error in
            if let error = error {
                print("Verification failed with error: \(error.localizedDescription)")
                print(error)
                completion(.failure(error))
                return
            }
            
            if let verificationId = verificationId {
                print("Verification ID received: \(verificationId)")
                self.verificationId = verificationId
                completion(.success(verificationId))
            } else {
                print("Failed to receive verification ID.")
                completion(.failure(URLError(.badServerResponse)))
            }
        }
    }
    
    public func verifyCode(smsCode: String, completion: @escaping (Bool) -> Void) {
        print("verifyCode: Entered function")

        guard let verificationId = self.verificationId else {
            print("verifyCode: verificationId is nil")
            completion(false)
            return
        }
        
        print("verifyCode: verificationId found - \(verificationId)")
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print("verifyCode: Sign in failed with error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard result != nil else {
                print("verifyCode: Sign in result is nil")
                completion(false)
                return
            }
            
            print("verifyCode: Sign in successful")
            completion(true)
        }
    }

    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        AnalyticsManager.login()
        return AuthDataResultModel(user: authDataResult.user)
       
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updateEmail(to: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
}
