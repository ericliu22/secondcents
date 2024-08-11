//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI




@MainActor
final class TextWidgetViewModel: ObservableObject {
    
    //this might cause errors bc several places are running and creating and overriding db user below... but for now its good
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func loadUser(userId: String) async throws {
     
        self.user = try await UserManager.shared.getUser(userId: userId)
    }

    
    
    @Published private(set) var space:  DBSpace? = nil
    func loadCurrentSpace(spaceId: String) async throws {
        
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
    
    
    @Published private(set) var WidgetMessage: CanvasWidget? = nil
    func loadWidget(spaceId: String, widgetId: String) async throws {
        
        self.WidgetMessage = try await SpaceManager.shared.getWidget(spaceId: spaceId, widgetId: widgetId)
        
    }
    
    
    func getUserColorWrapper(userColor: String) {
        
        self.userColor = getUserColor(userColor: userColor)
    }
    
    @Published private(set)var userColor:  Color? = nil
    
    func getUserColor(userColor: String) -> Color{
        
        return Color.fromString(name: userColor)
        
    }
    
    
    
    
    
    
    
}



