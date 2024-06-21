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
    
    
    let location = widget.location?.split(separator: ", ")
    
    let latitude = String(location?[0] ??  "40.7791151")
    let longitude = String(location?[1] ?? "-73.9626129")
    
    return AnyView(
        
        DisplayLocationWidgetView(latitude: latitude, longitude: longitude)
           
          
       
    )//AnyView
    
}
