//
//  FrontPageViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/22/23.
//

import Foundation

import SwiftUI

extension Color {
    
    static func fromString(name: String) -> Color{
        
        switch name {
            
        case "red":
            return Color.red
        case "orange":
            return Color.orange
        case "yellow":
            return Color.yellow
        case "green":
            return Color.green
        case "mint":
            return Color.mint
        case "teal":
            return Color.teal
        case "cyan":
            return Color.cyan
        case "blue":
            return Color.blue
        case "indigo":
            return Color.indigo
        case "purple":
            return Color.purple
        case "pink":
            return Color.pink
        case "brown":
            return Color.brown
        default:
            return Color.gray
        }
        
    }
}

@MainActor
final class RootViewModel: ObservableObject{
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
    
    
    
    
    func getUserColor(userColor: String) -> Color{
        return Color.fromString(name: userColor)
    }
    
    
        
    
    
}
