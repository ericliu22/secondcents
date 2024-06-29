//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import SwiftUI

struct EventWidget: WidgetView {
    
//    @State private var isPresented: Bool = false
    let widget: CanvasWidget // Assuming CanvasWidget is a defined type
//    @StateObject private var viewModel = TextWidgetViewModel()
    
//    @State private var userColor: Color = .gray
    
    @State private var todoList = ["Alc", "Mac and cheese"]
    
    var body: some View {
        ZStack{
            
            Color(UIColor.tertiarySystemFill)
            
            
            VStack(alignment: .leading, spacing:0){
                
                Text("Boys Night")
                    .font(.footnote)
                    .foregroundColor(Color.accentColor)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                Text("September 9")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
             
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                    .frame(height: 4)
                
                ForEach(todoList, id: \.self) {item in
                    
                    
                    HStack{
                        
                        Color.red
                            .frame(width: 3, height: 10)
                            .cornerRadius(3)
                        
                        Text(item)
                            .font(.caption)
                            .foregroundColor(Color(UIColor.label))
                        
                    }
                    
                }
                
                
                Spacer()
                
                
            }
            
           

            .padding(16)
            .frame(width: TILE_SIZE, height: TILE_SIZE)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(CORNER_RADIUS)

            
            
            
    
        }
    }
}
