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
    @State var spaceId: String
    var body: some View{
        VStack(alignment: sentByMe ? .trailing : .leading, spacing: 3){
            
            
            if isFirstMsg && !sentByMe {
                
             
                Text(name)
                    .foregroundStyle(userColor)
                    .font(.caption)
//                    .padding(.leading, 12)
                    .padding(.leading, 6)

                    
            }
            
            if message.text != "" &&  message.text != nil{
                //show text message if text is not nill
                Text(message.text! )
                    .font(.headline)
                    .fontWeight(.regular)
                //                .padding(10)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                
                //                .foregroundStyle(Color(UIColor.label))
                    .foregroundStyle(userColor)
                    .background(.ultraThickMaterial)
                    .background(userColor)
                
                //FOR ASYMETRIC ROUNDING...
                //                .clipShape(chatBubbleShape (sentByMe: sentByMe, isFirstMsg: isFirstMsg))
                //                .clipShape(RoundedRectangle(cornerRadius: 5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                    .frame(maxWidth: 300, alignment: sentByMe ?  .trailing : .leading)
                
            } else {
                
                //show widget message if text is nil
               
                
               
                if viewModel.WidgetMessage != nil {
                                      
                    MediaView(widget: viewModel.WidgetMessage!, spaceId: spaceId)
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                        .cornerRadius(CORNER_RADIUS)
                    
                        .frame(maxWidth: .infinity, alignment: sentByMe ?  .trailing : .leading)
                    
                }

               
            }
            

        }
        .frame(maxWidth: .infinity, alignment: sentByMe ?  .trailing : .leading)
        .task {
            self.name = try! await UserManager.shared.getUser(userId: message.sendBy).name!
            
        
            try? await viewModel.loadUser(userId: message.sendBy)
            withAnimation{
                self.userColor = viewModel.getUserColor(userColor:viewModel.user?.userColor ?? "")
            }
            
            if message.widgetId != nil {
                
                try? await viewModel.loadWidget(spaceId: spaceId , widgetId: message.widgetId!)
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
