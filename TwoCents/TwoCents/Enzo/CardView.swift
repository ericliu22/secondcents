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
                    .border(.white, width: 5.0)
                    .cornerRadius(4)
                    .foregroundColor(Color(player.color))
                    .shadow(radius: 2)
                    .padding(.vertical, 100)
                    .padding(.horizontal, 40)
                VStack(){
                    Image(player.image)
                    Text(player.name)
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                    Spacer()
                    NavigationLink(value: playerData[playerIndex]) {
                        ZStack{
                            Rectangle()
                                .foregroundColor(Color(player.color))
                                .background(.regularMaterial)
                                .frame(width: 200, height: 50)
                                .cornerRadius(10)
                                .opacity(0.5)
                                .shadow(radius: 5)
                            Text("Sabotage")
                                .font(.custom("LuckiestGuy-Regular", size: 28))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
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
        case -500...(-100):
            print("The index is: \(index)")
            print("The player is: \(player)")
            offset = CGSize(width: 0, height: 0)
            index = index - 1
        case 100...(500):
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
