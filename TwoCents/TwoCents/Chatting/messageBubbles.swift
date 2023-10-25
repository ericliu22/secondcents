//
//  MessageBubbles.swift
//  TwoCents
//
//  Created by Joshua Shen on 9/25/23.
//

import Foundation
import UIKit
import SwiftUI

//message bubble leading --> other users
struct messageBubbleLead: View{
    var message: Message
    var body: some View{
        Text(message.sendBy)
        Text(message.text).background(Color(.red))
    }
}

//message bubble leading --> other users, same user texted twice
struct messageBubbleSameLead: View{
    var message: Message
    var body: some View{
        Text(message.text).background(Color(.yellow))
    }
}

//message bubble trailing --> the user/self
struct messageBubbleTrail: View{
    var message: Message
    var body: some View{
        Text(message.text).background(Color(.green))
    }
}

struct messageBubbleSameTrail: View{
    var message: Message
    var body: some View{
        Text(message.text).background(Color(.blue))
    }
}


