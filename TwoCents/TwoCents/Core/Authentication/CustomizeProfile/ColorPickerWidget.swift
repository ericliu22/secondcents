//
//  ColorPickerWidget.swift
//  TwoCents
//
//  Created by jonathan on 8/22/23.
//

import SwiftUI




struct ColorPickerWidget: View {
    
    @Environment(AppModel.self) var appModel
    @StateObject private var viewModel = ColorPickerWidgetViewModel()
    
    
    private let colors: [Color] = [.red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink,.brown]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack{
                ForEach(colors, id: \.self) {color in
                    Circle()
                        .foregroundColor(color)
                        .frame(width: 45,height: 45)
                        .opacity(color == appModel.loadedColor ? 1.0  : 0.5)
                        .scaleEffect(color == appModel.loadedColor ? 1.1  : 1.0)
                        .onTapGesture{
                            appModel.loadedColor = color
                            viewModel.saveUserColor(selectedColor: appModel.loadedColor, userId: appModel.user?.userId ?? "")
                            
                        }
                        .animation(.easeInOut(duration: 0.25), value: appModel.loadedColor)
                        
                }
            }
            
            .padding()
            .background(.thinMaterial)
            //            .background(appModel.loadedColor.opacity(0.3))
            .cornerRadius(10)
            .padding(.horizontal)
//            .task{
//                viewModel.saveUserColor(selectedColor: appModel.loadedColor, userId: appModel.user?.userId ?? "")
//                
//            }
        }
        
        
        
        
    }
    
}

/*
struct ColorPickerWidget_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerWidget(appModel.loadedColor: .constant(.blue))
    }
}

*/
