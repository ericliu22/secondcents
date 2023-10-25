////
////  SabotageGame.swift
////  TwoCentsUI
////
////  Created by Enzo Tanjutco on 8/31/23.
////
//
//import SwiftUI
//
//private let fixedColumns = [
//    GridItem(.flexible()),
//    GridItem(.flexible())
//]
//
//struct SabotageGame: View {
//    
//    @State var isSpread = false
//    var body: some View {
//        NavigationStack{
//            ZStack{
//                Color("SabotageBg")
//                    .edgesIgnoringSafeArea(.all)
//                VStack{
//                    Text("Who will be the victim of your")
//                        .foregroundColor(.white)
//                        .font(.title2)
//                        .padding()
//                    Text("Sabotage")
//                        .foregroundColor(.white)
//                        .font(.custom("LuckiestGuy-Regular", size: 60))
//                        .padding(.top, -10)
//                    Spacer()
//                    ZStack{
//                        ForEach(0..<playerData.count, id: \.self) { player in
//                            CardView(player: playerData[player], playerIndex: player, isSpread: $isSpread)
////                                .onAppear{
////                                    isSpread = true
////                                }
//                                .rotationEffect(.degrees(isSpread ? CGFloat((player*5)+5) : 0))
////                                .animation(Animation.spring(
////                                    response: 1.0,
////                                    dampingFraction: 5).repeatForever().delay(1), value: isSpread)
////                                .offset(x: isSpread ? CGFloat(player*20) : 0)
//                        }
//                    }
//                    Spacer()
//                }
//                .onTapGesture {
//                    withAnimation(.spring()) {
//                        isSpread.toggle()
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct SabotageGamePageTwo: View {
//    
//    var player: PlayerData
//    
//    var body: some View {
//        ZStack{
//            Color("SabotageBg")
//                .edgesIgnoringSafeArea(.all)
//            VStack{
//                Image(player.image)
//                Text(player.name)
//                    .foregroundColor(.white)
//                    .font(.custom("LuckiestGuy-Regular", size: 30))
//                    .padding()
//                Spacer()
//                ScrollView{
//                    LazyVGrid(columns: fixedColumns, spacing: nil) {
//                        NavigationLink {
//                            SabotageGamePretend(player: player)
//                        } label: {
//                            SabotageWidget(player: player, icon: "person.fill", sabotageText: "Pretend")
//                        }
//                        
//                        NavigationLink {
//                            SabotageGameChangePic(player: player)
//                        } label: {
//                            SabotageWidget(player: player, icon: "shuffle", sabotageText: "Change profile")
//                        }
//                        
//                        NavigationLink {
//                            SabotageGameDelete(player: player)
//                        } label: {
//                            SabotageWidget(player: player, icon: "trash.fill", sabotageText: "Delete widgets")
//                        }
//                        
//                        NavigationLink {
//                            SabotageGameRemovePoints(player: player)
//                        } label: {
//                            SabotageWidget(player: player, icon: "delete.left.fill", sabotageText: "Remove points")
//                        }
//                    }.padding()
//                }
//            }
//        }
//    }
//}
//
//struct SabotageGamePretend: View {
//    
//    @State private var sabotageMessage = ""
//    var player: PlayerData
//    
//    var body: some View {
//        ZStack{
//            Color("SabotageBg")
//                .edgesIgnoringSafeArea(.all)
//            VStack{
//                Text("What's on your mind")
//                    .foregroundColor(.white)
//                    .font(.custom("LuckiestGuy-Regular", size: 30))
//                Text("'\(player.name)'")
//                    .foregroundColor(.white)
//                    .font(.custom("LuckiestGuy-Regular", size: 30))
//                ZStack{
//                    Image(player.image)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 90, height: 90)
//                        .offset(x: -165, y: -55)
//                        .zIndex(10)
//                    TextField("Type here!", text: $sabotageMessage)
//                        .padding(.all, 20)
//                        .padding(.vertical, 15)
//                        .keyboardType(.default)
//                        .background(.white).cornerRadius(100)
//                        .overlay(Capsule().stroke(Color(player.color), lineWidth: 5))
//                        .padding()
//                }
//            }
//        }
//    }
//}
//
//struct SabotageGameChangePic: View {
//    var player: PlayerData
//    var body: some View {
//        Text("change pic")
//    }
//}
//
//struct SabotageGameDelete: View {
//    var player: PlayerData
//    var body: some View {
//        Text("delete widgets")
//    }
//}
//
//struct SabotageGameRemovePoints: View {
//    var player: PlayerData
//    var body: some View {
//        Text("remove points")
//    }
//}
//
//struct SabotageWidget: View {
//    
//    var player: PlayerData
//    var icon: String
//    var sabotageText: String
//    
//    var body: some View {
//        ZStack{
//            VStack{
//                Image(systemName: icon)
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(Color(player.color))
//                
//                Text(sabotageText)
//                    .foregroundColor(Color(player.color))
//                    .font(.headline)
//                    .fontWeight(.regular)
//            }
//        }
//        
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(.white)
//        .aspectRatio(1, contentMode: .fit)
//        .cornerRadius(20)
//        
//    }
//    
//}
//
//
//struct SabotageGame_Previews: PreviewProvider {
//    static var previews: some View {
//        SabotageGame()
//    }
//}
