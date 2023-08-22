//
//  RootView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI

struct RootView: View {
    
    
    @State private var showSignInView: Bool = false
    
    @State private var showCreateProfileView: Bool = false
    
    var body: some View {
        
        ZStack {
            
//                
                FrontPageView(showSignInView: $showSignInView)
     
            
        }
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView, showCreateProfileView: $showCreateProfileView)
            }
        }
        .fullScreenCover(isPresented: $showCreateProfileView, content: {
            CreateProfileView(showCreateProfileView: $showCreateProfileView)
                
        })

        
        
        
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
