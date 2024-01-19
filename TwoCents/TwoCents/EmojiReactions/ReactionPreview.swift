//
//  ReactionPreview.swift
//  TwoCents
//
//  Created by Joshua Shen on 11/21/23.
//

import SwiftUI

//struct ReactionPreview: View {
//    @State var enlarge = false
//    //make showStruct binding
//    //onTap toggle the binding variable
//    @State var showStruct = false
//    @State var icon = ""
//    var body: some View {
//        Text("Sample Message")
//            .padding()
//            .frame(width: 300)
//            .background(Color(.purple), in: RoundedRectangle(cornerRadius: 40))
//            .onTapGesture{
//                withAnimation{
//                    enlarge = true
//                }
//            showStruct = true
//            }
//            .onLongPressGesture(maximumDistance: 0.1) {
//                withAnimation{                enlarge.toggle()
//                }
//            }
//            .overlay(alignment: .topTrailing, content: {
//                if showStruct{
//                    EmojiStruct(selectedIcon: $icon)
//                        .offset(y: -30 )
//                }
//            })
//            .overlay(alignment: .bottomTrailing, content: {
//                if !icon.isEmpty {
//                    Text(icon).offset(y: 0.4)
//                        .frame(width: 30, height: 30)
//                        .background(Color(.darkGray), in:Circle())
//                        .offset(x: 5, y:5)
//                }
//            })
//            .scaleEffect(enlarge ? 1.2: 1)
//    }
//}
//
//#Preview {
//    ReactionPreview()
//}

