//
//  FrontPageView.swift
//  TwoCents
//
//  Created by jonathan on 8/16/23.
//

import SwiftUI

struct FrontPageView: View {
    
   
    
//    @Binding var showSignInView: Bool
    @Binding var loadedColor: Color
//    @Binding var showCreateProfileView: Bool
    @Binding var activeSheet: sheetTypes?
    
    var body: some View {
        TabView{
//            UploadExample()
            
//            SpacesView(showSignInView: $showSignInView, loadedColor: $loadedColor, showCreateProfileView: $showCreateProfileView)
            SpacesView(activeSheet: $activeSheet, loadedColor: $loadedColor)
                .tabItem {
                    Image(systemName: "rectangle.3.group.fill")
                    Text("Spaces")
                }

            AddFriendFromContactsView(activeSheet: $activeSheet)
                .tabItem {
                    Image(systemName: "rectangle.3.group.fill")
                    Text("test")
                }
            
//            VoteGameView()
//                .tabItem {
//                    Image(systemName: "house")
//                    Text("Vote Game")
//                    
//                }
//            ChatView()
//                .tabItem {
//                    Image(systemName: "house")
//                    Text("Chatting View")
//                    
//                }
//            
            
//            SearchUserView(showSignInView: $showSignInView, loadedColor: $loadedColor, showCreateProfileView: $showCreateProfileView, targetUserId: "")
            SearchUserView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserId: "")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
//            CanvasPage(spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F")
//                .tabItem {
//                    Image(systemName: "house")
//                    Text("Canvas Page")
//                }
//     
            
            
            NavigationStack {
//                ProfileView(showSignInView: $showSignInView, loadedColor: $loadedColor, showCreateProfileView: $showCreateProfileView, targetUserId: "")
                ProfileView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserId: "")
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
//        FrontPageView(showSignInView: .constant(false), loadedColor: .constant(.red),showCreateProfileView: .constant(false))
        FrontPageView(loadedColor: .constant(.red), activeSheet: .constant(nil))
    }
}
