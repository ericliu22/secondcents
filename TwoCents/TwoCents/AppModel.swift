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
    case space(spaceId: String, widgetId: String?)
}

enum NotificationRequest: Equatable {
    case none
    case notification(title: String, message: String, spaceId: String? = nil, widgetId: String? = nil)
}

@Observable @MainActor
final class AppModel {
    
    var navigationRequest: NavigationRequest = .none
    var loadedColor: Color = .gray
    var user: DBUser?
    var activeSheet: PopupSheet?
    var notificationRequest: NotificationRequest = .none
    
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
    
    func showNotification(title: String, message: String, spaceId: String? = nil, widgetId: String? = nil) {
        notificationRequest = .notification(title: title, message: message, spaceId: spaceId, widgetId: widgetId)
    }
    
    func addToSpace(userId: String) {
        return
    }
    
}
