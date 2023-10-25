//
//  ResultView.swift
//  TwoCents
//
//  Created by jonathan on 10/25/23.
//

import SwiftUI


struct ResultView: View {
    var playerName: String
    var playerImage: String
    var playerColor: String
    var playerVotes: Int
    var body: some View {

        ZStack{
            Color(playerColor)
                .edgesIgnoringSafeArea(.all)
            VStack{
                Image(playerImage)
                Text(playerName)
                    .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: 36))
                Rectangle()
                    .fill(Color(playerColor))
                Text("Number of Votes: \(playerVotes)")
                    .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: 24))
            }
        }
    }
}



#Preview {
    ResultView(playerName: "enzo", playerImage: "enzo-pic", playerColor: "enzoGreen", playerVotes: 2)
}
