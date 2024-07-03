//
//  ChatBubbleViewBuilder.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//


import SwiftUI

struct ChatBubbleViewBuilder: View {
    
    let messageId: String
    let spaceId: String
    @State private var message: Message? = nil
    
    @State private var name: String = ""
    @State private var user: DBUser?
    @State private var userColor: Color = .gray
    
    var body: some View {
        ZStack {
            if let message {
                ChatBubbleView(message: message, sentByMe: message.sendBy == user?.userId, isFirstMsg: message.sendBy != message.parent, name: name)
            }
        }
        .task {
            self.message = try? await NewMessageManager.shared.getMessage(messageId: messageId, spaceId: spaceId)
            
            
            
            self.name = try! await UserManager.shared.getUser(userId: message?.sendBy ?? "").name!
            
        
            user = try! await UserManager.shared.getUser(userId: message?.sendBy ?? "")
            
            withAnimation{
                self.userColor = Color.fromString(name: user?.userColor ?? "")
                
            }
            
//            if message.widgetId != nil {
//                
//                try? await viewModel.loadWidget(spaceId: spaceId , widgetId: message.widgetId!)
//            }
//   
            
            
            
            
            
            
        }
    }
}

//struct ChatBubbleViewBuilder_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatBubbleViewBuilder(productId: "1")
//    }
//}
