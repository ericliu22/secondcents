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
                MediaView(widget: widget, spaceId: spaceId)
                    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                    .cornerRadius(CORNER_RADIUS)
                    .frame(maxWidth: .infinity, minHeight: TILE_SIZE, alignment: sentByMe ? .trailing : .leading)
            }
        }
        .offset(x: dragOffset.width, y: 0)
        .frame(maxWidth: .infinity, alignment: sentByMe ? .trailing : .leading)
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .scrollView)
                .onChanged { value in
                    let horizontalThreshold: CGFloat = 10
                    let isHorizontalDrag = abs(value.translation.width) > horizontalThreshold && abs(value.translation.height) < horizontalThreshold

                    if isHorizontalDrag {
                        let isDraggingLeft = sentByMe && value.translation.width < 0 && value.translation.width > -100
                        let isDraggingRight = !sentByMe && value.translation.width > 0 && value.translation.width < 100

                        if isDraggingLeft || isDraggingRight {
                            dragOffset = value.translation
                        }
                    }
                }
                .onEnded { value in
                    let horizontalThreshold: CGFloat = 10
                    let isHorizontalDrag = abs(value.translation.width) > horizontalThreshold && abs(value.translation.height) < horizontalThreshold

                    if isHorizontalDrag && abs(value.translation.width) > 100 {
                        
                        if let messageThreadId = message.threadId {
                            print("the msg u swiped on's id is \(messageThreadId)")
                            
                            if !messageThreadId.isEmpty{
                              
                                //if the msg ur replying to has a thread id, use the same one
                                threadId = messageThreadId
                            }  else {
                                //if msg ur replying to doesnt have thread id, use it (the root)'s id
                                
                                threadId = message.id
                            }
                            
                            
                            //haptic!
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                        
                        
                       
                    }
                    dragOffset = .zero
                }
        )

    }
}
