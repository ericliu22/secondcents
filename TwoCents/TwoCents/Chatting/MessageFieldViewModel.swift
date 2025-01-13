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
final class MessageFieldViewModel: ObservableObject {
    
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
    
    func sendMessages(text: String?, widget: CanvasWidget?, spaceId: String, threadId: String){
        let docRef = db.collection("spaces").document(spaceId).collection("chat").document("mainChat")

        docRef.getDocument { [self] (document, error) in
            guard let document = document, error == nil else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
//                completion(false)  // Indicate failure
                return
            }

            let lastSendProperty = document.get("lastSend") as? String

            do {
                if let text = text, let widget = widget {
                    let body: String = text.isEmpty ? "Replied to a widget" : text
                    Task {
                        try await chatNotification(spaceId: spaceId, body: body)
                    }
                    sendMessages(text: nil, widget: widget, spaceId: spaceId, threadId: threadId)
                    sendMessages(text: text, widget: nil, spaceId: spaceId, threadId: widget.id.uuidString)
                } else {
                    let uuidString = widget?.id.uuidString.isEmpty ?? true ? UUID().uuidString : widget!.id.uuidString
                    let resolvedThreadId = threadId.isEmpty ? uuidString : threadId

                    let newMessage = Message(
                        id: uuidString,
                        sendBy: user?.userId ?? "",
                        text: text,
                        ts: Date(),
                        parent: lastSendProperty ?? "",
                        widgetId: widget?.id.uuidString,
                        threadId: resolvedThreadId
                    )

                    let mainChatReference = db.collection("spaces").document(spaceId).collection("chat").document("mainChat")
                    try mainChatReference.collection("chatlogs").document(uuidString).setData(from: newMessage)

                    mainChatReference.setData([
                        "lastSend": newMessage.sendBy,
                        "lastTs": newMessage.ts
                    ], merge: true)

                    let body: String = text ?? "Replied to a widget"
                    Task {
                        try await chatNotification(spaceId: spaceId, body: body)
                    }

                    Task {
                        await messageUnread(spaceId: spaceId)
                    }
                    AnalyticsManager.shared.messageSend()

//                    completion(true)  // Indicate success
                }
            } catch {
                print("Error adding message to Firestore: \(error.localizedDescription)")
//                completion(false)  // Indicate failure
            }
        }
    }

    
    
    
    
    
    
}



