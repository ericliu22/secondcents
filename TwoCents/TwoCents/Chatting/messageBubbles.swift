//
//  MessageBubbles.swift
//  TwoCents
//
//  Created by Joshua Shen on 9/25/23.
//

import Foundation
import UIKit
import SwiftUI

////message bubble leading --> other users
//struct messageBubbleLead: View{
//    var message: Message
//    var body: some View{
//        VStack(alignment:.leading){
//            Text(message.sendBy)
//            Text(message.text)
//                .background(.green)
//                .cornerRadius(30)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
////message bubble leading --> other users, same user texted twice
//struct messageBubbleSameLead: View{
//    var message: Message
//    var body: some View{
//        Text(message.text)
//            .background(.blue)
//            .cornerRadius(30)
//            .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
////message bubble trailing --> the user/self
//struct messageBubbleTrail: View{
//    var message: Message
//    var body: some View{
//        VStack(alignment:.trailing){
//            Text(message.sendBy)
//            Text(message.text)
//                .background(.red)
//                .cornerRadius(30)
//        }
//            .frame(maxWidth: .infinity, alignment: .trailing)
//    }
//}
//
//struct messageBubbleSameTrail: View{
//    var message: Message
//    var body: some View{
//        Text(message.text)
//            .background(.purple)
//            .cornerRadius(30)
//            .frame(maxWidth: .infinity, alignment: .trailing)
//    }
//}
//




//Jonathan combined above stucts into one... if there is an error, ask him



struct universalMessageBubble: View{
    var message: Message
    var sentByMe: Bool
    var isFirstMsg: Bool
    
    
    @State private var name: String = ""
    
   

    var body: some View{
        VStack(alignment: sentByMe ? .trailing : .leading){
            
            
            if isFirstMsg && !sentByMe {
                
             
                Text(name)
                    .foregroundStyle(.green)
                    .font(.caption)
                    .padding(.leading, 10)
                    
            }
            
            
            Text(message.text)
                .font(.headline)
                .fontWeight(.regular)
                .padding(10)
      
                .foregroundStyle(.white)
                . background(.ultraThinMaterial)
                .background(.green)
            
                
                .clipShape(chatBubbleShape (sentByMe: sentByMe))
                .frame(maxWidth: 300, alignment: sentByMe ?  .trailing : .leading)
            
            
            

        }
        .frame(maxWidth: .infinity, alignment: sentByMe ?  .trailing : .leading)
        .task {
            self.name = try! await UserManager.shared.getUser(userId: message.sendBy).name!
        }
    }
}


struct chatBubbleShape: Shape {
    
    let sentByMe: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft,.topRight,sentByMe ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width:16, height: 16))
        
        return Path(path.cgPath)
    }
    
}
