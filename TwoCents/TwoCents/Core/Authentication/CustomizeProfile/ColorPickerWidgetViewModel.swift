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
    @Environment(AppModel.self) var appModel
    
//    
//    @Published private(set) var user:  DBUser? = nil
//    func loadCurrentUser() async throws {
//        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
//        
//    }
//    
//    
    
    func saveUserColor(selectedColor: Color, userId: String ) {
        
//        guard let user = appModel.user else { return }
        
        
        Task {
            
            try await UserManager.shared.updateUserColor(userId: userId, selectedColor: selectedColor)
            
            print(selectedColor)
//            appModel.loadedColor = selectedColor
            
       
//            try? await loadCurrentUser()
            
        }
        
    }
    
}
