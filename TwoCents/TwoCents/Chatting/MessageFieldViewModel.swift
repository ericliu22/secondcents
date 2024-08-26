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
    
    
    
    func sendMessages(text: String?, widget: CanvasWidget?, spaceId: String, threadId: String) {
        let docRef = db.collection("spaces").document(spaceId).collection("chat").document("mainChat")

        docRef.getDocument{ [self] (document, error) in
            if let document = document {
                let property = document.get("lastSend")
                
                do {
                    //if there is both text and widget, send widget first seperately, then the text.
                    if text != nil && widget != nil {
                        messageNotification(spaceId: spaceId, userUID: user?.userId ?? "", message: (text == "" ? "Replied to a widget" : text)!)
                        sendMessages(text: nil, widget: widget, spaceId: spaceId, threadId: threadId)
                        sendMessages(text: text, widget: nil, spaceId: spaceId, threadId: widget?.id.uuidString ?? "")
                        print("2")
                    } else {
                        
                        print("thread id is this \(threadId)")
                       
                        //create uuid for name
                        let uuidString = widget?.id.uuidString.isEmpty ?? true ? UUID().uuidString : widget!.id.uuidString

                        
                        let threadIdInput = threadId == "" ? uuidString : threadId
                        
                     
                        
                        
                        let mainChatReference = db.collection("spaces").document(spaceId).collection("chat").document("mainChat")
                        let newMessage = Message(id: uuidString, sendBy: user?.userId ?? "", text: text, ts: Date(), parent: (property as? String) ?? "", widgetId: widget?.id.uuidString, threadId: threadIdInput)
                        try mainChatReference.collection("chatlogs").document(uuidString).setData(from: newMessage)
                        mainChatReference.setData(["lastSend": newMessage.sendBy], merge: true)
                        mainChatReference.setData(["lastTs": newMessage.ts], merge: true)
                        messageNotification(spaceId: spaceId, userUID: user?.userId ?? "", message: text ?? "replied to a widget")

                    }
                    Task {
                        await messageUnread(spaceId: spaceId)
                    }
                    AnalyticsManager.shared.messageSend()

                    } catch {
                    print("Error adding message to Firestore: \(error)")
                }
                
            } else {
                print("Document does not exist in cache")
            }
        }
        
    }
    
    
    
    
    
    
}



