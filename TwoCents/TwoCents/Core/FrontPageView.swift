//
//  FrontPageView.swift
//  TwoCents
//
//  Created by jonathan on 8/16/23.
//

import SwiftUI

struct FrontPageView: View {
    
    @Binding var showSignInView: Bool
    var body: some View {
        TabView{
            UploadExample()
                .tabItem {
                    Image(systemName: "house")
                    Text("Page 1")
                }
            ColorSelectionView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Color Picker")
                }
            CreateProfileView(showSignInView: $showSignInView )
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
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
                
                
            }
         
            
            
            
        }
        .tint(Color(UIColor.label))
        
    }
}

struct FrontPageView_Previews: PreviewProvider {
    
    static var previews: some View {
        FrontPageView(showSignInView: .constant(false))
    }
}
