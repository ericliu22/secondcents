//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import SwiftUI

struct CalendarWidget: WidgetView {
    
//    @State private var isPresented: Bool = false
    let widget: CanvasWidget // Assuming CanvasWidget is a defined type
//    @StateObject private var viewModel = TextWidgetViewModel()
    
    @State private var userColor: Color = .gray
    
    var body: some View {
        
        ZStack{
            
            Color(UIColor.tertiarySystemFill)
            
            
            VStack{
               
                Color.red
                
                
            }
            .background(Color.white)
            .frame(width: TILE_SIZE, height: TILE_SIZE)
            .cornerRadius(CORNER_RADIUS)
        }
        
        
    }
}
