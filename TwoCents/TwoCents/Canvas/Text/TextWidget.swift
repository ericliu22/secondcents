//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import SwiftUI

struct TextWidget: WidgetView {
    
    @State private var isPresented: Bool = false
    let widget: CanvasWidget // Assuming CanvasWidget is a defined type
    @StateObject private var viewModel = TextWidgetViewModel()
    
    @State private var userColor: Color = .gray
    
    
   
    
    
    var body: some View {
        Text(widget.textString ?? "")
            .multilineTextAlignment(.leading)
            .font(.custom("LuckiestGuy-Regular", size: 24, relativeTo: .headline))
            .padding(5)
            .minimumScaleFactor(0.8)
            .frame(width: widget.width, height: widget.height)
            .background(.ultraThickMaterial)
            .background(userColor)
            .foregroundColor(userColor)
            .task {
                try? await viewModel.loadUser(userId: widget.userId)
                
                
                
                withAnimation{
                    self.userColor = viewModel.getUserColor(userColor:viewModel.user?.userColor ?? "")
                }
                
            }
        
        
            
        
        
        
    }
}
