//
//  CardView.swift
//  TwoCentsUI
//
//  Created by Enzo Tanjutco on 8/31/23.
//

import SwiftUI

@available(iOS 17.0, *)
struct CardView: View {
    
    var player: DBUser
    var playerIndex: Int
    @State private var offset = CGSize.zero
    @State private var index: Double = 0
    @Binding var isSpread: Bool
    
    var playerColor: Color
    var playerImage: String
    
    var urlString: String
    var frameSize: CGFloat? = 200
    
    var body: some View {
            ZStack{
                Rectangle()
                    .border(.white, width: 5.0)
                    .cornerRadius(4)
                    .foregroundColor(playerColor)
                    .shadow(radius: 2)
                    .padding(.vertical, 100)
                    .padding(.horizontal, 40)
                VStack(){
                    
                    let url = URL(string: urlString)
                    AsyncImage(url: url) {image in
                        image
                            .resizable()
                            .scaledToFill()
                    }  placeholder: {
                        //else show loading after user uploads but sending/downloading from database
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                            .frame(width: frameSize, height: frameSize)
                            .background(
                                Circle()
                                    .fill(Color.accentColor)
                            )
                    }
                    .clipShape(Circle())
                    .frame(width: frameSize, height: frameSize)

                    Text(player.name!)
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                    Spacer()
                    NavigationLink(value: playerData[playerIndex]) {
                        ZStack{
                            Rectangle()
                                .foregroundColor(playerColor)
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
            .navigationDestination(for: Int.self) { player in
                SabotageSelectionView(playerIndex: player)
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

//@available(iOS 17.0, *)
//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardView(player: playerData[1], playerIndex: 1, isSpread: .constant(false))
//    }
//}
