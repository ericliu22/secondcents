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
    
    
    var body: some View{
        VStack(alignment: sentByMe ? .trailing : .leading){
            
            
            if isFirstMsg {
                Text(message.sendBy)
                    .foregroundStyle(.purple)
                    .font(.headline)
            }
            
            
            Text(message.text)
                .font(.headline)
                .fontWeight(.regular)
            
                .padding(.horizontal,5)
                .padding(.vertical,2.5)
            
            
                .background(.regularMaterial)
                .background(.purple)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity, alignment: sentByMe ?  .trailing : .leading)
    }
}
