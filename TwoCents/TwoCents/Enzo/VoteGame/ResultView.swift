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
    var playerColor: Color
    var playerVotes: Int
    
    var urlString: String
    var frameSize: CGFloat? = 200
    
    
    var body: some View {

        ZStack{
            Color(playerColor)
                .edgesIgnoringSafeArea(.all)
            VStack{
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
    ResultView(playerName: "enzo", playerImage: "enzo-pic", playerColor: .green, playerVotes: 2, urlString: "enzo-pic")
}
