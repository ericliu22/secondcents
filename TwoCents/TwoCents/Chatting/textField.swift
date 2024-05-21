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
    
    
    var body: some View{
//        ZStack (alignment: .bottomTrailing){
            
        
        ZStack (alignment: .trailing){
                //            customTextField(placeholder: Text("message..."), text: $message)
                
                TextField("Message", text: $message, axis: .vertical)
                    .lineLimit(0...5)
//                    .padding(.leading, nil)
//                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .padding(.trailing, 48)
//                    .clipShape(Capsule())
                    .font(.headline)
                    .fontWeight(.regular)
                    
                
                
                
//                Spacer()
//                    .frame(width: 60, height: 30)
 
                
                Button{
                    messagesManager.sendMessages(text: message)
                    message = ""
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.headline )
                        .frame(width: 30, height: 30, alignment: .center)
             
                        .foregroundColor(message.isEmpty ? .clear : .white)
                        .background(message.isEmpty ? .clear : userColor)
                        .clipShape(Circle())
                     
                    
                }
                .clipped()
                .buttonStyle(PlainButtonStyle())
                .disabled(message.isEmpty)
                .padding(.trailing, 5)
                
                

                
            }
        .foregroundStyle(Color(UIColor.label))
            .background(.regularMaterial)
//            .background(userColor)
            .cornerRadius(20)
            .padding(.horizontal)
            .padding(.top, 5)
//            .background(.thickMaterial)
       
            .frame(height:50, alignment: .center)
            
            
            .task{
                
                try? await viewModel.loadCurrentUser()
                self.userColor = viewModel.getUserColor(userColor:viewModel.user?.userColor ?? "")
    //            print (userColor)
            }
        
        
     
//        }
    }

}

struct customTextField: View{
//    var placeholder: Text
    @Binding var text: String
//    var editingChanged: (Bool) -> () = {_ in}
//    var commit: () -> () = {}
//    
    var body: some View{
//        ZStack(alignment: .leading) {
//            if text.isEmpty{
//                placeholder.opacity(0.5)
//            }
//            TextField("", text:$text, onEditingChanged: editingChanged, onCommit: commit)
//             
//        }
        
        
        
        TextField("Message", text:$text, axis: .vertical)
            .lineLimit(0...5)
        
        
        
    }
}
