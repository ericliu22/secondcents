//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI

@Observable @MainActor
final class TextWidgetViewModel {
    
    //this might cause errors bc several places are running and creating and overriding db user below... but for now its good
    var user:  DBUser? = nil
    var WidgetMessage: CanvasWidget? = nil
    var canvasWidgetTextString: String? = nil
    var userColor:  Color? = nil

    func getUserColorWrapper(userColor: String) {
        
        self.userColor = getUserColor(userColor: userColor)
    }
    
    
    func getUserColor(userColor: String) -> Color{
        
        return Color.fromString(name: userColor)
        
    }
    //Josh Added
    func loadWidgetTextString(spaceId: String, widgetId: String) async throws {
        self.canvasWidgetTextString = try await SpaceManager.shared.getWidget(spaceId: spaceId, widgetId: widgetId).textString
    }
    
    
}



