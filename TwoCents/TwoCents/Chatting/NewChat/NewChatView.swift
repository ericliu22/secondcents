//
//  NewChatView.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//

import Foundation
import SwiftUI
import UIKit

struct Message: Identifiable, Codable {
    var id: String
    var sendBy: String
    var text: String?
    var ts: Date
    var parent: String
    var widgetId: String?
}

struct NewChatView: View {
    
    @State var spaceId: String
    
    @StateObject private var viewModel = NewChatViewModel()
    let userUID: String = try! AuthenticationManager.shared.getAuthenticatedUser().uid
    
    var body: some View {
        List {
            ForEach(viewModel.messages, id: \.id) { message in
                ChatBubbleViewBuilder(messageId: message.id, spaceId: spaceId)
                
                if message.id == viewModel.messages.last?.id {
                            if viewModel.hasMoreMessages {
                                Text("LAST: \(message.text)")
                                    .onAppear {
                                        viewModel.getMessages(spaceId: spaceId)
                                        print("loaded more messages")
                                    }
                            } else {
                                Text("Loaded all messages")
                            }
                        }
                
                
                
                
                
            }
        }
        .onAppear {
            viewModel.getMessages(spaceId: spaceId)
//            print(viewModel.messages)
        }
    }
}


struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewChatView(spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E")
        }
    }
}
