//
//  ColorPickerWidgetViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/22/23.
//

import Foundation
import SwiftUI

@MainActor
final class ColorPickerWidgetViewModel: ObservableObject{
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
    
    
    func saveUserColor(selectedColor: Color) {
        
        guard let user else { return }
        
        
        Task {
            
           
            
            try await UserManager.shared.updateUserColor(userId: user.userId, selectedColor: selectedColor)
       
            try? await loadCurrentUser()
     
            
        }
        
    }
    
}
