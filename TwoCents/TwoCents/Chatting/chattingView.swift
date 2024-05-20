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
    var text: String
    var ts: Date
    var parent: String
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
   
            
            
         
            
            universalMessageBubble(message: message, sentByMe: message.sendBy == userUID, isFirstMsg: message.sendBy != message.parent)
            
            
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 60)
        
    }
}



struct chattingView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(spaceId: "87D5AC3A-24D8-4B23-BCC7-E268DBBB036F")
    }
}

//originally part of separate file

struct ChatView: View {
    
    private var spaceId: String
    @StateObject var messageManager: MessageManager
   
    init(spaceId: String) {
        self.spaceId = spaceId
        _messageManager = StateObject(wrappedValue: MessageManager(spaceId: spaceId))
      
 
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
                
            }
//            .frame(width: Tapped ? .infinity: TILE_SIZE, height: Tapped ? .infinity: TILE_SIZE)
            .onChange(of: messageManager.lastMessageId) {
                    id in proxy.scrollTo(id, anchor: .bottom)
                }
//            .overlay(
//                RoundedRectangle(cornerRadius:20)
//                    .stroke(Tapped ? .clear : .black, lineWidth: 5)
////                    .ignoresSafeArea()
//            )
//            .onTapGesture {
//                withAnimation(.spring()){
//                    Tapped.toggle()
//                }
//                proxy.scrollTo(messagesManager.lastMessageId, anchor: .bottom)
//            }
            }
            .padding(.horizontal)
            
            
            
            
//            if Tapped{
                MessageField().environmentObject(messageManager)
                
//            }
        }
        
        .scrollIndicators(.hidden)
        
        
        
    }
}



