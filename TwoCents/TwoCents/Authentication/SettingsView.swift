//
//  SettingsView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI
@MainActor
final class SettingsViewModel: ObservableObject{
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        //NEED TO CHANGE TO BE IN BRACKET ABOVE. BUT NEED TO IMPLEMENT UI
        let email = "123"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        
        let password = "123"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        List{
            
            
            emailSection

            
            Button("Log Out"){
                Task {
                    do{
                        try viewModel.signOut()
                        showSignInView = true
                    }  catch {
                        print(error)
                    }
                }
                
                
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SettingsView(showSignInView: .constant(false))
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
            Text("Email Functions")
        }
    }
}
