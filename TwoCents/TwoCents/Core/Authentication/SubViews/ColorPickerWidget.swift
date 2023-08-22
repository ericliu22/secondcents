//
//  ColorPickerWidget.swift
//  TwoCents
//
//  Created by jonathan on 8/22/23.
//

import SwiftUI




struct ColorPickerWidget: View {
    
    @Binding var selectedColor: Color

    private let colors: [Color] = [.red, .orange, .yellow, .green, .mint, .teal,  .cyan, .blue, .indigo, .purple, .pink,.brown]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack{
                ForEach(colors, id: \.self) {color in
                    Circle()
                        .foregroundColor(color)
                        .frame(width: 45,height: 45)
                        .opacity(color == selectedColor ? 1.0  : 0.5)
                        .scaleEffect(color == selectedColor ? 1.1  : 1.0)
                        .onTapGesture{
                            selectedColor = color
                        }
                }
            }
            .padding()
            .background(.thinMaterial)
//            .background(selectedColor.opacity(0.3))
            
            .cornerRadius(20)
            .padding(.horizontal)
        }
        
    }
}

struct ColorPickerWidget_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerWidget(selectedColor: .constant(.blue))
    }
}
