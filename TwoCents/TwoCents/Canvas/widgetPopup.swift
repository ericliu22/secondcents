//
//  widgetPopup.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/14/24.
//

import Foundation
import SwiftUI

//fullscreencover for image, video, album widgets?
struct widgetPopup: View{
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        ZStack(alignment: .topLeading) {
            Color.white.edgesIgnoringSafeArea(.all)
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .font(.largeTitle)
                    .padding(20)
            })
            Text("test")
        }
    }
}
