//
//  NewChatView.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//

import Foundation
import SwiftUI
import UIKit

struct Message: Identifiable, Codable, Equatable {
    var id: String
    var sendBy: String
    var text: String?
    var ts: Date
    var parent: String
    var widgetId: String?
    var threadId: String?
}

struct ChatView: View {
    @State var spaceId: String
    @StateObject private var viewModel = ChatViewModel()
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    
    @State var threadId: String = ""
    @State private var threadIdChangedTime: Date = Date()
    @Environment(\.dismiss) var dismissScreen
    
    
    var body: some View {
    
            ScrollViewReader { proxy in
                
                List {
                    Spacer()
                        .frame(height: 30)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .id("top")
                        .listRowBackground(Color.clear)
                    
                    if let widget = canvasViewModel.replyWidget {
                        MediaView(widget: widget, spaceId: spaceId)
                            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                            .cornerRadius(CORNER_RADIUS)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .id("replyWidget")
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .rotationEffect(.degrees(180))
                            .padding(.bottom, 3)
                            .listRowBackground(Color.clear)
//                        
//                            .onAppear {
//                                threadId = widget.id.uuidString
//                            }
                        
                    }
                    
                    // Display new messages
                    ForEach(viewModel.messagesFromListener.filter { message in
                        (threadId.isEmpty || message.threadId == threadId) && message.ts > threadIdChangedTime
                    }) { message in
                        
                        ChatBubbleViewBuilder(spaceId: spaceId, message: message, currentUserId: viewModel.user?.id ?? "", threadId: $threadId)
                 
                            .id(message.id)
                            .rotationEffect(.degrees(180))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .padding(.bottom, 3)
                            .blur(radius: canvasViewModel.replyWidget == nil ? 0 : 2)
                            .listRowBackground(Color.clear)
                        //                        .background(.red)
                    }
                    
                    // Display old messages
                    ForEach(viewModel.messages) { message in
                        ChatBubbleViewBuilder(spaceId: spaceId, message: message, currentUserId: viewModel.user?.id ?? "", threadId: $threadId)
                            .id(message.id)
                            .rotationEffect(.degrees(180))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .padding(.bottom, 3)
                            .blur(radius: canvasViewModel.replyWidget == nil ? 0 : 2)
                            .listRowBackground(Color.clear)
                        
                        if message.id == viewModel.messages.last?.id {
                            if viewModel.hasMoreMessages {
                                ProgressView()
                                    .onAppear {
                                        if threadId == "" {
                                            viewModel.getOldMessages(spaceId: spaceId)
                                        } else {
                                            viewModel.getThreadMessages(spaceId: spaceId, threadId: threadId)
                                        }
                                    }
                                    .rotationEffect(.degrees(180))
                                    .frame(maxWidth: .infinity)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .padding(.bottom, 3)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        
                    }
                    
                }
                
                .onChange(of: threadId) { _, newValue in
                    threadIdChangedTime = Date()
                    
                    if !newValue.isEmpty {
                        viewModel.removeMessages()
                        viewModel.getThreadMessages(spaceId: spaceId, threadId: newValue)
                    }
                }
         
                
                .onChange(of: canvasViewModel.selectedDetent) { _, newValue in
                    if newValue == .height(50) {
                        threadId = ""
                        viewModel.removeMessages()
                        viewModel.getOldMessages(spaceId: spaceId)
                        viewModel.fetchNewMessages(spaceId: spaceId)
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
                .onChange(of: canvasViewModel.selectedDetent) { _, newValue in
                    if newValue == .height(50) {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        
            .scrollDismissesKeyboard(.interactively)
            .padding(.horizontal)
//            .background(threadId == "" ? Color.clear : Color(UIColor.secondarySystemBackground))
//            .background(
//                Group {
//                    if threadId == "" {
//                        Color.clear
//                    } else {
//                        Color.fromString(name: viewModel.user?.userColor ?? "")
//                            .brightness(0.6)
//                            .opacity(0.3)
//                    }
//                }
//            )
         
            .onTapGesture {
                
                
           
       
             
                withAnimation {
                    canvasViewModel.replyWidget = nil
                  
                    
                    if threadId != "" {
                        
                        threadId = ""
                        viewModel.removeMessages()
                        viewModel.getOldMessages(spaceId: spaceId)
                        viewModel.fetchNewMessages(spaceId: spaceId)
                    } else {
                        
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            
            .overlay(
            
                    Color("customClear")
                        .frame(height: 100)
                        .frame(maxHeight: .infinity, alignment: .top)
             
                
            )
       
            .overlay(
            
                
                MessageField(spaceId: spaceId, threadId: $threadId)
//                    .disabled(canvasViewModel.selectedDetent == .height(50) && canvasViewModel.replyWidget == nil)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .onTapGesture {
                        if canvasViewModel.selectedDetent == .height(50){
                            canvasViewModel.selectedDetent = .large
                        }
                        }
            )
            
            
            
            
            .task {
                try? await viewModel.loadCurrentUser()
                
            }
            
            
            
            
            
       
        
 
    }
  
}

//struct NewChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            NewChatView(spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E", canvasViewModel.replyWidget: .constant(nil), canvasViewModel.selectedDetent: .constant(.large))
//        }
//    }
//}
