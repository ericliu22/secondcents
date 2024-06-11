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






struct chatStruct: View{
    //@TODO: Fix messageManager
    private var spaceId: String
    @ObservedObject var messageManager: MessageManager
    private var userUID: String
    
    
    init(spaceId: String) {
        self.spaceId = spaceId
        
        _messageManager = ObservedObject(wrappedValue: MessageManager(spaceId: spaceId))
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

//originally part of separate file

struct ChatView: View {
    
    //    @StateObject private var viewModel = CanvasPageViewModel()
    
    private var spaceId: String
    //    @State private var userColor: Color
    @StateObject var messageManager: MessageManager
    @Binding private var replyMode: Bool
    
    @Binding private var replyWidget: CanvasWidget?
    
    @State private var position: Message.ID?
    @State private var scroll: Bool
    
    @Binding private var selectedDetent: PresentationDetent
    
    init(spaceId: String, replyMode: Binding<Bool>, replyWidget: Binding<CanvasWidget?>, selectedDetent: Binding<PresentationDetent>) {
        self.spaceId = spaceId
        _messageManager = StateObject(wrappedValue: MessageManager(spaceId: spaceId))
        //        self.userColor = .gray
        
        self._replyMode = replyMode
        self._replyWidget = replyWidget
        
        self.scroll = false
        
        self._selectedDetent = selectedDetent
        
    }
    
    var body: some View{
        VStack(spacing: 0){
            
            
            ScrollViewReader{ proxy in
                
                ScrollView{
                        chatStruct(spaceId: spaceId).onAppear(perform: {
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
                    let index: Int = messageManager.messages.firstIndex(where: {$0.id == position}) ?? 0
                    //Eric: As you can see here the index updates when scrolling
                    print(index)
                    
                    if (index == 0) {
                        //Eric: Here it prints when the users scrolls to the top
                        print("reached the end")
                        messageManager.messageCount += 10
                        messageManager.fetchMoreMessages()
                        
                        
                    }
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



