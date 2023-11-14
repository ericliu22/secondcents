//
//  HotSeatManager.swift
//  TwoCentsUI
//
//  Created by Enzo Tanjutco on 7/28/23.
//

import Foundation
import SwiftUI

struct PlayerData: Identifiable, Hashable{
    let id = UUID()
    let name: String
    let image: String
    let color: String
    let numVotes: Int
    let nativeColor: Color
}

let playerData: [PlayerData] = [
    PlayerData(name: "enzobenzoferrari", image: "enzo-pic", color: "enzoGreen", numVotes: 2, nativeColor: .green),
    PlayerData(name: "GOAT", image: "josh-pic", color: "joshOrange", numVotes: 3, nativeColor: .orange),
    PlayerData(name: "mlgxd420", image: "jonathan-pic", color: "jonathanBlue", numVotes: 0, nativeColor: .teal),
    PlayerData(name: "daddy", image: "eric-pic", color: "ericPurple", numVotes: 100, nativeColor: .purple),
]

class HotSeatManager: ObservableObject{
    @Published var onHotSeat = true
}


//                   //Displays the current user's name
//                   if let myUser = viewModel.user {
//                       if let myName = myUser.name{
//                           Text("My name: \(myName)")
//                       }
//                   }
//                   //Displays the space's name
//                   if let mySpace = viewModel.space {
////                        if let mySpaceName = mySpace.name{
////                            Text("This space: \(mySpaceName)")
////                        }
//                       
//                       
//                       //display's the UID's of each member within this space. Usually not needed, as i have put this within the loadMembersInfo function
////                        if let mySpaceMembers = mySpace.members{
////                            ForEach(0..<mySpaceMembers.count, id: \.self) {member in
////                                Text("member \(member): \(mySpaceMembers[member])")
////                            }
////                        }
//                       
//                       
//                       //displays each user's info pulled from the database. Must do the try await loadMembersInfo in the task area at the bottom first.
//                       if let myMemberInfo = viewModel.membersInfo{
//                           ForEach(0..<myMemberInfo.count, id: \.self) {member in
////                                Text(myMemberInfo[member].name ?? "")
//                               let memberColor: Color = viewModel.getUserColor(userColor:myMemberInfo[member].userColor ?? "")
//
//                           }
//                       }
//                   }

//                                Rectangle()
//                                    .fill(memberColor)
//                                Group{
//                                    //Circle or Profile Pic
//                                    let frameSize: CGFloat? = 64
//
//                                    if let urlString = myMemberInfo[member].profileImageUrl,
//                                       let url = URL(string: urlString) {
//
//                                        //If there is URL for profile pic, show
//                                        //circle with stroke
//                                        AsyncImage(url: url) {image in
//                                            image
//                                                .resizable()
//                                                .scaledToFill()
//
//                                        } placeholder: {
//                                            //else show loading after user uploads but sending/downloading from database
//                                            ProgressView()
//                                                .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
//                                                .frame(width: frameSize, height: frameSize)
//                                                .background(
//                                                    Circle()
//                                                        .fill(Color.accentColor)
//                                                )
//                                        }
//                                        .clipShape(Circle())
//                                        .frame(width: frameSize, height: frameSize)
//
//                                    } else {
//                                        //if space does not have profile pic, show circle
//                                        Circle()
//                                            .fill(Color.accentColor)
//                                            .clipShape(Circle())
//                                            .frame(width: frameSize, height: frameSize)
//                                    }
//
//
//                                }
