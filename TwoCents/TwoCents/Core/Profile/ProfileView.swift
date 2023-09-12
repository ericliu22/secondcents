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
    @State var targetUserColor: Color?
    @Binding var showCreateProfileView: Bool
    
    @State var targetUserId: String
    
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        VStack {
            
            
            
            
            
            
            
            LazyVGrid(columns: columns, spacing: nil) {
                
                VStack {
                    
                    
                    
                    ZStack{
                        
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
                                                .fill(targetUserColor ?? loadedColor)
                                                .frame(width: 128, height: 128)
                                        )
                                }
                                
                            } else {
                                
                                //if user has not uploaded profile pic, show circle
                                Circle()
                                
                                    .strokeBorder(targetUserColor ?? loadedColor, lineWidth:0)
                                    .background(Circle().fill(targetUserColor ?? loadedColor))
                                    .frame(width: 128, height: 128)
                                
                            }
                            
                            if (targetUserId.isEmpty) {
                                ZStack{
                                    
                                    Circle()
                                        .fill(Color(UIColor.systemBackground))
                                        .frame(width: 48, height: 48)
                                    
                                    Circle()
                                        .fill(.thinMaterial)
                                        .frame(width: 48, height: 48)
                                    
                                    Circle()
                                        .fill(targetUserColor ?? loadedColor)
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "plus")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(UIColor.systemBackground))
                                }
                                .offset(x:44, y:44)
                                .onTapGesture{
                                    showCreateProfileView = true
                                    
                                }
                            }
                        }
                    }
                    
                    
                    
                    
                }
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                //                .padding(32)
                .background(.thinMaterial)
                .cornerRadius(20)
                
                
                
                
                
                ///
                
//                VStack{
//
//                    if let user = viewModel.user {
//
//
//
//
//                        if let username = user.name  {
//                            Text("\(username)")
//                                .font(.headline)
//                                .frame(maxWidth:.infinity, maxHeight: .infinity)
//                                .background(.thinMaterial)
//                                .cornerRadius(20)
//                        }
//                    }
//
//
//                        HStack{
//                            Image(systemName: "person.2.fill")
//
//                            Text("Friends")
//
//                        }
//                        .font(.headline)
//                        .fontWeight(.regular)
//
//                        .frame(maxWidth:.infinity, maxHeight: .infinity)
//                        .background(.thinMaterial)
//                        .cornerRadius(20)
//
//
//
//
//                }
//
//
                
                
                
                VStack{
                    if let user = viewModel.user {
                        
                        if let name = user.name  {
                            Text("\(name)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(targetUserColor ?? loadedColor)
                        }
                        

                       if let username = user.username  {
                           Text("@\(username)")
                               .font(.headline)
                               .fontWeight(.regular)
                               
                       }
                   }

                    
                }
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .background(.thinMaterial)
                .cornerRadius(20)
                
                
                
                
                VStack{
                    Text("15")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Friends")
                        .font(.headline)
                        .fontWeight(.regular)
                    
                }
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .background(.thinMaterial)
                .cornerRadius(20)
                
                
                
                
                
                RoundedRectangle(cornerRadius: 20)
                    .aspectRatio(1, contentMode: .fit)
                
                
                RoundedRectangle(cornerRadius: 20)
                    .aspectRatio(1, contentMode: .fit)
                
                
                
                
            }
            .padding()
            
            
            
            
            Spacer()
            
            
            
            
            
        }
        .task{
            
            targetUserId.isEmpty ?
            try? await viewModel.loadCurrentUser() :
            try? await viewModel.loadTargetUser(targetUserId: targetUserId)
            
        }
        .navigationTitle("Profile")
        .toolbar{
            if (targetUserId.isEmpty) {
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
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(showSignInView: .constant(false),loadedColor: .constant(.red),showCreateProfileView: .constant(false), targetUserId: "")
        }
    }
}
