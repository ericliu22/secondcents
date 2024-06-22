//
//  ProfileView.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import SwiftUI

struct ProfileView: View {
    @Binding var activeSheet: sheetTypes?
    @StateObject private var viewModel = ProfileViewModel()
//    @Binding var showSignInView: Bool
    @Binding var loadedColor: Color
    @State var targetUserColor: Color?
//    @Binding var showCreateProfileView: Bool
    
    @State var targetUserId: String
    
    
    
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        VStack {
            //for padding
            VStack{
                HStack{
                    VStack {
                        ZStack{
                            
                            Group{
                                //Circle or Profile Pic
                                //
                                //
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
                                            .progressViewStyle(
                                                CircularProgressViewStyle(tint:
                                                                            Color(UIColor.systemBackground)
                                                                          
                                                                         )
                                            )
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
                                    
                                    
                                        .background(Circle().fill(targetUserColor ?? loadedColor))
                                        .frame(width: 128, height: 128)
                                    
                                    
                                }
                                //
                                
                                //
                                //
                                
                                if (targetUserId.isEmpty) {
                                    ZStack{
                                        Circle()
                                        
                                            .fill(targetUserColor ?? loadedColor)
                                        
                                            .frame(width: 48, height: 48)
                                        
                                        Circle()
                                            .fill(.thickMaterial)
                                            .scaleEffect(1.015)
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
//                                        showCreateProfileView = true
                                        activeSheet = .customizeProfileView
                                        
                                    }
                                }
                            }
                        }
                        
                        
                        
                        
                    }
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                    //                .aspectRatio(1, contentMode: .fit)
                    //                    .background(.thinMaterial)
                    //                    .cornerRadius(20)
                    
                    
                    
                    VStack{
                        if let user = viewModel.user {
                            
                            if let name = user.name  {
                                Text("\(name)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(targetUserColor ?? loadedColor)
                                
                                
                                //protects text overflow
                                    .padding([.leading, .trailing],nil)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                            }
                            
                            
                            if let username = user.username  {
                                Text("@\(username)" )
//                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .foregroundStyle(.secondary)
                                
                                    .font(.headline)
                                
                                    .fontWeight(.regular)
                                
                                //protects text overflow
                                    .padding([.leading, .trailing],nil)
                                //                                .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                
                                
                                
                            }
                        }
                        
                        
                    }
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                    //                .aspectRatio(1, contentMode: .fit)
                    //                    .background(.thinMaterial)
                    //                    .cornerRadius(20)
                }
                
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .aspectRatio(2, contentMode: .fit)
                .background(.thickMaterial)
                .background(targetUserColor ?? loadedColor)
                
                .cornerRadius(20)
                //            .padding([.bottom], 0)
                //            .padding([.top, .leading, .trailing], nil)
                
                
                
                
                
                
                LazyVGrid(columns: columns, spacing: nil) {
                    
                    
                    
                    
                    VStack{
                        
                        
                        
                        NavigationLink {
//                            FriendsView(showSignInView: $showSignInView, loadedColor: $loadedColor, showCreateProfileView: $showCreateProfileView, targetUserId: viewModel.user?.userId ?? "")
                            FriendsView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserId: viewModel.user?.userId ?? "")
                        } label: {
                            
                            VStack{
                                if let user = viewModel.user {
                                    if let friends = user.friends{
                                        Text(String(friends.count))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(targetUserColor ?? loadedColor)
                                        
                                        Text(friends.count == 1 ? "Friend" : "Friends")
                                            .font(.headline)
                                            .fontWeight(.regular)
                                        
                                    }
                                }
                            }
                            .foregroundColor(Color(UIColor.label))
                            .frame(maxWidth:.infinity, maxHeight: .infinity)
                            .background(.thinMaterial)
                            .cornerRadius(20)
                            
                        }
                        
                        
                        if targetUserId.isEmpty {
                            
                            NavigationLink {
//                                FriendRequestsView(showSignInView: $showSignInView, loadedColor: $loadedColor, showCreateProfileView: $showCreateProfileView, targetUserId: viewModel.user?.userId ?? "")
                                
                                FriendRequestsView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserId: viewModel.user?.userId ?? "")
                            } label: {
                                
                                VStack{
                                    if let user = viewModel.user {
                                        if let incomingFriendRequests = user.incomingFriendRequests{
                                            
                                            if incomingFriendRequests.count == 0 {
                                                Label("No Requests",
                                                      systemImage: "person.crop.rectangle.stack")
                                                
                                                .font(.headline)
                                                .fontWeight(.regular)
//                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                                .foregroundStyle(.secondary)
                                            } else {
                                                
                                                Label(incomingFriendRequests.count == 1
                                                      ? String(incomingFriendRequests.count)  +   " Request"
                                                      : String(incomingFriendRequests.count)  +    " Requests",
                                                      systemImage: "person.crop.rectangle.stack")
                                                
                                                .font(.headline)
                                                .fontWeight(.regular)
                                                .foregroundColor(loadedColor)
                                                
                                            }
                                        }
                                    }
                                }
                                .foregroundColor(Color(UIColor.label))
                                .frame(maxWidth:.infinity, maxHeight: .infinity)
                                .background(.thinMaterial)
                                .cornerRadius(20)
                                
                            }
                            
                            
                        } else {
                            if  viewModel.isFriend != nil, viewModel.requestSent != nil, viewModel.requestedMe != nil {
                                Button {
                                    
                                    if viewModel.isFriend!{
                                        viewModel.removeFriend(friendUserId: targetUserId)
                                    } else {
                                        if viewModel.requestedMe! {
                                            viewModel.acceptFriendRequest(friendUserId: targetUserId)
                                            
                                        } else {
                                            viewModel.requestSent!
                                            ? viewModel.unsendFriendRequest(friendUserId: targetUserId)
                                            : viewModel.sendFriendRequest(friendUserId: targetUserId)
                                        }
                                    }
                                    
                                    
                                    
                                } label: {
                                    
                                    
                                    HStack{
                                        
                                        
                              
                                        
                                        if viewModel.isFriend!{
                                            
                                            Label("Friended", systemImage: "person.crop.circle.badge.checkmark")
                                            
                                        } else {
//                                                    let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                                            if viewModel.requestedMe! {
                                                
                                                
                                                Label("Accept Request", systemImage: "person.badge.plus")
                                                
                                                
                                            } else {
                                                
                                                
                                                viewModel.requestSent!
                                                ? Label("Request Sent", systemImage: "paperplane")
                                                
                                                : Label("Add Friend", systemImage: "person.badge.plus")
                                                
                                            }
                                        }
                                
                                
                                
                                        
                                        
                                        
                                        
                                    }
                                    
                                    .font(.headline)
                                    .fontWeight(.regular)
                                    .tint(targetUserColor ?? loadedColor)
                                    //                                    .animation(.easeInOut, value: viewModel.isFriend!)
                                    .animation(nil, value: viewModel.isFriend!)
                                    .animation(nil, value: viewModel.requestSent!)
                                    
                                    
                                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                                    .background(.thinMaterial)
                                  
                                    
                                    .cornerRadius(20)
                                    
                                }
                                
                            }
                            
                            
                            
                            
                            
                        }
                        
                        
                    }
                    .aspectRatio(1, contentMode: .fit)
                    
                    
                    
                    
                    
                    
                    VStack {
                        if let user = viewModel.user, let dateCreated = user.dateCreated {
                            // Calculate user's age in days
                            let calendar = Calendar.current
                            let currentDate = Date()
                            
                            if let userAge = calendar.dateComponents([.day], from: dateCreated, to: currentDate).day {
                                Text(userAge == 1 ? "\(userAge) day" : "\(userAge) days")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.secondary)
                                
                                Text("of adventure")
                                    .font(.headline)
                                    .fontWeight(.regular)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                                
                            }
                        }
                    }


           
                
                
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(.thickMaterial)
             
                
                .cornerRadius(20)
                
//                
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(.thinMaterial)
//                        .aspectRatio(1, contentMode: .fit)
//                    
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                        .aspectRatio(1, contentMode: .fit)
                    
                    
                    
                    
                }
                //            .padding()
                
                
                
            }
            .padding()
            
            Spacer()
            
            
            
            
            
        }
        
        .task{
            
            targetUserId.isEmpty ?
            try? await viewModel.loadCurrentUser() :
            try? await viewModel.loadTargetUser(targetUserId: targetUserId)
            
            viewModel.checkFriendshipStatus()
            viewModel.checkRequestStatus()
            viewModel.checkRequestedMe()
            
            
        }
        .navigationTitle("Profile 🤠")
        .toolbar{
            if (targetUserId.isEmpty) {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink{
//                        SettingsView(showSignInView: $showSignInView)
                        
                        SettingsView(activeSheet: $activeSheet)
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
//            ProfileView(showSignInView: .constant(false),loadedColor: .constant(.red),showCreateProfileView: .constant(false), targetUserId: "")
            ProfileView(activeSheet: .constant(nil), loadedColor: .constant(.red), targetUserId: "")
        }
    }
}
