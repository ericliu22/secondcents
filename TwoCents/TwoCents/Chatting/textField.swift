//
//  textField.swift
//  TwoCents
//
//  Created by Joshua Shen on 9/22/23.
//

import Foundation
import SwiftUI
import UIKit

struct MessageField: View{
    @EnvironmentObject var messagesManager: MessageManager
    @State private var message = ""
    
    
    @State private var userColor: Color = .gray
    
    @StateObject private var viewModel = ChattingViewModel()
    
    @Binding  var replyMode: Bool
    @Binding  var replyWidget: CanvasWidget?
    
    
    @FocusState private var isFocused: Bool
    
    var body: some View{
//        ZStack (alignment: .bottomTrailing){
            
        
        ZStack (alignment: .bottomTrailing){
            
                
                TextField("Message", text: $message, axis: .vertical)
                    .lineLimit(0...5)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .padding(.trailing, 48)
//                    .clipShape(Capsule())
                    .font(.headline)
                    .fontWeight(.regular)
                    .focused($isFocused)
                    .onAppear(perform: {
                        isFocused = replyMode
                        
                    })
                    
                    
                    
                Button{
                    
                    messagesManager.sendMessages(text: message, widget: replyWidget)
                    message = ""
                    
                    replyWidget = nil
                    withAnimation{
                        replyMode = false
                        
                    }

                } label: {
                    Image(systemName: "arrow.up")
                        .font(.headline )
                        .frame(width: 30, height: 30, alignment: .center)
             
                        .foregroundColor(message.isEmpty && !replyMode  ? .clear : .white)
                        .background(message.isEmpty && !replyMode ? .clear : userColor)
                        .clipShape(Circle())
                        .padding(.bottom, 4)
                     
                    
                    
                }
                .clipped()
                .buttonStyle(PlainButtonStyle())
                .disabled(message.isEmpty && !replyMode)
                .padding(.trailing, 5)
                
  
                

                
            }
        .foregroundStyle(Color(UIColor.label))
            .background(.regularMaterial)
//            .background(userColor)
            .cornerRadius(20)
            .padding(.horizontal)
            .padding(.top, 5)
//            .background(.thickMaterial)
       
            .frame(minHeight:50, alignment: .center)
            
            
            .task{
                
                try? await viewModel.loadCurrentUser()
                self.userColor = viewModel.getUserColor(userColor:viewModel.user?.userColor ?? "")
    //            print (userColor)
            }
        
        
     
//        }
    }

}
