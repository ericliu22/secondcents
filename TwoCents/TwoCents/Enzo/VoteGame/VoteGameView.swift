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
                    
                    if let myUser = viewModel.user {
                        
                        if let myName = myUser.name{
                            
                            Text("\(myName)")
                                .font(.largeTitle)
                            
                            
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
            
            try? await viewModel.loadCurrentUser()
            
            
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
