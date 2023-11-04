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
            customTextField(placeholder: Text("message..."), text: $message)
            Button{
                messagesManager.sendMessages(text: message)
                message=""
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color(.red))
                    .cornerRadius(50)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.lightGray))
        .cornerRadius(50)
        .padding()
    }
}

struct customTextField: View{
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool) -> () = {_ in}
    var commit: () -> () = {}
    
    var body: some View{
        ZStack(alignment: .leading) {
            if text.isEmpty{
                placeholder.opacity(0.5)
            }
            TextField("", text:$text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}
