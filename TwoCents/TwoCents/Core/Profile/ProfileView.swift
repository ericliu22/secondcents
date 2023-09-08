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
    @Binding var showCreateProfileView: Bool
    var body: some View {
        //        Rectangle()
        //            .frame(width: 100,height: 100)
        //            .foregroundColor(loadedColor)
        //        List{
        //            if let user = viewModel.user {
        //                if let name = user.name {
        //                    Text("Name: \(name)")
        //                }
        //
        //
        //                if let email = user.email {
        //                    Text("Email: \(email)")
        //                }
        //
        //
        //
        //                Text("UserId: \(user.userId)")
        //
        //
        //
        //            }
        //
        //
        
        
        VStack {
            
            VStack {
                
                
                
         
                    
                    Group{
                        //Circle or Profile Pic
                        
                        
                        if let urlString = viewModel.user?.profileImageUrl,
                           let url = URL(string: urlString) {
                            
                            
                            
                            //If there is URL for profile pic, show
                            //circle with stroke
                            AsyncImage(url: url) {image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 128, height: 128)
                                
                                
                                
                            } placeholder: {
                                //else show loading after user uploads but sending/downloading from database
                                
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                //                            .scaleEffect(1, anchor: .center)
                                    .frame(width: 128, height: 128)
                                    .background(
                                        Circle()
                                            .fill(loadedColor)
                                            .frame(width: 128, height: 128)
                                    )
                            }
                            
                        } else {
                            
                            //if user has not uploaded profile pic, show circle
                            Circle()
                            
                                .strokeBorder(loadedColor, lineWidth:0)
                                .background(Circle().fill(loadedColor))
                                .frame(width: 128, height: 128)
                            
                        }
                    }
                    
                    .onTapGesture{
                        showCreateProfileView = true
                        
                    }
                    
                    
                    Spacer()
                        .frame(height: 15)
                    
                    if let user = viewModel.user {
                        if let name = user.name {
                            Text("\(name)")
                                .font(.headline)
                            
                        }
                        
                        
                        if let username = user.username  {
                            Text("@\(username)")
                                .font(.caption)
                               
                            
                        }
                    }
                    
                    
                    
                    
                }

                .padding(32)
                .background(.thinMaterial)
                .cornerRadius(20)
              
                
                
                
                
              
               
         
            
            
            
            Spacer()
            
            
            
            
            
            
            
            
            
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
            ProfileView(showSignInView: .constant(false),loadedColor: .constant(.red),showCreateProfileView: .constant(false))
        }
    }
}
