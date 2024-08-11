//
//  RootView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI
import Firebase


enum sheetTypes: Identifiable  {
    
    
    
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
    
    @State private var tintLoaded: Bool = false
    @State private var userColor: String = ""
    @State private var loadedColor: Color = .gray
    
    @State private var activeSheet: sheetTypes?
    
    @State private var userPhoneNumber: String?
    
    var body: some View {
        
        ZStack {
            FrontPageView(loadedColor: $loadedColor, activeSheet: $activeSheet)
                .task{
                    
                    try? await viewModel.loadCurrentUser()
                    
                    if let myColor = viewModel.user?.userColor{
                        tintLoaded = true
                        userColor = myColor
                        print("USERCOLOR: \(userColor)")
                        loadedColor = viewModel.getUserColor(userColor: userColor)
                    }
                    
                }
            //                .tint(viewModel.getUserColor(userColor: viewModel.user?.userColor ?? ""))
            
                .tint(tintLoaded ? loadedColor : .gray)
                .animation(.easeIn, value: tintLoaded)
                .background(
                    Group {
                        if shouldNavigateToCanvas {
                            NavigationLink(
                                destination: CanvasPage(spaceId: waitForVariable{spaceId}),
                                isActive: $shouldNavigateToCanvas,
                                label: { EmptyView() }
                            )
                        }
                    }
                )
        }
        
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            //            self.showSignInView = authUser == nil
            
            if authUser == nil {
                activeSheet = .signInView
            } else {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                   self.spaceId = appDelegate.spaceId
                   if spaceId != nil {
                       shouldNavigateToCanvas = true // Trigger navigation if spaceId is present
                   }
               }
            }
        }
        
        .fullScreenCover(item: $activeSheet) { item in
            NavigationStack {
                
                switch item {
                case .signInView:
                  
                    AuthenticationView(activeSheet: $activeSheet, userPhoneNumber: $userPhoneNumber)
                case .customizeProfileView:
                    CustomizeProfileView(activeSheet: $activeSheet, selectedColor: $loadedColor)
                        
                    
                case .verifyCodeView:
                    VerifyCodeView(activeSheet: $activeSheet)
                case .signUpPhoneNumberView:
                    SignUpPhoneNumberView(activeSheet: $activeSheet, userPhoneNumber: $userPhoneNumber)
                case .addFriendFromContactsView:
                    AddFriendFromContactsView(activeSheet:$activeSheet)
                    
                }
            }
        
        }
        
 
        
        
        
        //        .fullScreenCover(isPresented: $showCreateProfileView,  content: {
        //            NavigationStack{
        ////                CustomizeProfileView(showCreateProfileView: $showCreateProfileView, selectedColor: $loadedColor)
        //                CustomizeProfileView(activeSheet: $activeSheet, selectedColor: $loadedColor)
        //            }
        //
        //
        //        })
        
        
        .onChange(of: activeSheet) { oldValue, newValue in
            switch newValue {
     
            case .customizeProfileView:
                Task{
                    try? await viewModel.loadCurrentUser()
                    
                    if let myColor = viewModel.user?.userColor{
                        tintLoaded = true
                        
                        userColor = myColor
                        print("USERCOLOR: \(userColor)")
                        loadedColor = viewModel.getUserColor(userColor: userColor)
                    }
                    
                    
                }
                
            default:
                break
            }
            
    
            
            Task{
                
                do {
                    try await viewModel.loadCurrentUser()
                } catch {
                    if activeSheet == nil{
                        activeSheet = .signUpPhoneNumberView
                        
                        
                        
                        
                    }
                    
                }
            }
            
            switch oldValue  {
                
            case .customizeProfileView:
                Task{
                    
                    try? await viewModel.loadCurrentUser()
                    
                    if let myColor = viewModel.user?.userColor{
                        tintLoaded = true
                        userColor = myColor
                        print("USERCOLOR: \(userColor)")
                        loadedColor = viewModel.getUserColor(userColor: userColor)
                    } else {
                        print("gray")
                    }
                    
                }
                
                
            case .signInView:
                Task{
                    try? await viewModel.loadCurrentUser()
                    
                    if let myColor = viewModel.user?.userColor{
                        withAnimation{
                        tintLoaded = true
                        
                        userColor = myColor
                        print("USERCOLOR: \(userColor)")
                        
                   
                            loadedColor = viewModel.getUserColor(userColor: userColor)
                        }
                    }
                    
                    
                }
                
                
            default:
                break
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
