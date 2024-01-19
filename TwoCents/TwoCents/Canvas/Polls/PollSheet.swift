//
//  File.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI

struct pollSheet: View{
    
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
            PollChartView(
                options:[
                    .init(count: 5, name: "blue"),
                    .init(count: 1, name: "red"),
                    .init(count: 2, name: "purple"),
                    .init(count: 5, name: "yellow"),
                    .init(count: 3, name: "green")
                            ]
            )
        }
    }
}
