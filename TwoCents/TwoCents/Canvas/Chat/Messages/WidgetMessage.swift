//
//  ChatBubble.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/15.
//

import SwiftUI

protocol MessageView: View {
    var message: any WidgetMessage { get }
}

@ViewBuilder
func makeMessage(message: any WidgetMessage) -> some View{
    switch message.messageType {
    case .text:
        if let textMsg = message as? TextMessage {
            // If it's not actually a TextMessage, return an error view
            TextMessageView(message: textMsg)
                .onAppear {
                    
                    print("Text Message")
                }
        } else {
            EmptyMessageView(message: message)
                .onAppear {
                    
                    print("Empty Message")
                }
        }
    default:
        EmptyMessageView(message: message)
    }
}

@ViewBuilder
func makePreviewMessage(message: any WidgetMessage) -> some View {
    switch message.messageType {
    case .text:
        if let textMsg = message as? TextMessage {
            TextMessageView(message: textMsg)
        } else {
            EmptyMessageView(message: message)
        }
    default:
        EmptyMessageView(message: message)
    }
}

protocol WidgetMessage: Codable, Equatable, Identifiable {
    var id: String { get }
    var dateCreated: Date { get }
    var messageType: MessageType { get }
    var sendBy: String { get }
}

enum MessageType: String, Codable {
    case text
    case widget
    case empty
}


struct EmptyMessage: WidgetMessage {
    let id: String
    let dateCreated: Date
    let messageType: MessageType
    let sendBy: String
    
    init() {
        self.id = UUID().uuidString
        self.dateCreated = Date()
        self.messageType = .empty
        self.sendBy = ""
    }
}

struct EmptyMessageView: MessageView {
    let message: any WidgetMessage
    
    var body: some View {
        EmptyView()
    }
    
}
