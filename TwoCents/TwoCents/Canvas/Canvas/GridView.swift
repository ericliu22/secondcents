//
//  GridView.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/11.
//

import Foundation
import SwiftUI

extension CanvasPage {
    
     func GridView() -> some View {
            ForEach(canvasWidgets, id:\.id) { widget in
                //main widget
                MediaView(widget: widget, spaceId: spaceId)
                    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                    .cornerRadius(CORNER_RADIUS)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 4)
                    .frame(
                        width: TILE_SIZE,
                        height: TILE_SIZE
                    )
                    .position(x: widget.x ??  FRAME_SIZE/2, y: widget.y ?? FRAME_SIZE/2)
                //clickable area/outline when clicked
                    .overlay(
                        RoundedRectangle(cornerRadius: CORNER_RADIUS)
                            .strokeBorder(viewModel.selectedWidget == widget ? Color.secondary : .clear, lineWidth: 3)
                            .contentShape(RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                            .frame(width: TILE_SIZE, height: TILE_SIZE)
                            .position(x: widget.x ??  FRAME_SIZE/2, y: widget.y ?? FRAME_SIZE/2)
                            .cornerRadius(CORNER_RADIUS)
                            //on double tap
                            .onTapGesture(count: 2, perform: {widgetDoubleTap(widget: widget)})
                            //on single tap
                            .onTapGesture(count: 1, perform: {widgetSingleTap(widget: widget)})
                    )


                //full name below widget
                    .overlay(content: {
                        Text(widgetDoubleTapped ? fullName : "" )
                            .position(x: widget.x ??  FRAME_SIZE/2, y: widget.y ?? FRAME_SIZE/2)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .offset(y:90)
                    })
                    .blur(radius: widgetDoubleTapped && viewModel.selectedWidget != widget ? 20 : 0)
//                    .scaleEffect(widgetDoubleTapped && viewModel.selectedWidget == widget ? 1.05 : 1)
//                
                    .animation(.spring)
                    //emoji react MENU
                    .overlay( alignment: .top, content: {
                        if widgetDoubleTapped && viewModel.selectedWidget == widget {
                            EmojiReactionsView(spaceId: spaceId, widget: widget)
                                .offset(y:-110)
                                .position(x: widget.x ??  FRAME_SIZE/2, y: widget.y ?? FRAME_SIZE/2)

                        }
                    })
                    .overlay(content: {
                        viewModel.selectedWidget == nil/* && draggingItem == nil */?
                        EmojiCountOverlayView(spaceId: spaceId, widget: widget)
                            .offset(y: TILE_SIZE/2)
                            .position(x: widget.x ??  FRAME_SIZE/2, y: widget.y ?? FRAME_SIZE/2)

                        : nil
                    })
                    .draggable(widget) {
                        MediaView(widget: widget, spaceId: spaceId)
                            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                            .frame(
                                width: TILE_SIZE,
                                height: TILE_SIZE
                            )
                            .onAppear{
                                draggingItem = widget
                            }
                    }
                
            }
    }
    
    func widgetDoubleTap(widget: CanvasWidget) {
        if viewModel.selectedWidget != widget || !widgetDoubleTapped {
            //select
            
            viewModel.selectedWidget = widget
            widgetDoubleTapped = true
            //                                    showSheet = false
            //                                    showNewWidgetView = false
            activeSheet = nil
            
            //haptic
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        } else {
            //deselect
            viewModel.selectedWidget = nil
            widgetDoubleTapped = false
            //                                    showSheet = true
            //                                    showNewWidgetView = false
            activeSheet = .chat
        }
        Task {
            do {
                let user = try await UserManager.shared.getUser(userId: widget.userId)
                if let name = user.name {
                    fullName = name
                } else {
                    // Handle the case where name is nil
                    print("User name is nil")
                    
                }
            } catch {
                // Handle the error
                print("Failed to get user: \(error.localizedDescription)")
            }
        }
    }
    
    func widgetSingleTap(widget: CanvasWidget) {
        
        if widgetDoubleTapped{
            //deselect
            viewModel.selectedWidget = nil
            widgetDoubleTapped = false
            //                                    showSheet = true
            //                                    showNewWidgetView = false
            activeSheet = .chat
        } else {
            
            //haptic
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            
            switch widget.media {
            case .poll:
                activeWidget = widget
                activeSheet =  .poll
            case .todo:
                activeWidget = widget
                activeSheet = .todo
            case .map:
                if let location = widget.location {
                    viewModel.openMapsApp(location: location)
                }
            case .link:
                if let url = widget.mediaURL {
                    viewModel.openLink(url: url)
                }
            default:
                break
            }
        }
    }
    
}
