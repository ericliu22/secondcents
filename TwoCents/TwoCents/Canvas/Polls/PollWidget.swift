//
//  PollWidget.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI

struct PollWidget: View {
    @State var isShowingPoll = false;
    
    var body: some View {
        VStack{
           Text("poll")
        }
            .frame(width: 200, height: 200)
            .onTapGesture{isShowingPoll.toggle()}
            .fullScreenCover(isPresented: $isShowingPoll, content: {
                pollSheet()
            })
    }
}

#Preview{
    PollWidget()
}
