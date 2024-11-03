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
    
    static let shared = AuthenticationManager()
    
    private init (){
        
    }
    
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
       
        return AuthDataResultModel(user:user)
        
    }
    
    
    //WITH EMAIL
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
  
        
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    
    
    private var verificationId: String?

    public func startAuth(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationId, error in
            if let error = error {
                print("Verification failed with error: \(error.localizedDescription)")
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
