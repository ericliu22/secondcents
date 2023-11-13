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
        VStack{
            Text(message.sendBy)
            Text(message.text)
                .background(Color(.green))
                .cornerRadius(30)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//message bubble leading --> other users, same user texted twice
struct messageBubbleSameLead: View{
    var message: Message
    var body: some View{
        Text(message.text).background(Color(.yellow))
            .cornerRadius(30)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//message bubble trailing --> the user/self
struct messageBubbleTrail: View{
    var message: Message
    var body: some View{
        VStack{
            Text(message.sendBy)
            Text(message.text)
                .background(Color(.red))
                .cornerRadius(30)
        }
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct messageBubbleSameTrail: View{
    var message: Message
    var body: some View{
        Text(message.text)
            .background(Color(.orange))
            .cornerRadius(30)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}


