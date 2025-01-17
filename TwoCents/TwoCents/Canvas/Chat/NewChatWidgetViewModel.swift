//
//  NewChatWidgetViewModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/16.
//

import SwiftUI
import FirebaseFirestore

@Observable @MainActor
class NewChatWidgetViewModel {
    var text: String = ""
    var members: [String] = []
    
    init() {
    }
    
    func uploadChat(userId: String, spaceId: String) throws -> CanvasWidget {
        
        let (width, height) = SpaceManager.shared.getMultipliedSize(widthMultiplier: 2, heightMultiplier: 2)
        
        let widget = CanvasWidget(width: width, height: height, borderColor: .red, userId: userId, media: .chat, widgetName: text)
        let chat = Chat(userId: userId, spaceId: spaceId, name: text, members: members, id: widget.id.uuidString)
            try Firestore.firestore().collection("spaces").document(spaceId).collection("chats").document(widget.id.uuidString).setData(from: chat)
            return widget
    }
}
