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
    
    @StateObject private var viewModel = ChattingViewModel()
    @State private var userColor: Color = .gray

    var body: some View{
        VStack(alignment: sentByMe ? .trailing : .leading, spacing: 3){
            
            
            if isFirstMsg && !sentByMe {
                
             
                Text(name)
                    .foregroundStyle(userColor)
                    .font(.caption)
//                    .padding(.leading, 12)
                
                    
            }
            
            
            Text(message.text)
                .font(.headline)
                .fontWeight(.regular)
//                .padding(10)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
      
                .foregroundStyle(Color(UIColor.label))
                .background(.ultraThickMaterial)
                .background(userColor)
            
                
                .clipShape(chatBubbleShape (sentByMe: sentByMe, isFirstMsg: isFirstMsg))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(maxWidth: 300, alignment: sentByMe ?  .trailing : .leading)
            
            
            

        }
        .frame(maxWidth: .infinity, alignment: sentByMe ?  .trailing : .leading)
        .task {
            self.name = try! await UserManager.shared.getUser(userId: message.sendBy).name!
            
        
            try? await viewModel.loadUser(userId: message.sendBy)
            withAnimation{
                self.userColor = viewModel.getUserColor(userColor:viewModel.user?.userColor ?? "")
            }
            
   
            //            print (userColor)
            
        }
    }
}


struct chatBubbleShape: Shape {
    
    let sentByMe: Bool
    var isFirstMsg: Bool
    
    
    func path(in rect: CGRect) -> Path {
      
            let path = !isFirstMsg 
        ? UIBezierPath(roundedRect: rect, byRoundingCorners: [ sentByMe ? .topLeft : .topRight,sentByMe ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width:12, height: 12))
        : UIBezierPath(roundedRect: rect, byRoundingCorners: [ .topLeft , .topRight,sentByMe ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width:12, height: 12))
            
  
        
        
        return Path(path.cgPath)
    }
    
}
