//
//  NewChatView.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//

import Foundation
import SwiftUI
import UIKit

struct Message: Identifiable, Codable,Equatable {
    var id: String
    var sendBy: String
    var text: String?
    var ts: Date
    var parent: String
    var widgetId: String?
    var threadId: String?
}
import SwiftUI

struct NewChatView: View {
    @State var spaceId: String
    @StateObject private var viewModel = NewChatViewModel()
    let userUID: String = (try? AuthenticationManager.shared.getAuthenticatedUser().uid) ?? ""
    @Binding var replyWidget: CanvasWidget?
    @Binding var detent: PresentationDetent
    @State var threadId: String = ""

    var body: some View {
        ScrollViewReader { proxy in
            List {
                Spacer()
                    .frame(height: 30)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .id("top")

                if let widget = replyWidget {
                    MediaView(widget: widget, spaceId: spaceId)
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                        .cornerRadius(CORNER_RADIUS)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .id("replyWidget")
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .rotationEffect(.degrees(180))
                        .padding(.bottom, 3)
                }
                
                
                
                //thread messages
                ForEach(viewModel.threadMessages) { message in
                    ChatBubbleViewBuilder(messageId: message.id, spaceId: spaceId, currentUserId: userUID, threadId: $threadId)
                        .id(message.id)
                        .rotationEffect(.degrees(180))
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.bottom, 3)
                        .blur(radius: replyWidget == nil ? 0 : 2)

                    if message.id == viewModel.messages.last?.id {
                        if viewModel.hasMoreMessages {
                            ProgressView()
                                .onAppear {
                                    viewModel.getOldMessages(spaceId: spaceId)
                                }
                                .rotationEffect(.degrees(180))
                                .frame(maxWidth: .infinity)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .padding(.bottom, 3)
                        }
                    }
                }
                
                
                
                
                //new messages
                ForEach(viewModel.messagesFromListener) { message in
                    ChatBubbleViewBuilder(messageId: message.id, spaceId: spaceId, currentUserId: userUID, threadId: $threadId)
                        .id(message.id)
                        .rotationEffect(.degrees(180))
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.bottom, 3)
                        .blur(radius: replyWidget == nil && threadId != "" ? 0 : 2)
                }

                
                //old messages
                ForEach(viewModel.messages) { message in
                    ChatBubbleViewBuilder(messageId: message.id, spaceId: spaceId, currentUserId: userUID, threadId: $threadId)
                        .id(message.id)
                        .rotationEffect(.degrees(180))
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.bottom, 3)
                        .blur(radius: replyWidget == nil && threadId == ""  ? 0 : 2)

                    if message.id == viewModel.messages.last?.id {
                        if viewModel.hasMoreMessages {
                            ProgressView()
                                .onAppear {
                                    viewModel.getOldMessages(spaceId: spaceId)
                                }
                                .rotationEffect(.degrees(180))
                                .frame(maxWidth: .infinity)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .padding(.bottom, 3)
                        }
                    }
                }
            }
            .environment(\.defaultMinListRowHeight, 0)
            .rotationEffect(.degrees(180))
            .listStyle(PlainListStyle())
            .onAppear {
                viewModel.getOldMessages(spaceId: spaceId)
                viewModel.fetchNewMessages(spaceId: spaceId)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 20)
            .onChange(of: detent) { _, newValue in
                if newValue == .height(50) {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
            
            
            .onChange(of: threadId) { newValue in
                if !newValue.isEmpty {
                    viewModel.getThreadMessages(spaceId: spaceId, threadId: newValue)
                }
            }
            
            
            
        }
        .padding(.horizontal)
        .onTapGesture {
            withAnimation {
                replyWidget = nil
            }
        }
        .overlay(
            NewMessageField(replyWidget: $replyWidget, spaceId: spaceId, threadId: $threadId)
                .frame(maxHeight: .infinity, alignment: .bottom)
        )
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewChatView(spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E", replyWidget: .constant(nil), detent: .constant(.large))
        }
    }
}
