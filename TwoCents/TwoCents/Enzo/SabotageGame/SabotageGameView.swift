//
//  SabotageGame.swift
//  TwoCentsUI
//
//  Created by Enzo Tanjutco on 8/31/23.
//

import SwiftUI


private let fixedColumns = [
    GridItem(.flexible()),
    GridItem(.flexible())
]

struct SabotageView: View {
    
    @State var isSpread = false
    
    @StateObject private var viewModel = SabotageGameViewModel()
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color("SabotageBg")
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Text("Who will be the victim of your")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding()
                    Text("Sabotage")
                        .foregroundColor(.white)
                        .font(.custom("LuckiestGuy-Regular", size: 60))
                        .padding(.top, -10)
                    Spacer()
                    ZStack{
                        
                        if let myMemberInfo = viewModel.membersInfo{ForEach(0..<myMemberInfo.count, id: \.self){member in
                            let memberColor: Color = viewModel.getUserColor(userColor:myMemberInfo[member].userColor ?? "")
                            let urlString: String = myMemberInfo[member].profileImageUrl ?? ""
                            
                            CardView(player: myMemberInfo[member], playerIndex: member, isSpread: $isSpread, playerColor: memberColor, playerImage: urlString, urlString: urlString)
                                .rotationEffect(.degrees(isSpread ? CGFloat((member*5)+5) : 0))
                        }
                        
//                        ForEach(0..<playerData.count, id: \.self) { player in
//                            CardView(player: playerData[player], playerIndex: player, isSpread: $isSpread) 
//                                .onAppear{
//                                    isSpread = true
//                                }
//                                .animation(Animation.spring(
//                                    response: 1.0,
//                                    dampingFraction: 5).repeatForever().delay(1), value: isSpread)
//                                .offset(x: isSpread ? CGFloat(player*20) : 0)
                        }
                    }
                    Spacer()
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        isSpread.toggle()
                    }
                }
            }
        }
        .task{
            
            //loads the current user (the one using the app)
            try? await viewModel.loadCurrentUser()
            
            //loads teh current space (usually, spaceId is passed in. However, jonny has not completed the page that passes it in, so its hard coded rn)
            try? await viewModel.loadCurrentSpace(spaceId: "B72612FC-70DE-44F5-9CE9-B001B0B6651F" )
            
            //if space is loaded, and it has the field members in it...
            //for each UID in the members array, load their DBUser Info...
            if let mySpace = viewModel.space, let myMembers = mySpace.members {
                    try? await viewModel.loadMembersInfo(members: myMembers)
            }
        }
    }
}




struct SabotageGamePretendReal: View {
    
    @State private var sabotageMessage = ""
    var player: PlayerData
    
    var body: some View {
        ZStack{
            Color("SabotageBg")
                .edgesIgnoringSafeArea(.all)
            VStack{
                Text("What's on your mind")
                    .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: 30))
                Text("'\(player.name)'")
                    .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: 30))
                ZStack{
                    Image(player.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 90)
                        .offset(x: -165, y: -55)
                        .zIndex(10)
                    TextField("Type here!", text: $sabotageMessage)
                        .padding(.all, 20)
                        .padding(.vertical, 15)
                        .keyboardType(.default)
                        .background(.white).cornerRadius(100)
                        .overlay(Capsule().stroke(Color(player.color), lineWidth: 5))
                        .padding()
                }
            }
        }
    }
}

struct SabotageGameChangePicReal: View {
    var player: PlayerData
    var body: some View {
        Text("change pic")
    }
}

struct SabotageGameDeleteReal: View {
    var player: PlayerData
    var body: some View {
        Text("delete widgets")
    }
}

struct SabotageGameRemovePointsReal: View {
    var player: PlayerData
    var body: some View {
        Text("remove points")
    }
}

struct SabotageWidgetReal: View {
    
    var player: PlayerData
    var icon: String
    var sabotageText: String
    
    var body: some View {
        ZStack{
            VStack{
                Image(systemName: icon)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(player.color))
                
                Text(sabotageText)
                    .foregroundColor(Color(player.color))
                    .font(.headline)
                    .fontWeight(.regular)
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(20)
        
    }
    
}


@available(iOS 17.0, *)
struct SabotageView_Previews: PreviewProvider {
    static var previews: some View {
        SabotageView()
    }
}
