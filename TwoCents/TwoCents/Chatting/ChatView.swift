//
//  NewChatView.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//

import Foundation
import SwiftUI
import UIKit

struct OldMessage: Identifiable, Codable, Equatable {
    var id: String
    var sendBy: String
    var text: String?
    var ts: Date
    var parent: String
    var widgetId: String?
    var threadId: String?
}

struct ChatView: View {
    let spaceId: String
    @State var viewModel: ChatViewModel
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @Environment(AppModel.self) var appModel
    @Environment(\.dismiss) var dismissScreen
    
    init(spaceId: String) {
        self.spaceId = spaceId
        viewModel = ChatViewModel(spaceId: spaceId)
    }
    
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
                            .frame(width: TILE_SIZE, alignment: .trailing)
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
                        (viewModel.threadId.isEmpty || message.threadId == viewModel.threadId) && message.ts > viewModel.threadIdChangedTime
                    }) { message in
                        
                        ChatBubbleViewBuilder(spaceId: spaceId, message: message, currentUserId: appModel.user?.id ?? "")
                 
                            .id(message.id)
                            .rotationEffect(.degrees(180))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .padding(.bottom, 3)
                            .blur(radius: canvasViewModel.replyWidget == nil ? 0 : 2)
                            .listRowBackground(Color.clear)
                            .environment(viewModel)
                        //                        .background(.red)
                    }
                    
                    // Display old messages
                    ForEach(viewModel.messages) { message in
                        ChatBubbleViewBuilder(spaceId: spaceId, message: message, currentUserId: appModel.user?.id ?? "")
                            .id(message.id)
                            .rotationEffect(.degrees(180))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .padding(.bottom, 3)
                            .blur(radius: canvasViewModel.replyWidget == nil ? 0 : 2)
                            .listRowBackground(Color.clear)
                            .environment(viewModel)
                        
                        if message.id == viewModel.messages.last?.id {
                            if viewModel.hasMoreMessages {
                                ProgressView()
                                    .onAppear {
                                        if viewModel.threadId == "" {
                                            viewModel.getOldMessages(spaceId: spaceId)
                                        } else {
                                            viewModel.getThreadMessages(spaceId: spaceId, threadId: viewModel.threadId)
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
                
                .onChange(of: viewModel.threadId) { _, newValue in
                    
                    viewModel.isLoading = true // Start thread change
                    viewModel.threadIdChangedTime = Date()
                    
                    if !newValue.isEmpty {
              
                        viewModel.removeMessages()
                        viewModel.getThreadMessages(spaceId: spaceId, threadId: newValue) { _ in
                            viewModel.isLoading = false // End thread change
                                          }
                    
                        
                    }
                }
         
                
                .onChange(of: canvasViewModel.selectedDetent) { _, newValue in
                    if newValue == .height(50) {
                        viewModel.threadId = ""
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
//                        Color.fromString(name: appModel.user?.userColor ?? "")
//                            .brightness(0.6)
//                            .opacity(0.3)
//                    }
//                }
//            )
         
            .onTapGesture {
                
                
                if !viewModel.isLoading{
                    
                  
                    withAnimation {
                        canvasViewModel.replyWidget = nil
                        
                        
                        if viewModel.threadId != "" {
                            
                            viewModel.threadId = ""
                            viewModel.removeMessages()
                            viewModel.getOldMessages(spaceId: spaceId)
                            viewModel.fetchNewMessages(spaceId: spaceId)
                            
                        } else {
                            
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                
                
            }
            
//            .overlay(
//                Group {
//                    if #available(iOS 18, *) {
//                        Color.clear
//                            .frame(height: 100)
//                            .frame(maxHeight: .infinity, alignment: .top)
//                            .contentShape(Rectangle())
//                    } else {
//                        Color("customClear")
//                            .frame(height: 100)
//                            .frame(maxHeight: .infinity, alignment: .top)
//                    }
//                }
//            )

       
            .overlay(
            
                
                MessageField()
                //                    .disabled(canvasViewModel.selectedDetent == .height(50) && canvasViewModel.replyWidget == nil)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .disabled(canvasViewModel.selectedDetent == .height(50))
                    .onTapGesture {
                        if canvasViewModel.selectedDetent == .height(50){
                            canvasViewModel.selectedDetent = .large
                        }
                    }
                    .environment(viewModel)
            )
            
            
            
            
            
       
        
 
    }
  
}

//struct NewChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            NewChatView(spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E", canvasViewModel.replyWidget: .constant(nil), canvasViewModel.selectedDetent: .constant(.large))
//        }
//    }
//}
