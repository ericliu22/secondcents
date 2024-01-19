//
//  EmojiStruct.swift
//  TwoCents
//
//  Created by Joshua Shen on 11/17/23.
//

import SwiftUI

struct Emoji: Codable{
    var sendBy: String
    var emoji: String
}

struct Icon{
    var icon: String
    var isVisible: Bool = false
}

struct EmojiStruct: View {
    //show struct variable
    @Binding var showStruct: Bool
    @State var show = false
    @State var icons: [Icon] = [
        Icon(icon: "💀"),
        Icon(icon: "💅"),
        Icon(icon: "🤡"),
        Icon(icon: "🗣️"),
        Icon(icon: "🤓"),
    ]
    @Binding var selectedIcon: String
    var body: some View {
        HStack(spacing: 20){
            ForEach(icons.indices,id: \.self) {
                index in
                IconView(icon: $icons[index].icon, isVisible: $icons[index].isVisible, selectedIcon: $selectedIcon, showStruct: $showStruct)
                    .animation(Animation.spring().delay(Double(index)*0.2), value: icons[index].isVisible)
            }
        }
        .frame(width: show ? 230: 40, height: 40)
        .background(Color(.darkGray), in:RoundedRectangle(cornerRadius: 40))
        .onAppear(perform: {
            withAnimation(.easeInOut(duration: 0.2)){
                show = true
            }
            for index in icons.indices{
                icons[index].isVisible = true
            }
        })
    }
}

struct IconView: View{
//    @EnvironmentObject var reactionManager: ReactionManager
    @Binding var icon: String
    @Binding var isVisible: Bool
    @State var isTapped: Bool = false
    @Binding var selectedIcon: String
    @Binding var showStruct: Bool
    var body: some View{
        Text(icon).font(.title2)
            .scaleEffect(isTapped ? 1.5 : isVisible ? 1:0)
            .background(Circle().foregroundColor( (selectedIcon == icon) ? .red : .clear))
        //add/change emoji
            .onTapGesture{
                showStruct = false
                withAnimation(Animation.spring, {
                    
                    isTapped = true
                    selectedIcon = (selectedIcon == icon) ? "": icon
                    
                })
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    withAnimation{
                        isTapped = false
                    }
            }
        }
    }
}

#Preview {
    ReactionPreview()
}

struct ReactionPreview: View {
//    @EnvironmentObject var reactionManager: ReactionManager
    @State var enlarge = false
    //make showStruct binding
    //onTap toggle the binding variable
    @State var showStruct = false
    @State var icon = ""
    var body: some View {
        Text("Sample Message")
            .padding()
            .frame(width: 300)
            .background(Color(.purple), in: RoundedRectangle(cornerRadius: 40))
        //open and close emoji struct
            .onTapGesture(count: 2){
                showStruct.toggle()
                //showStruct = true
            }
            .overlay(alignment: .topTrailing, content: {
                if showStruct {
                    EmojiStruct(showStruct: $showStruct, selectedIcon: $icon)
                        .offset(y: -30 )
                }
                
            })
            .overlay(alignment: .bottomTrailing, content: {
                if !icon.isEmpty {
                    Text(icon).offset(y: 0.4)
                        .frame(width: 30, height: 30)
                        .background(Color(.darkGray), in:Circle())
                        .offset(x: 5, y:5)
                }
            })
//            .scaleEffect(enlarge ? 1 : 1)
    }
}
