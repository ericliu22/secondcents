//
//  FrontPageView.swift
//  TwoCents
//
//  Created by jonathan on 8/16/23.
//

import SwiftUI

struct FrontPageView: View {
    
   
    
    @Binding var showSignInView: Bool
    @Binding var loadedColor: Color
    @Binding var showCreateProfileView: Bool
    
    
    var body: some View {
        TabView{
//            UploadExample()
            VoteGameView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Vote Game")
                    
                }
            chattingView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Chatting View")
                    
                }
            
            
            SearchUserView(showSignInView: $showSignInView, loadedColor: $loadedColor, showCreateProfileView: $showCreateProfileView, targetUserId: "")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            CanvasPage(chatroom: db.collection("Chatrooms").document("ChatRoom1"))
                .tabItem {
                    Image(systemName: "house")
                    Text("Canvas Page")
                }
            SpacesView(showSignInView: $showSignInView, loadedColor: $loadedColor, showCreateProfileView: $showCreateProfileView)
                .tabItem {
                    Image(systemName: "rectangle.3.group.fill")
                    Text("Spaces")
                }
            
            
            
            NavigationStack {
                ProfileView(showSignInView: $showSignInView, loadedColor: $loadedColor, showCreateProfileView: $showCreateProfileView, targetUserId: "")
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
                
                
            }
            
        }
        

        
       
        
        
        
    }
}

struct FrontPageView_Previews: PreviewProvider {
    
    static var previews: some View {
        FrontPageView(showSignInView: .constant(false), loadedColor: .constant(.red),showCreateProfileView: .constant(false))
    }
}
