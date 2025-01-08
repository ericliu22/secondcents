//
//  AppModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/6.
//

import Foundation
import SwiftUI
import Firebase

enum NavigationRequest: Equatable {
    case none
    case space(spaceId: String)
}
@Observable @MainActor
final class AppModel {
    
    var navigationRequest: NavigationRequest = .none
    var loadedColor: Color = .gray
    var user: DBUser?
    var activeSheet: PopupSheet?
    
    init() {
        updateUser()
    }
    
    func updateUser(){
        
        guard let userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid else {
            print("AppModel: Failed to get authenticated user")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateUser()
            }
            
            return
        }
        
        Task {
            guard let dbuser = try? await UserManager.shared.getUser(userId: userId) else {
                print("AppModel: Failed to read uid as DBUser")
                return
            }
            
            
            
            user = dbuser
            guard let color = user?.userColor else {
                print("AppModel: failed to get color")
                return
            }
            self.loadedColor = Color.fromString(name: color)
        }
        
        
        
        
        
        
        
    }
    
    func addToSpace(userId: String) {
        return
    }
    
}
