//
//  NewMessageField.swift
//  TwoCents
//
//  Created by jonathan on 7/3/24.
//

import SwiftUI

struct NewMessageField: View {
    
    @State private var message = ""
    @FocusState private var isFocused: Bool
    

    @Binding  var replyWidget: CanvasWidget?
    
    
    @State private var userColor: Color = .gray
    
    @StateObject private var viewModel = NewMessageFieldViewModel()
    @State var spaceId: String
    
    
    @Binding var threadId: String
    
    var body: some View {
        
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
                    isFocused = replyWidget != nil
                    
                })
            Button{
                print("HERE")
                print(threadId)
                viewModel.sendMessages(text: message, widget: replyWidget, spaceId: spaceId, threadId: threadId)
                message = ""
                replyWidget = nil
                
                threadId = ""
                
            } label: {
                Image(systemName: "arrow.up")
                    .font(.headline )
                    .frame(width: 30, height: 30, alignment: .center)
                
                    .foregroundColor(message.isEmpty && replyWidget == nil  ? .clear : .white)
                    .background(message.isEmpty && replyWidget == nil ? .clear : userColor)
                    .clipShape(Circle())
                    .padding(.bottom, 4)
            }
            .clipped()
            .buttonStyle(PlainButtonStyle())
            .disabled(message.isEmpty && replyWidget == nil)
            .padding(.trailing, 5)
            
        }
        .foregroundStyle(Color(UIColor.label))
        .background(.regularMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 5)
        .frame(minHeight:50, alignment: .center)
        .task{
            try? await viewModel.loadCurrentUser()
            self.userColor = viewModel.getUserColor(userColor:viewModel.user?.userColor ?? "")
        }
        .background(.clear)
        .onChange(of: threadId) { _ , newValue in
            if newValue != "" {
                isFocused = true
                
                
                print("threadId")
                
                
          
            }
            
            print("changed")
        }
    }

    
    
}

//#Preview {
//    NewMessageField()
//}
