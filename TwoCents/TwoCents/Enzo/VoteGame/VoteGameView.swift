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
    @State private var selectedColor: String = ""
    @State private var selectedNumVotes: Int = 0
    
    @State private var readyNextPage = false
    
    
    @StateObject private var viewModel = VoteGameViewModel()
    
    var body: some View {
        NavigationView{
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
                            ForEach(0..<playerData.count, id: \.self) {item in
                                ZStack{
                                    CapsuleView(emptyPlayer: $selectedPlayer, emptyImage: $selectedImage, emptyColor: $selectedColor, emptyNumVotes: $selectedNumVotes, selectedPlayer: playerData[item].name, selectedImage: playerData[item].image, selectedColor: playerData[item].color, selectedNumVotes: playerData[item].numVotes)
                                    HStack{
                                        Image(playerData[item].image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 60)
                                            .padding(.leading, 5)
                                        Text(playerData[item].name)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    
                    
                    
                    //Displays the current user's name
                    if let myUser = viewModel.user {
                        if let myName = myUser.name{
                            Text("My name: \(myName)")
                                .font(.largeTitle)
                        }
                    }
                    
                    
                    //Displays the space's name
                    if let mySpace = viewModel.space {
                        if let mySpaceName = mySpace.name{
                            Text("This space: \(mySpaceName)")
                                .font(.largeTitle)
                        }
                        
                        
                        //display's the UID's of each member within this space. Usually not needed, as i have put this within the loadMembersInfo function
                        if let mySpaceMembers = mySpace.members{
                            ForEach(0..<mySpaceMembers.count, id: \.self) {member in
                                Text("member \(member): \(mySpaceMembers[member])")
                                    .font(.headline)
                            }
                        }
                        
                        
                        //displays each user's info pulled from the database. Must do the try await loadMembersInfo in the task area at the bottom first.
                        if let myMemberInfo = viewModel.membersInfo{
                            ForEach(0..<myMemberInfo.count, id: \.self) {member in
                                Text(myMemberInfo[member].name ?? "")
                                    .font(.largeTitle)
                            }
                        }
                        
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    Button("Send") {
                        addVote()
                        self.readyNextPage = true
                    }
                    .font(.custom("LuckiestGuy-Regular", size: 48))
                    .foregroundColor(.white)
                    .opacity(selectedPlayer == "" ? 0.5 : 1.0)
                    .disabled(selectedPlayer == "")
                    
                    
                    
                    NavigationLink(destination: ResultView(playerName: selectedPlayer, playerImage: selectedImage, playerColor: selectedColor, playerVotes: selectedNumVotes), isActive: $readyNextPage) {EmptyView()}
                }
                .padding(.top)
            }
            .background(Color("VoteBg"))
        }
        .task{
            
            //loads the current user (the one using the app)
            try? await viewModel.loadCurrentUser()
            
            //loads teh current space (usually, spaceId is passed in. However, jonny has not completed the page that passes it in, so its hard coded rn)
            try? await viewModel.loadCurrentSpace(spaceId: "BC636778-A19D-4BD3-9973-7C6768F5D861" )
            
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
