//
//  CardView.swift
//  TwoCentsUI
//
//  Created by Enzo Tanjutco on 8/31/23.
//

import SwiftUI

struct CardView: View {
    
    var player: PlayerData
    var playerIndex: Int
    @State private var offset = CGSize.zero
    @State private var index: Double = 0
    @Binding var isSpread: Bool

    var body: some View {
            ZStack{
                Rectangle()
                    .frame(width: 320, height: 500)
                    .border(.white, width: 5.0)
                    .cornerRadius(4)
                    .foregroundColor(Color(player.color))
                    .shadow(radius: 2)
                VStack(){
                    Image(player.image)
                        .padding(.top, -130)
                    Text(player.name)
                        .foregroundColor(.white)
                    
                        .font(.title)
                    
//                        .font(.custom("LuckiestGuy-Regular", size: 32))
                        .bold()
                        .padding(.bottom, 230)
                    NavigationLink(value: playerData[playerIndex]) {
                        ZStack{
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .shadow(radius: 5)
                            Image(systemName: "x.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationDestination(for: PlayerData.self) { player in
                SabotageGamePageTwo(player: player)
            }
            .zIndex(index)
            .offset(x: offset.width, y: offset.height)
//            .rotationEffect(.degrees(Double.random(in: -5...5)))

            .rotationEffect(.degrees(Double(offset.width / 40)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { _ in
                        withAnimation {
                            swipeCard(width: offset.width)
                        }
                    }
            )
    }

   func swipeCard(width: CGFloat) {
        switch width {
        case -500...(-200):
            print("The index is: \(index)")
            print("The player is: \(player)")
            offset = CGSize(width: 0, height: 0)
            index = index - 1
        case 200...(500):
            print("The index is: \(index)")
            offset = CGSize(width: 0, height: 0)
            index = index - 1
        default:
            offset = .zero
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(player: playerData[1], playerIndex: 1, isSpread: .constant(false))
    }
}
