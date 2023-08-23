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
    
    @StateObject private var viewModel = RootViewModel()
    
    @State private var tintLoaded: Bool = false
    @State private var userColor: String = ""
    
    
    

       
    
    var body: some View {
        
        ZStack {
            
            
            
//                
                FrontPageView(showSignInView: $showSignInView)
                .task{
                    try? await viewModel.loadCurrentUser()
                    
                    if let myColor = viewModel.user?.userColor{
                        tintLoaded = true
                        userColor = myColor
                        print(userColor)
                    }
                   
                   
                    
                }
              
              
//                .tint(viewModel.getUserColor(userColor: viewModel.user?.userColor ?? ""))
            
                .tint(tintLoaded ? viewModel.getUserColor(userColor: userColor) : .gray)
                .animation(.easeIn, value: tintLoaded)
            
            
                
            
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
        .fullScreenCover(isPresented: $showCreateProfileView,  content: {
            NavigationStack{
                CustomizeProfileView(showCreateProfileView: $showCreateProfileView)
            }
            
                
        })
        .onChange(of: showCreateProfileView) { newValue in
            Task{
                try? await viewModel.loadCurrentUser()
                
                if let myColor = viewModel.user?.userColor{
                    tintLoaded = true
                    
                    userColor = myColor
                    print(userColor)
                }
               
                
            }
        }
        

        
        
        
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
