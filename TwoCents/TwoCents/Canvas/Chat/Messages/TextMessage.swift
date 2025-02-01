//
//  Message.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/15.
//
import Foundation
import SwiftUI

struct TextMessage: Message {
    
    let id: String
    let dateCreated: Date
    let messageType: MessageType
    let sendBy: String
    var text: String
    
    init(sendBy: String, text: String) {
        self.id = UUID().uuidString
        self.dateCreated = Date()
        self.messageType = .text
        self.sendBy = sendBy
        self.text = text
    }

}

struct TextMessageView: MessageView {
    
    @Environment(ChatWidgetViewModel.self) var chatViewModel
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @Environment(AppModel.self) var appModel
    let message: any Message
    let textMessage: TextMessage
    @State var userColor: Color = .gray
    
    init(message: TextMessage) {
        assert(message.messageType == .text)
        self.message = message
        self.textMessage = message
    }
    
    var body: some View {
        VStack{
            if chatViewModel.messageChange(messageId: textMessage.id) {
                Text(canvasViewModel.members.first(where: { u in u.userId == textMessage.sendBy})?.name ?? "")
                    .foregroundStyle(userColor)
                    .font(.caption)
                    .padding(.top, 3)
                    .padding(textMessage.sendBy == appModel.user!.userId ? .leading : .trailing, 6)
            }
            Text(textMessage.text)
                .font(.headline)
                .fontWeight(.regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(userColor)
                .background(.ultraThickMaterial)
                .background(userColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .onAppear {
            guard let colorString = canvasViewModel.members.first(where: {u in u.userId == textMessage.sendBy})?.userColor else {
                return
            }
            userColor = Color.fromString(name: colorString)
        }
    }
    
}

