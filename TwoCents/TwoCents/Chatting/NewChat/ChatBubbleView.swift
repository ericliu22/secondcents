//
//  ChatBubbleView.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//

import SwiftUI

struct ChatBubbleView: View {
    
    let message: Message
    
    let sentByMe: Bool
    let isFirstMsg: Bool
    
    let name: String
    
    let userColor: Color
    
    let widget: CanvasWidget?
    let spaceId: String
    
    @StateObject private var viewModel = ChattingViewModel()
    @State private var loaded: Bool = false
    @State private var dragOffset: CGSize = .zero
    @Binding var threadId: String
    
    
    @Binding var activeSheet: sheetTypesCanvasPage?
    @Binding var activeWidget: CanvasWidget?
    var body: some View {
        
            
            
            VStack(alignment: sentByMe ? .trailing : .leading, spacing: 3) {
                
                if isFirstMsg {
                    Text(name)
                        .foregroundStyle(userColor)
                        .font(.caption)
                        .padding(sentByMe ? .trailing : .leading, 6)
                        .padding(.top, 3)
                }
                
                
                if let text = message.text, !text.isEmpty {
                    Text(text)
                        .font(.headline)
                        .fontWeight(.regular)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(userColor)
                        .background(.ultraThickMaterial)
                        .background(userColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(maxWidth: 300, alignment: sentByMe ? .trailing : .leading)
                }
                
                
                
                
                if let widget = widget {
                    MediaView(widget: widget, spaceId: spaceId, activeSheet: $activeSheet, activeWidget: $activeWidget)
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                        .cornerRadius(CORNER_RADIUS)
                        .frame(maxWidth: .infinity, minHeight: TILE_SIZE, alignment: sentByMe ? .trailing : .leading)
                }
            }
            
      
            
    
        .offset(x: dragOffset.width, y: 0)
        
        .background(
            
         
                
                Image(systemName: "arrowshape.turn.up.left.fill")
                    .foregroundStyle(userColor)
                    .symbolEffect(.bounce.up.byLayer, value: abs(dragOffset.width) > 35)
                    .font(.headline)
                
                    .opacity(dragOffset.width == 0 ? 0 : 1)
                    .animation(.easeInOut, value: dragOffset.width)
                    .frame(maxWidth: .infinity, alignment: sentByMe ? .trailing : .leading)
                    .padding(.horizontal, 5)
                
                    .offset(y: isFirstMsg ?  10 : 0)
          

        )
        

    
        .frame(maxWidth: .infinity, alignment: sentByMe ? .trailing : .leading)
        .gesture(
            DragGesture(minimumDistance: 25, coordinateSpace: .scrollView)
                .onChanged { value in

                    if threadId == ""{
                        let isDraggingLeft = sentByMe && value.translation.width < 0 && value.translation.width > -50
                        let isDraggingRight = !sentByMe && value.translation.width > 0 && value.translation.width < 50

                        if isDraggingLeft || isDraggingRight {
                            dragOffset = value.translation
                            
                            if abs(value.translation.width) > 35 {
                                //haptic!
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                        }
                        
                        
                    }
                }
                .onEnded { value in
                    let isDraggingLeft = sentByMe && value.translation.width < 0
                    let isDraggingRight = !sentByMe && value.translation.width > 0 


                    if (isDraggingLeft || isDraggingRight) && abs(value.translation.width) > 35 {
                        
                        if let messageThreadId = message.threadId, threadId == ""{
                            print("the msg u swiped on's id is \(messageThreadId)")
                            
                            if !messageThreadId.isEmpty{
                              
                                //if the msg ur replying to has a thread id, use the same one
                                threadId = messageThreadId
                            }  else {
                                //if msg ur replying to doesnt have thread id, use it (the root)'s id
                                
                                threadId = message.id
                            }
                            
                            
                     
                        }
                        
                        
                       
                    }
                    dragOffset = .zero
                }
        )

    }
}
