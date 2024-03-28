//
//  PollChart.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI
import Charts

struct PollChartView: View{
    let options: [Option]
    var body: some View{
        VStack{
//            Text("Idk how to change chart colors lmao").foregroundColor(.black)
            Chart{
                ForEach(options) {
                    option in SectorMark(
                        angle: .value("Count", option.count),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Name", option.name))
                }
            }
            .padding()
//            PollButtons(options:[
//                .init(count: 5, name: "blue"),
//                .init(count: 1, name: "red"),
//                .init(count: 2, name: "purple"),
//                .init(count: 5, name: "yellow"),
//                .init(count: 3, name: "green")
//                        ])
        }
    }
}

//struct PollButtons: View {
//    let options: [Option]
//    var body: some View{
//        ForEach(options) {
//            option in Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
//                Text(option.name)
//            })
//        }
//    }
//}

struct PollButtons: View {
    let options: [Option]
    var body: some View{
        ForEach(options) {
            option in Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text(option.name)
            })
        }
        .padding(.top, 3)
        .padding(.bottom, 3)
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .foregroundColor(.black)
        .background(Color.white)
    }
}

//#Preview{
//    PollChartView(
////        options:[
////            .init(count: 5, name: "blue"),
////            .init(count: 1, name: "red"),
////            .init(count: 2, name: "purple"),
////            .init(count: 5, name: "yellow"),
////            .init(count: 3, name: "green")
////                    ]
//    )
//}
