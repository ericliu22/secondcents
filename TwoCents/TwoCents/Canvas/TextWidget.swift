//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI

func textWidget(widget: CanvasWidget, inputColor: Color) -> AnyView {
    @State var isPresented: Bool = false
    
    
    
    
    
    
    assert(widget.media == .text)
    @State var inputText: String = ""
    
//    @State var inputColor: Color
    
    return AnyView(
        
        
        Text(widget.textString ?? "")
            .multilineTextAlignment(.leading)
            .font(.custom("LuckiestGuy-Regular", size: 24, relativeTo: .headline))
            .foregroundColor(inputColor)
            .frame(width: widget.width, height: widget.height)
            .background(.thickMaterial)
            .task {
                
                
//                user = loadUser(userId: widget.userId)
//               user = loadUser(userId: widget.userId)
//                getUserColor(userColor: user?.userColor)
               
            }
//            .foregroundColor()
            
        
   
    )//AnyView
}


func getUserColor(userColor: String) -> Color{

    switch userColor {
        
    case "red":
        return Color.red
    case "orange":
        return Color.orange
    case "yellow":
        return Color.yellow
    case "green":
        return Color.green
    case "mint":
        return Color.mint
    case "teal":
        return Color.teal
    case "cyan":
        return Color.cyan
    case "blue":
        return Color.blue
    case "indigo":
        return Color.indigo
    case "purple":
        return Color.purple
    case "pink":
        return Color.pink
    case "brown":
        return Color.brown
    default:
        return Color.gray
    }
    
    
    
}





func loadUser(userId: String) async throws -> DBUser {
 
    return try await UserManager.shared.getUser(userId: userId)
}
