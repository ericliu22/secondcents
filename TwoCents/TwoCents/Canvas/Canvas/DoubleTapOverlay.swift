//
//  DoubleTapOverlay.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/11.
//

import Foundation
import SwiftUI

extension CanvasPage {
    
    func widgetButton(for media: Media) -> some View {
        switch media {
        case .poll:
            return Button(action: {
                activeWidget = viewModel.selectedWidget
                viewModel.selectedWidget = nil
                widgetDoubleTapped = false
                activeSheet =  .poll
            }, label: {
                Image(systemName: "list.clipboard")
                    .foregroundColor(Color(UIColor.label))
                    .font(.title3)
                    .padding(.horizontal, 5)
            }).eraseToAnyView()
            
            
        case .todo:
            return Button(action: {
                activeWidget = viewModel.selectedWidget
                viewModel.selectedWidget = nil
                widgetDoubleTapped = false
                activeSheet = .todo
            }, label: {
                Image(systemName: "checklist")
                    .foregroundColor(Color(UIColor.label))
                    .font(.title3)
                    .padding(.horizontal, 5)
            }).eraseToAnyView()

        case .map:
            return Button(action: {
                if let location = viewModel.selectedWidget?.location {
                    viewModel.openMapsApp(location: location)
                }
                viewModel.selectedWidget = nil
                widgetDoubleTapped = false
            }, label: {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Color(UIColor.label))
                    .padding(.horizontal, 5)
            }).eraseToAnyView()
        case .link:
            return Button(action:{
                if let url = viewModel.selectedWidget?.mediaURL {
                    viewModel.openLink(url: url)
                }
                
                viewModel.selectedWidget = nil
                widgetDoubleTapped = false
            }, label: {
                Image(systemName: "link")
                    .foregroundColor(Color(UIColor.label))
                    .padding(.horizontal, 5)
            }).eraseToAnyView()
        default:
            return EmptyView().eraseToAnyView()
        }
    }
    
    func doubleTapOverlay() -> some View {
        viewModel.selectedWidget != nil ? VStack {
            EmojiCountHeaderView(spaceId: spaceId, widget: viewModel.selectedWidget!)
            Spacer()
            HStack(spacing: 5) { // Increase spacing between buttons
                
                
                if let selectedWidget = viewModel.selectedWidget {
                       widgetButton(for: selectedWidget.media)
                   } else {
                       EmptyView()
                   }

                // Reply button
                Button(action: {
                    
                    replyWidget = viewModel.selectedWidget
                    viewModel.selectedWidget = nil
                    widgetDoubleTapped = false
                    activeSheet = .chat
                }, label: {
                    Image(systemName: "arrowshape.turn.up.left")
                        .foregroundColor(Color(UIColor.label))
                        .font(.title3)
                        .padding(.horizontal, 5)
                })
                
                
                
                // Delete button
                Button(action: {
                    if let selectedWidget = viewModel.selectedWidget, let index = canvasWidgets.firstIndex(of: selectedWidget)  {
                        canvasWidgets.remove(at: index)
                        SpaceManager.shared.removeWidget(spaceId: spaceId, widget: selectedWidget)
                        
                        //delete specific widget items (in their own folders)
                        
                        switch selectedWidget.media {
                            
                        case .poll:
                            deletePoll(spaceId: spaceId, pollId: selectedWidget.id.uuidString)
                        case .todo:
                            deleteTodoList(spaceId: spaceId, todoId: selectedWidget.id.uuidString)
                            
                        default: 
                            break
                            
                        }
                   
                    }
                    viewModel.selectedWidget = nil
                    widgetDoubleTapped = false
                    activeSheet = .chat
                }, label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                        .padding(.horizontal, 5) // Increase padding
                     
                })
                
                
                
                
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10) // Add vertical padding
            .background(Color(UIColor.systemBackground), in: Capsule())
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 4)
        }
        
        .frame(maxHeight: .infinity, alignment: .bottom)
        : nil
    }

}
