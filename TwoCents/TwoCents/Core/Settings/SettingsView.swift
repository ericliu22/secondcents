//
//  SettingsView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(AppModel.self) var appModel
//    @Binding var showSignInView: Bool
    var body: some View {
        List{
            
            
//            emailSection

            
            
            Section {
                
               
                Button("Customize Profile"){
                    Task {
                        do{
                          
                            
                            appModel.activeSheet  = .customizeProfileView
                        }  catch {
                            print(error)
                        }
                    }
                    
                    
                }
                
             
                
                NavigationLink(destination:   AddFriendFromContactsView()) {
                    Text("Contacts")
                        .foregroundColor(Color.accentColor)
                }
                
            } header: {
                Text("Personal Details")
            }
            
            
            
            Button("Log Out"){
                Task {
                    do{
                        try viewModel.signOut()
//                        showSignInView = true
                        
                        appModel.activeSheet  = .signInView
                    }  catch {
                        print(error)
                    }
                }
                
                
            }
            .navigationBarTitle("Settings ⚙️")
        }
        
    }
}


extension SettingsView {
    private var emailSection: some View {
        Section {
            Button("Update Email"){
                Task {
                    do{
                        try await viewModel.updateEmail()
                        
                    }  catch {
                        
                        print(error)
                    }
                }
                
            }
            
            Button("Update Password"){
                Task {
                    do{
                        try await viewModel.updatePassword()
                    }  catch {
                        print(error)
                    }
                }
                
            }
            
            
            Button("Reset Password"){
                Task {
                    do{
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET")
                    }  catch {
                        print(error)
                    }
                }
                
            }
        } header: {
            Text("Password & Security")
        }
    }
}

/*
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
//            SettingsView(showSignInView: .constant(false))
            
            SettingsView(appModel.activeSheet: .constant(nil))
        }
    }
}
 */
