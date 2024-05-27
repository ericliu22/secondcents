//
//  TextWidgetAlphaTest.swift
//  TwoCents
//
//  Created by Joshua Shen on 5/22/24.
//

import Foundation
import SwiftUI

struct testView: View {
    @State private var showPopup = false
    @State private var showTextDisplay = false
    @State private var displayedText: String = ""

    var body: some View {
        ZStack {
            VStack {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
            }
            .onLongPressGesture {
                showPopup = true
            }

            if showPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPopup = false
                    }

                TextView(showPopup: $showPopup, showTextDisplay: $showTextDisplay, textToDisplay: $displayedText)
                    .transition(.scale)
                    .zIndex(1)
            }

            if showTextDisplay {
                TextDisplayView(text: displayedText)
                    .transition(.scale)
                    .zIndex(2)
            }
        }
    }
}

struct testView_Previews: PreviewProvider {
    static var previews: some View {
        testView()
    }
}
