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
    var body: some View{
//        ZStack (alignment: .bottomTrailing){
            
        
        ZStack (alignment: .bottomTrailing){
                //            customTextField(placeholder: Text("message..."), text: $message)
                
                TextField("Message", text: $message, axis: .vertical)
                    .lineLimit(0...5)
//                    .padding(.leading, nil)
//                    .padding(.vertical, 10)
                    .padding(12)
                    .padding(.trailing, 48)
                    .clipShape(Capsule())
                    .font(.subheadline)
                
                
                
//                Spacer()
//                    .frame(width: 60, height: 30)
 
                
                Button{
                    messagesManager.sendMessages(text: message)
                    message = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                    //                    .padding(10)
                    
                }
                .tint(.purple)
                .buttonStyle(.borderedProminent)
                .disabled(message.isEmpty)
                .clipShape(Circle())
                .padding(.horizontal)
                .offset(x: 12, y: -4)
                
               
                
                

                
            }
            .background(.thickMaterial)
            .background(.purple)
            .cornerRadius(20)
            
            
            
            
       
          
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
