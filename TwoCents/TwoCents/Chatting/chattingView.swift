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
    
    private var spaceId: String
    @StateObject var messageManager: MessageManager
    private var userUID: String
    
    
    init(spaceId: String) {
        self.spaceId = spaceId
        _messageManager = StateObject(wrappedValue: MessageManager(spaceId: spaceId))
        self.userUID = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        
    }
    
    
    //    let user: DBUser
    
    var body: some View{
        VStack (spacing: 3){
            ForEach(messageManager.messages, id:\.id) {
                message in
                
                /*
                 //other user, texted once
                 if(message.sendBy != "Josh" && message.sendBy != message.parent){
                 messageBubbleLead(message: message)
                 }
                 //other user, texted twice
                 else if(message.sendBy != "Josh" && message.sendBy == message.parent){
                 messageBubbleSameLead(message: message)
                 }
                 //I texted twice
                 else if(message.sendBy == "Josh" && message.sendBy == message.parent){
                 messageBubbleSameTrail(message: message)
                 }
                 //I texted once
                 else if(message.sendBy == "Josh" && message.sendBy != message.parent){
                 messageBubbleTrail(message: message)
                 }
                 */
                
                //Jonathan combined above stucts into one
                
                
                
                
                
                universalMessageBubble(message: message, sentByMe: message.sendBy == userUID, isFirstMsg: message.sendBy != message.parent, spaceId: spaceId)
                
                
                
            }
            
            .frame(maxWidth: .infinity)
        }
        
        //        .padding(.bottom, 60)
        
    }
}



struct chattingView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(spaceId: "87D5AC3A-24D8-4B23-BCC7-E268DBBB036F", replyMode: .constant(false), replyWidget: .constant(nil))
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
    
    @State private var scroll: Bool
    
    
    init(spaceId: String, replyMode: Binding<Bool>, replyWidget: Binding<CanvasWidget?>) {
        self.spaceId = spaceId
        _messageManager = StateObject(wrappedValue: MessageManager(spaceId: spaceId))
        //        self.userColor = .gray
        
        self._replyMode = replyMode
        self._replyWidget = replyWidget
        
        self.scroll = false
        
        
        
    }
    
    
    //
    //    private var spaceId: String
    //    @StateObject  var messagesManager = MessageManager(spaceId: spaceId)
    //    @State var Tapped = false
    
    //check for data to use this boolean
    var body: some View{
        VStack(spacing: 0){
            
            
            ScrollViewReader{ proxy in
                
                
                
                ScrollView{
                    
                    chatStruct(spaceId: spaceId).onAppear(perform: {
                        proxy.scrollTo(messageManager.lastMessageId, anchor: .bottom)
                    })
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
               
                .onChange(of: messageManager.lastMessageId) {
//                    id in proxy.scrollTo(id, anchor: .bottom)
                    
                    scroll = true
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
        
        
        
    }
}



