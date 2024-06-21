//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI

func mapWidget(widget: CanvasWidget) -> AnyView {

//    print(isPresented)
    assert(widget.media == .map)
    

    
    return AnyView(
        
        DisplayLocationWidgetView(latitude: "40.7791151", longitude: "-73.9626129")
           
          
       
    )//AnyView
    
}
