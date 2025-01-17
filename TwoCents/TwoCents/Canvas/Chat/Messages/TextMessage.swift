//
//  Message.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/15.
//
import Foundation
import SwiftUI

struct TextMessage: WidgetMessage {
    
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
    
    let userColor: Color = .purple
    let message: any WidgetMessage
    let textMessage: TextMessage
    
    init(message: TextMessage) {
        assert(message.messageType == .text)
        self.message = message
        self.textMessage = message
    }
    
    var body: some View {
        VStack{
            Text(textMessage.text)
                .font(.headline)
                .fontWeight(.regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(userColor)
                .background(.ultraThickMaterial)
                .background(userColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(maxWidth: 300, alignment: true ? .trailing : .leading)
        }
    }
    
}
