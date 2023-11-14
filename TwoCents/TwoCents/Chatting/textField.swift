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
        HStack {
//            customTextField(placeholder: Text("message..."), text: $message)
       
            TextField("Message", text: $message, axis: .vertical)
                .lineLimit(0...5)
                .padding(.leading, nil)
                
         
           
          
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
            
     
            
            
        }
//        .padding(.horizontal)
//        .padding(.vertical, 10)
        .padding(.vertical, 5)
        .background(.regularMaterial)
        .background(.purple)
        .cornerRadius(20)
        
//        .padding(.bottom, nil)
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
