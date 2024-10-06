//
//  AppModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/6.
//

import Foundation
import SwiftUI
import Firebase

@Observable @MainActor
final class AppModel {
    
    var navigationSpaceId: String?
    var shouldNavigateToSpace: Bool = false
    var correctTab: Bool = false
    var inSpace: Bool = false
    var currentSpaceId: String?
    var navigationMutex: NSCondition = NSCondition()
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
        guard let spaceId = navigationSpaceId else { return }
        Firestore.firestore().collection("spaces").document(spaceId).updateData([
            "members": FieldValue.arrayUnion([userId])
        ])
    }
    
}
