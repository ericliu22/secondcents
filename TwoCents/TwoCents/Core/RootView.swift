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
    
    //@TODO: DEPRECATED CONSIDER REMOVING
    //@State var viewModel = RootViewModel()
    @Environment(AppModel.self) var appModel: AppModel
    
    @State private var userPhoneNumber: String?
    
    var body: some View {
        @Bindable var appModel = appModel
        ZStack {
            FrontPageView()
                .tint(appModel.loadedColor)

        }
//        
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            
          
            
            //            self.showSignInView = authUser == nil
            
            if authUser == nil {
                appModel.activeSheet = .signInView
            }
        }
        
        .fullScreenCover(item: $appModel.activeSheet) { item in
            NavigationStack {
                
                switch item {
                case .signInView:
                  
                    AuthenticationView(userPhoneNumber: $userPhoneNumber)
                case .customizeProfileView:
                    CustomizeProfileView()
                        
                    
                case .verifyCodeView:
                    VerifyCodeView()
                case .signUpPhoneNumberView:
                    SignUpPhoneNumberView(userPhoneNumber: $userPhoneNumber)
                case .addFriendFromContactsView:
                    
                    NavigationView{
                        AddFriendFromContactsView()
                    }
                    
                }
            }
        
        }
        
        
        
        .onChange(of: appModel.activeSheet) { newValue, oldValue in
            Task {
                do {
                    appModel.updateUser()
                } catch {
                    if appModel.activeSheet == nil {
                        appModel.activeSheet = .signUpPhoneNumberView
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
