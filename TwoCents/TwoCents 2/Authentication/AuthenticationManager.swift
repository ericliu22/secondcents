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

    public func startAuth(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        
//        
//        //disable captcha
//        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        

        
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationId, error in
            
            
            
            guard let verificationId = verificationId, error == nil else {
                completion(false)
                return
            }
            
            self.verificationId = verificationId
            completion(true)
            
            
        }
    }
    
    
    
    public func verifyCode(smsCode: String, completion: @escaping (Bool) -> Void) {
        guard let verificationId = self.verificationId else {
            completion(false)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
        
        Auth.auth().signIn(with: credential) { result, error in
            
            guard result != nil, error == nil else {
                
                completion(false)
                return
            }
            
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
