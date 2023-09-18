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
            UploadExample()
                .tabItem {
                    Image(systemName: "house")
                    Text("Page 1")
                    
                }
            SearchUserView(showSignInView: $showSignInView, loadedColor: $loadedColor, showCreateProfileView: $showCreateProfileView, friendsOnly: false, targetUserId: "")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            ColorSelectionView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Page 3")
                }
            ColorSelectionView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Page 4")
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
