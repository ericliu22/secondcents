//
//  SignInEmailViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation

@MainActor

final class SignUpPhoneNumberViewModel: ObservableObject{
    
    
    @Published var name = ""
    @Published var username = ""
    @Published var phoneNumber = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
  
    
    
    
  
    
    func signUp() async throws {
        guard !phoneNumber.isEmpty, !password.isEmpty, !name.isEmpty, !username.isEmpty, !confirmPassword.isEmpty else {
            print("Fields are empty")
            throw URLError(.badServerResponse)
//            return
        }
        
       
            
            guard password == confirmPassword else {
                print("password and confirm password are not equal")
                throw URLError(.badServerResponse)
                //            return
            }
        if validatePhoneNumber() {
    
        
//        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)

        
//        let user = DBUser(auth: authDataResult, name: name, username: username)
        
        
//        try await UserManager.shared.createNewUser(user: user)
      
        }
    }
    
    
    
    func validatePhoneNumber() -> Bool {
            let phoneNumberRegex = "^[0-9]{10}$" // Adjust the regex as per the phone number format requirements
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
            return phoneTest.evaluate(with: phoneNumber)
        }
    
    
    
    func formatPhoneNumber() {
            let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            
            let formattedNumber = applyPhoneNumberFormat(cleanedPhoneNumber)
            
            if phoneNumber != formattedNumber {
                phoneNumber = formattedNumber
            }
        }

        func applyPhoneNumberFormat(_ number: String) -> String {
            var formattedString = ""
            let length = number.count
            let hasAreaCode = length > 3
            let hasPrefix = length > 6
            
            if length > 0 {
                formattedString.append("(")
                formattedString.append(contentsOf: number.prefix(3))
            }
            if hasAreaCode {
                let startIndex = number.index(number.startIndex, offsetBy: 3)
                let endIndex = number.index(number.startIndex, offsetBy: min(length, 6))
                let range = startIndex..<endIndex
                formattedString.append(") ")
                formattedString.append(contentsOf: number[range])
            }
            if hasPrefix {
                let startIndex = number.index(number.startIndex, offsetBy: 6)
                let endIndex = number.index(number.startIndex, offsetBy: min(length, 10))
                let range = startIndex..<endIndex
                formattedString.append("-")
                formattedString.append(contentsOf: number[range])
            }
            
            return formattedString
        }
        
    func getCleanPhoneNumber() -> String {
          return phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
      }
}


