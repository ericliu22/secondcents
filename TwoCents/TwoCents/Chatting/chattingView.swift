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
        }
        .frame(maxWidth: .infinity)
    }
}

struct chattingView: View {
    var body: some View {
        VStack{
            newChatView()
        }
    }
}

struct chattingView_Previews: PreviewProvider {
    static var previews: some View {
        chattingView()
    }
}

//originally part of separate file

struct newChatView: View {
    @StateObject  var messagesManager = MessageManager()
    @State var Tapped = false
    //check for data to use this boolean
    var body: some View{
        VStack{
            ScrollView{
                LazyVStack{
                    chatStruct()
                    //unwrap data into view
                }
                .padding(5)
                
                
            }.frame(width: Tapped ? 300: 200, height: Tapped ? 700: 200).overlay(RoundedRectangle(cornerRadius:20).stroke(Tapped ? .white : .black, lineWidth: 2))
                .onTapGesture {
                    withAnimation(.spring()){
                        Tapped.toggle()
                    }
                }
            if Tapped{
                MessageField().environmentObject(messagesManager)
            }
        }
        
    }
}
   

