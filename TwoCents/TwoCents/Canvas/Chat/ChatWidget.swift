//
//  ChatWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/15.
//

import SwiftUI
import FirebaseFirestore

struct Chat: Identifiable, Codable {
    let id: String
    let spaceId: String
    var name: String
    var members: [String]
    var lastSender: String
    
    init(userId: String, spaceId: String, name: String, members: [String], id: String) {
        self.id = id
        self.spaceId = spaceId
        self.name = name
        self.members = members
        self.lastSender = userId
    }
    
    
}


struct ChatWidget: WidgetView {

    let widget: CanvasWidget
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @State var viewModel: ChatWidgetViewModel
    @FocusState private var isFocused: Bool
    //    @Environment(AppModel.self) var appModel

    init(widget: CanvasWidget, spaceId: String) {
        self.widget = widget
        self.viewModel = ChatWidgetViewModel(
            spaceId: spaceId, chatId: widget.id.uuidString)
    }

    var body: some View {
        if let chat = viewModel.chat {
            NavigationLink {
                ChatPage()
                    .onAppear {
                        canvasViewModel.inSubView = true
                        canvasViewModel.activeWidget = widget
                    }
                    .onDisappear {
                        canvasViewModel.inSubView = false
                        canvasViewModel.activeWidget = nil
                    }
                    .environment(viewModel)
            } label: {
                ChatPreview(messages: viewModel.messages)
                    .frame(width: widget.width, height: widget.height)
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}

struct ChatPreview: View {
    var messages: [any WidgetMessage]

    init(messages: [any WidgetMessage]) {
        self.messages = messages
    }

    var body: some View {
        VStack {
            List {
                ForEach(messages, id: \.id) { message in
                    makePreviewMessage(message: message)
                        .rotationEffect(.degrees(180))
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }
            }
            .rotationEffect(.degrees(180))
        }

    }
}

func deleteChat(spaceId: String, chatId: String) {
    Firestore.firestore().collection("spaces")
        .document(spaceId)
        .collection("chatas")
        .document(chatId)
        .delete()
}
