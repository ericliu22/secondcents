//
//  CanvasWidgetMessage.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/20.
//

import Foundation
import SwiftUI

struct WidgetMessage: Message {
    
    let id: String
    let dateCreated: Date
    let messageType: MessageType
    let sendBy: String
    let widgetId: String
    var text: String
    
    init(sendBy: String, text: String, widgetId: String) {
        self.id = UUID().uuidString
        self.dateCreated = Date()
        self.messageType = .text
        self.sendBy = sendBy
        self.text = text
        self.widgetId = widgetId
    }

}

struct WidgetMessageView: MessageView {
    
    @Environment(ChatWidgetViewModel.self) var chatViewModel
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @Environment(AppModel.self) var appModel
    let message: any Message
    let canvasWidgetMessage: WidgetMessage
    @State var canvasWidget: CanvasWidget?
    @State var userColor: Color = .gray
    
    init(message: WidgetMessage) {
        assert(message.messageType == .widget)
        self.message = message
        self.canvasWidgetMessage = message
    }
    
    var body: some View {
        VStack{
            if chatViewModel.messageChange(messageId: canvasWidgetMessage.id) {
                Text(canvasViewModel.members.first(where: { u in u.userId == canvasWidgetMessage.sendBy})?.name ?? "")
                    .foregroundStyle(userColor)
                    .font(.caption)
                    .padding(.top, 3)
                    .padding(canvasWidgetMessage.sendBy == appModel.user!.userId ? .leading : .trailing, 6)
            }
            if let widget = canvasWidget {
                MediaView(widget: widget, spaceId: chatViewModel.spaceId)
                    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                    .cornerRadius(CORNER_RADIUS)
                    .frame(width: TILE_SIZE, alignment: .trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .id("replyWidget")
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.bottom, 3)
                    .listRowBackground(Color.clear)
            }
            Text(canvasWidgetMessage.text)
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
            guard let colorString = canvasViewModel.members.first(where: {u in u.userId == canvasWidgetMessage.sendBy})?.userColor else {
                return
            }
            userColor = Color.fromString(name: colorString)
            canvasWidget = canvasViewModel.canvasWidgets.first(where: { $0.id.uuidString == canvasWidgetMessage.widgetId})
        }
    }
    
}

