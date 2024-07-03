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
            print(messageId)
            
            print(message?.text)
            
            
            do {
                if let userId = message?.sendBy, !userId.isEmpty {
                    let user = try await UserManager.shared.getUser(userId: userId)
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
