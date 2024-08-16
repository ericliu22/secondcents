//
//  SettingsView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
//    @Binding var showSignInView: Bool
    @Binding var activeSheet: sheetTypes?
    var body: some View {
        List{
            
            
//            emailSection

            
            
            Section {
                
               
                Button("Customize Profile"){
                    Task {
                        do{
                          
                            
                            activeSheet  = .customizeProfileView
                        }  catch {
                            print(error)
                        }
                    }
                    
                    
                }
                
                
                
                NavigationLink(destination: ContactsView()) {
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
                        
                        activeSheet  = .signInView
                    }  catch {
                        print(error)
                    }
                }
                
                
            }
            .navigationBarTitle("Settings ⚙️")
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
//            SettingsView(showSignInView: .constant(false))
            
            SettingsView(activeSheet: .constant(nil))
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
