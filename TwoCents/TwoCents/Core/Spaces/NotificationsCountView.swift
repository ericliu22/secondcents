//
//  NotificationsCountView.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/22.
//

import Foundation
import SwiftUI

//Legit copy pasted from internet
struct NotificationCountView : View {
    
    @Environment(AppModel.self) var appModel
    @Binding var value: Int
    
    private let FOREGROUND_COLOR: Color = .white
    private let size: CGFloat
    private let x: CGFloat
    private let y: CGFloat
    
    init(value: Binding<Int>, x: CGFloat = 12.0, y: CGFloat = 20.0, size: CGFloat = 20 ) {
        self._value = value
        self.x = x
        self.y = y
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(appModel.loadedColor)
                .frame(width: size * widthMultplier(), height: size, alignment: .topTrailing)
                .position(x: x, y: y)
            
            if hasTwoOrLessDigits() {
                Text("\(value)")
                    .foregroundColor(FOREGROUND_COLOR)
                    .font(Font.caption)
                    .position(x: x, y: y)
            } else {
                Text("99+")
                    .foregroundColor(FOREGROUND_COLOR)
                    .font(Font.caption)
                    .frame(width: size * widthMultplier(), height: size, alignment: .center)
                    .position(x: x, y: y)
            }
        }
        .opacity(value == 0 ? 0 : 1)
    }
    
    // showing more than 99 might take too much space, rather display something like 99+
    private func hasTwoOrLessDigits() -> Bool {
        return value < 100
    }
    
    private func widthMultplier() -> Double {
        if value < 10 {
            // one digit
            return 1.0
        } else if value < 100 {
            // two digits
            return 1.5
        } else {
            // too many digits, showing 99+
            return 2.0
        }
    }
}
