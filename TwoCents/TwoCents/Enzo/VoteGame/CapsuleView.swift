//
//  CapsuleView.swift
//  TwoCents
//
//  Created by jonathan on 10/25/23.
//

import SwiftUI



struct CapsuleView: View {
    @Binding var emptyPlayer: String
    @Binding var emptyImage: String
    @Binding var emptyColor: Color
    @Binding var emptyNumVotes: Int

    var selectedPlayer: String
    var selectedImage: String
    var selectedColor: Color
    var selectedNumVotes: Int
    
    var member: PlayerData

    var body: some View {

        Capsule()
            .fill(selectedPlayer == emptyPlayer ? Color(selectedColor) : .white)
            .onTapGesture {
                withAnimation(.spring()){
                    emptyPlayer = selectedPlayer
                    emptyImage = selectedImage
                    emptyColor = selectedColor
                    emptyNumVotes = selectedNumVotes
                }
            }
    }
}


//#Preview {
//    CapsuleView(emptyPlayer: .constant(""), emptyImage: .constant(""), emptyColor: .green, emptyNumVotes: .constant(0), selectedPlayer: "enzo", selectedImage: "enzo-pic", selectedColor: .green, selectedNumVotes: 2)
//}
