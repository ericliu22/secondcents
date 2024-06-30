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
    
    @State private var todoList = ["Alc", "Ping pong balls"]
    
    var body: some View {
        ZStack{
            
            Color(UIColor.tertiarySystemFill)
                .ignoresSafeArea()
            
            
            
            
            VStack(alignment: .leading, spacing:0){
          
                    
                    //Event Name
                    Text("Boys Night")
                        .font(.footnote)
                        .foregroundColor(Color.accentColor)
                        .fontWeight(.semibold)
                    
                    
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
                
                
                //Date
                Text("Sep 9・4:30PM")
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                Spacer()
                    .frame(height: 3)
                
                
                //todo list
                ForEach(todoList, id: \.self) { item in
                    HStack(spacing: 3) {
                        Color.accentColor
                            .frame(width: 3, height: 12)
                            .cornerRadius(3)
                        
                        Text(item)
                            .font(.caption)
                            .foregroundColor(Color(UIColor.label))
                            .truncationMode(.tail)
                            .lineLimit(1)

                    }
                    .padding(.bottom, 3)
                }
                .padding(.horizontal, 16)
           
                
                HStack(spacing: 3) {
                    Color.secondary
                        .frame(width: 3, height: 12)
                        .cornerRadius(3)
                    
                    Text("+2 more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .truncationMode(.tail)
                        .lineLimit(1)

                }
                .padding(.horizontal, 16)
                
                
                
                Spacer()
                
                DisplayLocationWidgetView(latitude: "40.7791151", longitude: "-73.9626129", showAnnotation: false)
                
                    .frame(height: 45)
                
        
                
                
            }
            
            .frame(width: TILE_SIZE, height: TILE_SIZE)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(CORNER_RADIUS)
            

            
            
            
    
        }
    }
}

#Preview{
    EventWidget(widget: CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .text, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"))
}
