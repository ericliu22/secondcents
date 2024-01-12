//
//  SabotageSelectionView.swift
//  TwoCents
//
//  Created by Enzo Tanjutco on 12/4/23.
//

import SwiftUI

struct SabotageSelectionView: View {
    @State var currentIndex: Int = 0
    @State var posts: [PostModel] = []
//    var player: DBUser
    
    var playerIndex: Int
    
    var body: some View {
        ZStack{
            
            VStack{
                HStack(spacing: 0){
                }
                
                SabotageCarouselView(index: $currentIndex, playerIndex: playerIndex)
                .padding(.vertical, 40)
                
                HStack(spacing: 10) {
                    ForEach(posts.indices, id: \.self) { index in
                        Circle()
                            .fill(Color.black.opacity(currentIndex == index ? 1 : 0.1))
                            .frame(width: 10, height: 10)
                            .scaleEffect(currentIndex == index ? 1.4 : 1)
                            .animation(.spring(), value: currentIndex == index)
                    }
                }
            }
        }
        .background(
            ZStack{
                Color("SabotageBg")
                    .edgesIgnoringSafeArea(.all)
                Image("enzo-pic")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 1000, height: 1000)
                    .blur(radius: 80)
            }
            )
        .frame(maxWidth: .infinity, alignment: .top)
        .onAppear {
            for index in 1...4 {
                posts.append(PostModel(postImage: "post\(index)"))
//                print("The posts are: \(posts)")
            }
        }
    }
}

#Preview {
    SabotageSelectionView(playerIndex: 0)
}
