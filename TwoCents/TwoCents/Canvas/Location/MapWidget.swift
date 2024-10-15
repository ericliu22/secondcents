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

    private func openMapsApp(location: String) {
        
        let locationAray = location.split(separator: ", ")
        let latitude = String(locationAray[0])
        let longitude = String(locationAray[1])
        
        print(location)
        
        
        let url = URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Handle error if the Maps app cannot be opened
            print("Cannot open Maps app")
        }
    }
    
    
    var body: some View {
        
        ZStack{
            DisplayLocationWidgetView(latitude: latitude, longitude: longitude)
                .frame(
                    width: widget.width,
                    height: widget.height
                )
            
            //so context menu works
            Color.clear
               .contentShape(Rectangle())
        }
        .onTapGesture {
            if let location = widget.location {
                openMapsApp(location: location)
            }
        }
        
            
    }
       
   
}


