//
//  ProfileView.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @Binding var loadedColor: Color
    var body: some View {
        Rectangle()
            .frame(width: 100,height: 100)
            .foregroundColor(loadedColor)
        List{
            if let user = viewModel.user {
                if let name = user.name {
                    Text("Name: \(name)")
                }
                
                
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
            ProfileView(showSignInView: .constant(false),loadedColor: .constant(.red))
        }
    }
}
