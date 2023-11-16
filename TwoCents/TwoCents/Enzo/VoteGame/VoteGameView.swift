//
//  VoteGameReal.swift
//  TwoCentsUI
//
//  Created by Enzo Tanjutco on 8/1/23.
//

import SwiftUI

private let fixedColumns = [
    GridItem(.flexible())
]

struct VoteGameView: View {
    @State private var selectedPlayer: String = ""
    @State private var selectedImage: String = ""
    @State private var selectedColor: Color = .green
    @State private var selectedNumVotes: Int = 0
    @State private var selectedURLString: String = ""
    
    @State private var readyNextPage = false
    
    
    @StateObject private var viewModel = VoteGameViewModel()
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack{
                    Spacer()
                    Text("Vote for the friend who _slays_ at")
                        .foregroundColor(.white)
                        .padding(.bottom, -5)
                    
                    
                    Text("Killing the Vibe")
                        .foregroundColor(.white)
                        .font(.custom("LuckiestGuy-Regular", size: 36))
                    
                    
                    ScrollView{
                        LazyVGrid(columns: fixedColumns, spacing: 20) {
                            
                            if let myMemberInfo = viewModel.membersInfo{ForEach(0..<myMemberInfo.count, id: \.self){member in
                                let memberColor: Color = viewModel.getUserColor(userColor:myMemberInfo[member].userColor ?? "")
                                let urlString: String = myMemberInfo[member].profileImageUrl ?? ""
                                
                                
                                ZStack{
                                    CapsuleView(emptyPlayer: $selectedPlayer, emptyImage: $selectedImage, emptyColor: $selectedColor, emptyNumVotes: $selectedNumVotes, emptyURLString: $selectedURLString, selectedPlayer: myMemberInfo[member].name ?? "", selectedImage: "enzo-pic", selectedColor: memberColor, selectedNumVotes: playerData[member].numVotes, selectedURLString: urlString)
                                    HStack{
                                        //images
                                        Group{
                                            //Circle or Profile Pic
                                            let frameSize: CGFloat? = 72
                                            
                                            if let urlString = myMemberInfo[member].profileImageUrl,
                                               let url = URL(string: urlString) {
                                                
                                                //If there is URL for profile pic, show
                                                //circle with stroke
                                                AsyncImage(url: url) {image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                    
                                                } placeholder: {
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
                                                
                                            } else {
                                                //if space does not have profile pic, show circle
                                                Circle()
                                                    .fill(Color.accentColor)
                                                    .clipShape(Circle())
                                                    .frame(width: frameSize, height: frameSize)
                                            }
                                        }
                                        Text(myMemberInfo[member].name ?? "")
                                            .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }}
                            
                        }
                    }
                    .padding()

                    
                    ForEach(0..<1) { player in
                        NavigationLink(value: player) {
                            Text("Send")
                                .font(.custom("LuckiestGuy-Regular", size: 48))
                                .foregroundColor(.white)
                                .opacity(selectedPlayer == "" ? 0.5 : 1.0)
                        }
                        .disabled(selectedPlayer == "")
                        .onTapGesture {
                            addVote()
                        }
                    }
                }
                .padding(.top)
            }
            .navigationDestination(for: Int.self) { player in
                ResultView(playerName: selectedPlayer, playerImage: selectedImage, playerColor: selectedColor, playerVotes: selectedNumVotes, urlString: selectedURLString)
            }
            .background(Color("VoteBg"))

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
    func addVote() {
        selectedNumVotes += 1
    }
}

struct VoteGameView_Previews: PreviewProvider {
    static var previews: some View {
        VoteGameView()
    }
}
