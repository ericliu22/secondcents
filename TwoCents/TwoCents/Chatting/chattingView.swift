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
    @StateObject var messageManager = MessageManager()
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
            universalMessageBubble(message: message, sentByMe: message.sendBy == "Josh", isFirstMsg: message.sendBy != message.parent)
            
            
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 60)
        
    }
}



struct chattingView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

//originally part of separate file

struct ChatView: View {
    @StateObject  var messagesManager = MessageManager()
    @State var Tapped = false
    //check for data to use this boolean
    var body: some View{
        
        VStack(spacing: 0){
            ScrollViewReader{ proxy in
            ScrollView{
                
                chatStruct().onAppear(perform: {
                            proxy.scrollTo(messagesManager.lastMessageId, anchor: .bottom)
                        })
                
            }
            .frame(width: Tapped ? .infinity: TILE_SIZE, height: Tapped ? .infinity: TILE_SIZE)
            .onChange(of: messagesManager.lastMessageId) {
                    id in proxy.scrollTo(id, anchor: .bottom)
                }
            .overlay(
                RoundedRectangle(cornerRadius:20)
                    .stroke(Tapped ? .clear : .black, lineWidth: 5)
//                    .ignoresSafeArea()
            )
            .onTapGesture {
                withAnimation(.spring()){
                    Tapped.toggle()
                }
                proxy.scrollTo(messagesManager.lastMessageId, anchor: .bottom)
            }
            }
            .padding(.horizontal)
            
            
            
            
            if Tapped{
                MessageField().environmentObject(messagesManager)
                
            }
        }
        
        .scrollIndicators(.hidden)
        
        
        
    }
}



