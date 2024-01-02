//
//  NewWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/1/1.
//

import Foundation
import SwiftUI

struct NewWidget: View {
    
    var body: some View {
        ZStack {
            Color.white
                .frame(width: .infinity, height: .infinity)
            VStack{
               Text("Create a new Widget")
                .font(.custom("LuckiestGuy-Regular", size: 48))
                
            }
        }
    }
}


struct Tile: View {
    
    @State private var color: Color = .black
    @State private var type: Media = .image
    
    init(userColor: Color) {
        
        self.color = userColor
    }
    
    var body: some View {
        ZStack {
            Text("Media")
            RoundedRectangle(cornerRadius: CORNER_RADIUS)
                .stroke(color, lineWidth: LINE_WIDTH)
                .frame(width: TILE_SIZE, height: TILE_SIZE)
        }
    }
}
