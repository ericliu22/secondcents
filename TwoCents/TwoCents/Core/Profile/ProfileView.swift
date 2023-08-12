//
//  ProfileView.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        List{
            if let user = viewModel.user {
                
                if let email = user.email {
                    Text("Email: \(email)")
                }
                
                Text("UserId: \(user.userId)")
                
                
            
            }
            
           
            
            
           
        }
        .task{
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink{
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image (systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(showSignInView: .constant(false))
        }
    }
}
