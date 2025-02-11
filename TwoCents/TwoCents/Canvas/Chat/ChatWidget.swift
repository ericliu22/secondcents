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
                        canvasViewModel.lastChatId = widget.id.uuidString
                    }
                    .onDisappear {
                        canvasViewModel.inSubView = false
                        canvasViewModel.activeWidget = nil
                    }
                    .environment(viewModel)
                    .environment(canvasViewModel)

            } label: {
                ChatPreview(messages: viewModel.messages)
                    .frame(width: widget.width, height: widget.height)
            }
            .environment(viewModel)
            .environment(canvasViewModel)
        } else {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}

struct ChatPreview: View {
    @Environment(AppModel.self) var appModel
    var messages: [any Message]

    init(messages: [any Message]) {
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
                        .frame(maxWidth: .infinity, alignment: appModel.user?.userId == message.sendBy ? .leading : .trailing)
                }
            }
            .rotationEffect(.degrees(180))
        }
        .scrollDisabled(true)

    }
}

struct NewChatPreview: View {
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        VStack {
            VStack {
                Text("Alice")
                    .foregroundStyle(appModel.loadedColor)
                    .font(.caption)
                    .padding(.top, 3)
                    .padding(.leading)
                Text("Heyyy")
                    .font(.headline)
                    .fontWeight(.regular)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(appModel.loadedColor)
                    .background(.ultraThickMaterial)
                    .background(appModel.loadedColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            VStack{
                Text("Bob")
                    .foregroundStyle(.purple)
                    .font(.caption)
                    .padding(.top, 3)
                    .padding(.trailing)
                Text("Ew")
                    .font(.headline)
                    .fontWeight(.regular)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(.purple)
                    .background(.ultraThickMaterial)
                    .background(.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

func deleteChat(spaceId: String, chatId: String) {
    spaceReference(spaceId: spaceId)
        .collection("chatas")
        .document(chatId)
        .delete()
}
