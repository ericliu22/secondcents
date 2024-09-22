//
//  NewLinkViewModel.swift
//  TwoCents
//
//  Created by Eric Liu on 24/8/3.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import Observation

@Observable @MainActor
final class NewLinkViewModel {
    
    //this might cause errors bc several places are running and creating and overriding db user below... but for now its good
    var space:  DBSpace? = nil
    var WidgetMessage: CanvasWidget? = nil
    var user: DBUser?

    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func loadCurrentSpace(spaceId: String) async throws {
        
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
    func loadWidget(spaceId: String, widgetId: String) async throws {
        
        self.WidgetMessage = try await SpaceManager.shared.getWidget(spaceId: spaceId, widgetId: widgetId)
        
    }
    
}



