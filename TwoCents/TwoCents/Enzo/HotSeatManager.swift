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
}

let playerData: [PlayerData] = [
    PlayerData(name: "enzobenzoferrari", image: "enzo-pic", color: "enzoGreen", numVotes: 2),
    PlayerData(name: "GOAT", image: "josh-pic", color: "joshOrange", numVotes: 3),
    PlayerData(name: "mlgxd420", image: "jonathan-pic", color: "jonathanBlue", numVotes: 0),
    PlayerData(name: "daddy", image: "eric-pic", color: "ericPurple", numVotes: 100),
]

class HotSeatManager: ObservableObject{
    @Published var onHotSeat = true
}

