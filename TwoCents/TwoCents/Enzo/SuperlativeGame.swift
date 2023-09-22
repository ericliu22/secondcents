//
//  SuperlativeGame.swift
//  TwoCentsUI
//
//  Created by Enzo Tanjutco on 8/4/23.
//

import SwiftUI

var dataIndex = 0
var savedSuperlativeMessage: [String] = []

private let fixedColumns = [
    GridItem(.flexible())
]

struct SuperlativeGame: View {
    
    @State private var path = NavigationPath()
 
    var body: some View {
        NavigationStack(path: $path){
            ZStack{
                Color("SuperlativeBg")
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Text("SUPERLATIVES")
                        .foregroundColor(.white)
                        .font(.custom("LuckiestGuy-Regular", size: 48))
                    Spacer()
                    NavigationLink(value: playerData.first) {
                        Text("Start!")
                            .foregroundColor(.white)
                            .font(.custom("LuckiestGuy-Regular", size: 60))
                            .padding()
                            .shadow(radius: 3)
                    }
                    Spacer()
                }
                .navigationDestination(for: PlayerData.self) { player in
                    answeringView(path: $path, player: player)
                }
                .navigationDestination(for: Int.self) { integer in
                    responsesView(path: $path)
                }
            }
        }
    }
}

struct answeringView: View {
    
    @Binding var path: NavigationPath
    @State var player: PlayerData
    @State private var isTapped = false
    @State var superlativeMessage = ""
    @State var isAnimated = false
    @State var animateOpacity = 0.0

    var body: some View {
        ZStack{
            Color("SuperlativeBg")
                .edgesIgnoringSafeArea(.all)
            VStack{
                Text("SUPERLATIVES")
                    .onAppear{
                        isAnimated = true
                        animateOpacity = 1.0
                    }
                    .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: isAnimated ? 48 : 100))
                    .animation(Animation.spring(
                        response: 0.5,
                        dampingFraction: 0.2), value: isAnimated)
                    .padding(.top, 20)
                Spacer()
                Image(player.image)
                    .rotationEffect(Angle(degrees: isAnimated ? 360 : 0))
                    .animation(Animation.spring(
                        response: 1.0,
                        dampingFraction: 0.2).repeatForever(), value: isAnimated)
                    .opacity(animateOpacity)
                    .animation(.default.delay(4), value: animateOpacity)

                Spacer()
                Text("How would you describe the _charming_")
                    .foregroundColor(.white)
                    .font(.custom("SFProDisplay-Regular", size: isAnimated ? 18 : 50))
                    .animation(Animation.spring(), value: isAnimated)
                    .opacity(animateOpacity)
                    .animation(.default.delay(2), value: animateOpacity)
                    .padding()
                Text("\(player.name)?")
                    .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: isAnimated ? 28 : 100))
                    .animation(Animation.spring(), value: isAnimated)
                    .opacity(animateOpacity)
                    .animation(.default.delay(3), value: animateOpacity)
                    .padding(.top, -15)
                TextField("Answer here!", text: $superlativeMessage)
                    .padding()
                    .keyboardType(.default)
                    .background(.white).cornerRadius(40)
                    .overlay(Capsule().stroke(Color(player.color), lineWidth: 5))
                    .opacity(isAnimated ? 1.0 : 0.0)
                    .animation(Animation.linear.delay(5), value: isAnimated)
                    .padding(.horizontal, 40)
                Button("Send") {
                    saveSuperlativeMessage()
                    if dataIndex < playerData.count {
                        dataIndex += 1
                    }
                    if dataIndex <= playerData.count - 1 {
                        path.append(playerData[dataIndex])
                    } else if dataIndex == playerData.count {
                        path.append(dataIndex)
                        dataIndex = 0
                    }
                } .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: 36))
                    .shadow(radius: 3)
                    .padding(.top, 50)
                    .disabled(superlativeMessage == "")
                    .opacity(superlativeMessage == "" ? 0.5 : 1.0)
                    .opacity(isAnimated ? 1.0 : 0.0)
                    .animation(Animation.easeIn.delay(6), value: isAnimated)
                Spacer()

            }.navigationBarBackButtonHidden(true)
        }
    }
    
    func saveSuperlativeMessage() {
        savedSuperlativeMessage.append(superlativeMessage)
        superlativeMessage = ""
    }
}

struct responsesView: View {
    
    @Binding var path: NavigationPath
    @State var emptyMessage = ""
    @State var selectedMessage = ""
    
    var body: some View {
        ZStack{
            Color("SuperlativeBg")
                .edgesIgnoringSafeArea(.all)
            VStack{
                Text("SUPERLATIVES")
                    .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: 48))
                Image(playerData[dataIndex].image)
                Text("How would you describe the _charming_")
                    .foregroundColor(.white)
                    .font(.custom("SFProDisplay-Regular", size: 18))
                    .padding()
                Text("\(playerData[dataIndex].name)?")
                    .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: 30))
                    .padding(.top, -15)
                ZStack{
                    LazyVGrid(columns: fixedColumns, spacing: 20) {
                        ForEach(0..<playerData.count, id: \.self) { item in
                            ZStack{
                                responsesCapsules(emptyMessage: $selectedMessage, selectedMessage: savedSuperlativeMessage[item])
                                Text(savedSuperlativeMessage[dataIndex])
                            }
                        }
                    }
                }
                Spacer()
                Button ("Next") {
                    dataIndex += 1
                    path.append(dataIndex)
                }
            }
        }
    }
}

struct responsesCapsules: View{
    
    @Binding var emptyMessage: String
    var selectedMessage: String
    
    var body: some View {
        Capsule()
            .fill(selectedMessage == emptyMessage ? Color(playerData[dataIndex].color) : .white)
            .padding(.all, 20)
            .background(selectedMessage == emptyMessage ? Color(playerData[dataIndex].color) : .white).cornerRadius(40)
            .overlay(Capsule().stroke(Color(playerData[dataIndex].color), lineWidth: 5))
            .padding(.horizontal, 30)
            .onTapGesture {
                withAnimation(.spring()) {
                    emptyMessage = selectedMessage
                }
            }
    }
}
    

struct SuperlativeGame_Previews: PreviewProvider {
    static var previews: some View {
        SuperlativeGame()
    }
}
