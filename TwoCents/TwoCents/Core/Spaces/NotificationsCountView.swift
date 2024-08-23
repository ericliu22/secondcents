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
    
    @Binding var value: Int
    @Binding var loadedColor: Color
    
    private let FOREGROUND_COLOR: Color = .white
    private let SIZE = 20.0
    private let x = 20.0
    private let y = 12.0
    
    init(value: Binding<Int>, loadedColor: Binding<Color>) {
        self._value = value
        self._loadedColor = loadedColor
    }
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(loadedColor)
                .frame(width: SIZE * widthMultplier(), height: SIZE, alignment: .topTrailing)
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
                    .frame(width: SIZE * widthMultplier(), height: SIZE, alignment: .center)
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
