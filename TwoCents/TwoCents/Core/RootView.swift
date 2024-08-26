//
//  RootView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI
import Firebase


enum PopupSheet: Identifiable  {
    
    
    
    case customizeProfileView, signInView, verifyCodeView, signUpPhoneNumberView, addFriendFromContactsView
    
    var id: Self {
        return self
    }
    
}




struct RootView: View {
    
    
    //    @State private var showSignInView: Bool = false
    //
    //    @State private var showCreateProfileView: Bool = false
    
    var viewModel = RootViewModel()
    @Environment(AppModel.self) var appModel
    
    @State private var tintLoaded: Bool = false
    @State private var userColor: String = ""
    
    @State private var activeSheet: PopupSheet?
    
    @State private var userPhoneNumber: String?
    
    var body: some View {
        
        ZStack {
            FrontPageView(activeSheet: $activeSheet)
            //                .tint(viewModel.getUserColor(userColor: viewModel.user?.userColor ?? ""))
                .tint(appModel.loadedColor)
                .animation(.easeIn, value: tintLoaded)

        }
//        
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            //            self.showSignInView = authUser == nil
            
            if authUser == nil {
                activeSheet = .signInView
            }
        }
        
        .fullScreenCover(item: $activeSheet) { item in
            NavigationStack {
                
                switch item {
                case .signInView:
                  
                    AuthenticationView(activeSheet: $activeSheet, userPhoneNumber: $userPhoneNumber)
                case .customizeProfileView:
                    CustomizeProfileView(activeSheet: $activeSheet)
                        
                    
                case .verifyCodeView:
                    VerifyCodeView(activeSheet: $activeSheet)
                case .signUpPhoneNumberView:
                    SignUpPhoneNumberView(activeSheet: $activeSheet, userPhoneNumber: $userPhoneNumber)
                case .addFriendFromContactsView:
                    
                    NavigationView{
                        AddFriendFromContactsView(activeSheet:$activeSheet)
                    }
                    
                }
            }
        
        }
        
        //        .fullScreenCover(isPresented: $showCreateProfileView,  content: {
        //            NavigationStack{
        ////                CustomizeProfileView(showCreateProfileView: $showCreateProfileView, selectedColor: $appModel.loadedColor)
        //                CustomizeProfileView(activeSheet: $activeSheet, selectedColor: $appModel.loadedColor)
        //            }
        //
        //
        //        })
        
        
        .onChange(of: activeSheet) { newValue, oldValue in
            Task {
                do {
                    try await viewModel.loadCurrentUser()
                } catch {
                    if activeSheet == nil {
                        activeSheet = .signUpPhoneNumberView
                    }
                }
            }
        }
      
        
        
    }
}

@ViewBuilder func navigation() -> some View {
    
}

/*
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

*/
