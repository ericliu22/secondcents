//
//  ChatBubbleViewBuilder.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//


import SwiftUI

struct ChatBubbleViewBuilder: View {
    
//    let messageId: String
    let spaceId: String
    @State  var message: Message
    
    @State private var name: String = ""
    @State private var user: DBUser?
    @State private var userColor: Color = .gray
    let currentUserId: String 
    
    @State private var widget: CanvasWidget? = nil
    
    
    @Binding var threadId: String
    
    
    var body: some View {
        ZStack {
//            if let message {
            ChatBubbleView(message: message, sentByMe: message.sendBy == currentUserId, isFirstMsg: message.sendBy != message.parent, name: name, userColor: userColor, widget: widget ?? nil, spaceId: spaceId, threadId: $threadId)
//            }
        }
        .task {
//            self.message = try? await NewMessageManager.shared.getMessage(messageId: messageId, spaceId: spaceId)
//            print(messageId)
//            
//            print(message?.text)
            
            
            do {
                if !message.sendBy.isEmpty {
                    let user = try await UserManager.shared.getUser(userId: message.sendBy)
                    self.name = user.name ?? ""
                    self.user = user
                } else {
                    // Handle the case where userId is nil or empty
                    print("Invalid userId")
                }
            } catch {
                // Handle errors here
                print("Failed to get user: \(error)")
                // Optionally, set default values or take other actions
                self.name = "Unknown"
                self.user = nil
            }
            
            
            withAnimation{
                self.userColor = Color.fromString(name: user?.userColor ?? "")
                
            }
            
            
            
            //widget
            
            if let myWidget = message.widgetId {
                
                print("got here")
                
                self.widget = try? await SpaceManager.shared.getWidget(spaceId: spaceId, widgetId: myWidget)
            
                
            }
            
            
            
            
            
        }
    }
}

//struct ChatBubbleViewBuilder_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatBubbleViewBuilder(productId: "1")
//    }
//}
