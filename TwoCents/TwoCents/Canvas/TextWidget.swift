//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI

func textWidget(widget: CanvasWidget) -> AnyView {
    @State var isPresented: Bool = false
    
    assert(widget.media == .text)
    @State var inputText: String = ""
    return AnyView(
        
        
        Text(widget.textString ?? "")
            .multilineTextAlignment(.leading)
            .font(.custom("LuckiestGuy-Regular", size: 24, relativeTo: .headline))
            .foregroundColor(Color.accentColor)
            .frame(width: widget.width, height: widget.height)
            .background(.thickMaterial)
        
        
        
//        AsyncImage(url: widget.mediaURL) {image in
//            image
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: widget.width, height: widget.height)
//                .clipShape(
//                    RoundedRectangle(cornerRadius: CORNER_RADIUS)
//                )
//                .onTapGesture {
//                    isPresented.toggle();
//                }
//            
//        } placeholder: {
//            ProgressView()
//                .progressViewStyle(
//                    CircularProgressViewStyle(tint:
//                            .primary)
//                )
//           
//                .frame(width: widget.width, height: widget.height)
//                .background(.thickMaterial)
//        }//AsyncImage
//          
       
    )//AnyView
}
