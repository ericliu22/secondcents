//
//  SplashView.swift

import SwiftUI

struct SplashView: View {
    @State private var innerGap = true
//    let streamBlue = Color(.purple)
    @State  var userColor: Color
    
    var body: some View {
        ZStack {
            ForEach(0..<8) {
                Circle()
                    .foregroundStyle(
//                        .linearGradient(
//                            colors: [.green, streamBlue],
//                            startPoint: .bottom,
//                            endPoint: .leading
//                        )
                        userColor
                    )
                    .frame(width: 4, height: 4)
                    .offset(x: innerGap ? 24 : 0)
                    .rotationEffect(.degrees(Double($0) * 45))
                    .hueRotation(.degrees(20))
            }
            
            ForEach(0..<8) {
                Circle()
                    .foregroundStyle(
//                        .linearGradient(
//                            colors: [.green, streamBlue],
//                            startPoint: .bottom,
//                            endPoint: .leading
//                        )
                        userColor
                    )
                    .frame(width: 5, height: 5)
                    .offset(x: innerGap ? 26 : 0)
                    .rotationEffect(.degrees(Double($0) * 45))
                    .hueRotation(.degrees(-20))
                
            }
            .rotationEffect(.degrees(12))
        }
    }
}

#Preview {
    SplashView(userColor: .red)
}


