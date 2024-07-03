//
//  NewChatView.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//

import Foundation
import SwiftUI
import UIKit

struct Message: Identifiable, Codable,Equatable {
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
    let userUID: String = (try? AuthenticationManager.shared.getAuthenticatedUser().uid) ?? ""

    var body: some View {
        ScrollViewReader { proxy in
            List {
             
                
                ForEach(viewModel.messages, id: \.id) { message in
                    if message.id == viewModel.messages.last?.id {
                        if viewModel.hasMoreMessages {
                            ProgressView()
                                .onAppear {
                                    viewModel.getMessages(spaceId: spaceId)
                               
                                    
                                }
                                .frame(maxWidth:.infinity)
                            

                        }
                    }
                    
                    ChatBubbleViewBuilder(messageId: message.id, spaceId: spaceId, currentUserId: userUID)
                        .id(message.id)  // Ensure each message has a unique ID
                        .rotationEffect(.degrees(180))
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .animation(nil)
            .padding(.horizontal)
         
            .rotationEffect(.degrees(180))
            .listStyle(PlainListStyle())
            .onAppear {
                viewModel.getMessages(spaceId: spaceId)
            }
//            .ignoresSafeArea()
            .scrollIndicators(.hidden)
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


