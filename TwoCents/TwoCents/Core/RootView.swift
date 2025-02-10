//
//  RootView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI
import FirebaseFirestore


enum PopupSheet: Identifiable, Equatable {
    case customizeProfileView
    case signInView
    case verifyCodeView
    case signUpPhoneNumberView
    case addFriendFromContactsView
    case joinSpaceView(spaceId: String, spaceToken: String)
    
    var id: String {
        switch self {
        case .customizeProfileView:
            return "customizeProfileView"
        case .signInView:
            return "signInView"
        case .verifyCodeView:
            return "verifyCodeView"
        case .signUpPhoneNumberView:
            return "signUpPhoneNumberView"
        case .addFriendFromContactsView:
            return "addFriendFromContactsView"
        case .joinSpaceView(let spaceId, let spaceToken):
            return "joinSpaceView-\(spaceId)-\(spaceToken)"
        }
    }
    
    static func == (lhs: PopupSheet, rhs: PopupSheet) -> Bool {
        switch (lhs, rhs) {
        case (.customizeProfileView, .customizeProfileView),
             (.signInView, .signInView),
             (.verifyCodeView, .verifyCodeView),
             (.signUpPhoneNumberView, .signUpPhoneNumberView),
             (.addFriendFromContactsView, .addFriendFromContactsView):
            return true
        case let (.joinSpaceView(lhsSpaceId, lhsSpaceToken), .joinSpaceView(rhsSpaceId, rhsSpaceToken)):
            return lhsSpaceId == rhsSpaceId && lhsSpaceToken == rhsSpaceToken
        default:
            return false
        }
    }
}

struct RootView: View {
    
    
    //    @State private var showSignInView: Bool = false
    //
    //    @State private var showCreateProfileView: Bool = false
    
    //@TODO: DEPRECATED CONSIDER REMOVING
    //@State var viewModel = RootViewModel()
    @Environment(AppModel.self) var appModel
    
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
        .overlay {
            VStack {
                InAppNotification()
            }.frame(maxHeight: .infinity, alignment: .top)
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
                case .joinSpaceView(let spaceId, let spaceToken):
                    JoinSpaceView(spaceId: spaceId, spaceToken: spaceToken)
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
