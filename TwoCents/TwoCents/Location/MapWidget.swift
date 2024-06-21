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

func openMapsApp(lat: String, long: String) {
    
    let url = URL(string: "http://maps.apple.com/?ll=\(lat),\(long)")!
    
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        // Handle error if the Maps app cannot be opened
        print("Cannot open Maps app")
    }
}
