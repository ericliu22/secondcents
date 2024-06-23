//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI


struct MapWidget: WidgetView {

//    print(isPresented)
    let widget: CanvasWidget

    let latitude: String
    let longitude: String
    
    init(widget: CanvasWidget) {
        assert(widget.media == .map)
//        print(widget.name)
        self.widget = widget
        let location = widget.location?.split(separator: ", ")
        self.latitude = String(location?[0] ??  "40.7791151")
        self.longitude = String(location?[1] ?? "-73.9626129")
    }

    var body: some View {
     
            DisplayLocationWidgetView(latitude: latitude, longitude: longitude)
      
    }
       
   
}
