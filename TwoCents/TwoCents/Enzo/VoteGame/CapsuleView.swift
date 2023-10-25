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
    @Binding var emptyColor: String
    @Binding var emptyNumVotes: Int

    var selectedPlayer: String
    var selectedImage: String
    var selectedColor: String
    var selectedNumVotes: Int

    var body: some View {

        Capsule()
            .fill(selectedPlayer == emptyPlayer ? Color("enzoGreen") : .white)
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


#Preview {
    CapsuleView(emptyPlayer: .constant(""), emptyImage: .constant(""), emptyColor: .constant(""), emptyNumVotes: .constant(0), selectedPlayer: "enzo", selectedImage: "enzo-pic", selectedColor: "enzoGreen", selectedNumVotes: 2)
}
