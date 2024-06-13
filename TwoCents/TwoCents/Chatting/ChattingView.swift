//
//  chattingView.swift
//  TwoCents
//
//  Created by Joshua Shen on 8/12/23.
//

import Foundation
import SwiftUI
import UIKit

struct Message: Identifiable, Codable {
    var id: String
    var sendBy: String
    var text: String?
    var ts: Date
    var parent: String
    var widgetId: String?
}






struct ChatStruct: View{
    private var spaceId: String
    @ObservedObject var messageManager: MessageManager
    private var userUID: String
    
    
    init(spaceId: String, messageManager: MessageManager) {
        self.spaceId = spaceId
        self.messageManager = messageManager
        self.userUID = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        
    }
    
    
    //    let user: DBUser
    
    var body: some View{
        VStack (spacing: 3){
            //Eric: The ForEach doesn't update here even though messageManager.messages changed
            //Maybe look into setting messageManager as ObservableObject instead of StateObject?
            ForEach(messageManager.messages, id:\.id) {
                message in
               
                universalMessageBubble(message: message, sentByMe: message.sendBy == userUID, isFirstMsg: message.sendBy != message.parent, spaceId: spaceId)
                
                
            }
            
            .frame(maxWidth: .infinity)
        }
        
        //        .padding(.bottom, 60)
        
    }
}

struct chattingView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(spaceId: "87D5AC3A-24D8-4B23-BCC7-E268DBBB036F", replyMode: .constant(false), replyWidget: .constant(nil), selectedDetent: .constant(.medium))
    }
}

struct ChatView: View {
    
    //    @StateObject private var viewModel = CanvasPageViewModel()
    
    private var spaceId: String
    //    @State private var userColor: Color
    @ObservedObject var messageManager: MessageManager
    
    @Binding private var replyMode: Bool
    @Binding private var replyWidget: CanvasWidget?
    
    @State private var scrollViewContentOffset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @State private var position: Message.ID?
    @State private var scroll: Bool
    @State private var fetching: Bool = false
    
    @Binding private var selectedDetent: PresentationDetent
    
    init(spaceId: String, replyMode: Binding<Bool>, replyWidget: Binding<CanvasWidget?>, selectedDetent: Binding<PresentationDetent>) {
        self.spaceId = spaceId
        self.messageManager = MessageManager(spaceId: spaceId)
        self._replyMode = replyMode
        self._replyWidget = replyWidget
        
        self.scroll = false
        
        self._selectedDetent = selectedDetent
        
    }
    
    func callFetch(proxy: ScrollViewProxy) {
        if (messageManager.limitReached) {
            return
        }

        guard let index: Int = messageManager.messages.firstIndex(where: {$0.id == position}) else {
            return
        }
        if (index == 0) {
            Task {
                do {try await Task.sleep(nanoseconds: 100000000)}
                catch {return}
                messageManager.fetchMoreMessages()
                if (messageManager.limitReached) {
                    return
                }
                proxy.scrollTo(messageManager.messages[9].id, anchor: .top)
            }
        }
    }
    
    var body: some View{
        VStack(spacing: 0){
            
            
            ScrollViewReader{ proxy in
                
                ScrollView{
                        ChatStruct(spaceId: spaceId, messageManager: messageManager).onAppear(perform: {
                            proxy.scrollTo(messageManager.lastMessageId, anchor: .bottom)
                        })
                        .scrollTargetLayout()
                        .blur(radius: replyMode ? 2 : 0)
                        
                        if replyWidget != nil && replyMode {
                            
                            getMediaView(widget: replyWidget!, spaceId: spaceId)
                                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                                .cornerRadius(CORNER_RADIUS)
                            
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .id("replyWidget")
                        }
                }
                .onTapGesture {
                    withAnimation {
                        replyMode = false
                        replyWidget = nil
                    }
                }
                .onChange(of: position) {
                    callFetch(proxy: proxy)
                }
                .onChange(of: messageManager.lastMessageId) {
//                    id in proxy.scrollTo(id, anchor: .bottom)
                    
                    scroll = true
                }
                .onChange(of: selectedDetent) {
//                    id in proxy.scrollTo(id, anchor: .bottom)
                    
                    scroll = true
                    
                    if selectedDetent == .height(50) {
                        
                        replyMode = false
                        replyWidget = nil
                        
                    }
                }
                
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidChangeFrameNotification)) { _ in
//                    if replyWidget != nil {
//                        proxy.scrollTo("replyWidget", anchor: .bottom)
//                    }
                    scroll = true
                }
                
                .onChange(of: scroll) {
                    if replyMode {
                        proxy.scrollTo("replyWidget", anchor: .bottom)
                    } else {
                        proxy.scrollTo( messageManager.lastMessageId, anchor: .bottom)
                    }
                    
                    scroll = false
                }
   
                
            }
            .padding(.top)
            .padding(.horizontal)
            MessageField( replyMode: $replyMode, replyWidget: $replyWidget).environmentObject(messageManager)
              
        }
        .onTapGesture {
            scroll = true
        }
        
        .scrollIndicators(.hidden)
        .scrollPosition(id: $position)
    }
}



