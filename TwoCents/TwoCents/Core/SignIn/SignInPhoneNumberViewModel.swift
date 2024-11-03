//
//  SignInEmailViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation


@MainActor
final class SignInPhoneNumberViewModel: ObservableObject{
   
    @Published var phoneNumber = ""
//    @Published var password = ""
    
    @Published  var statusMessage: String = ""
    func sendCode() async throws {
           let number = "+1\(phoneNumber)"
           print(number)
           
        do {
            try await withCheckedThrowingContinuation { continuation in
                AuthenticationManager.shared.startAuth(phoneNumber: number) { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            print("Error occurred during authentication: \(error.localizedDescription)")
            statusMessage = "\(error.localizedDescription)"
            // Handle the error, e.g., show an alert to the user
        }

        
        
       }
    
    
    func validatePhoneNumber() -> Bool {
            let phoneNumberRegex = "^[0-9]{10}$" // Adjust the regex as per the phone number format requirements
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
            return phoneTest.evaluate(with: phoneNumber)
        }
    
    
    
    func formatPhoneNumber() {
        var cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        // Check if the phone number starts with "+1" and remove it if found
        if cleanedPhoneNumber.hasPrefix("1") {
            cleanedPhoneNumber = String(cleanedPhoneNumber.dropFirst(1))
        }
        
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
