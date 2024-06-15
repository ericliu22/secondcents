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

}
