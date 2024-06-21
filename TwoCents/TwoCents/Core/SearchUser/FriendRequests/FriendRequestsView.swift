//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct FriendRequestsView: View {
    @Binding var activeSheet: sheetTypes?
//    @Binding var showSignInView: Bool
    @Binding var loadedColor: Color
//    @Binding var showCreateProfileView: Bool
    

    @State var targetUserId: String
    
    @State private var searchTerm = ""
    
    
    
    @StateObject private var viewModel = FriendRequestsViewModel()
    
    private let noFriendsMessage: [String] = [
        "it's getting dry 😬",
        "no friends 🫵😂"
    ]
    
    
    var filteredSearch: [DBUser]{
        guard !searchTerm.isEmpty else { return viewModel.allRequests}
        return viewModel.allRequests.filter{$0.name!.localizedCaseInsensitiveContains(searchTerm) || $0.username!.localizedCaseInsensitiveContains(searchTerm)}
    }
    var body: some View {
        //        VStack {
        //            ForEach(viewModel.images, id: \.id) { item in
        //                Text("URL: \(item.url)")
        //                Text("Quote: \(item.quote)")
        //            }
        //        }.onAppear { viewModel.fetchData() }
        
//        if viewModel.allRequests.count == 0 {
//            
//            Text(noFriendsMessage[Int.random(in: 0..<(noFriendsMessage.count))])
//                .font(.headline)
//                .fontWeight(.regular)
//            
//            
//        } else {
        
            NavigationStack{
                
                List{
                    
                   
                    
                    ForEach(filteredSearch) { userTile    in
                        let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                        
                        
                        
                        NavigationLink  {
                            
//                            ProfileView(showSignInView: $showSignInView, loadedColor: $loadedColor,targetUserColor: targetUserColor, showCreateProfileView: $showCreateProfileView, targetUserId: userTile.userId)
                            
                            ProfileView(activeSheet:$activeSheet, loadedColor: $loadedColor,targetUserColor: targetUserColor, targetUserId: userTile.userId)
                        } label: {
                            HStack(spacing: 20){
                                
                                
                                Group{
                                    //Circle or Profile Pic
                                    
                                    if let urlString = userTile.profileImageUrl,
                                       let url = URL(string: urlString) {
                                        
                                        //If there is URL for profile pic, show
                                        //circle with stroke
                                        AsyncImage(url: url) {image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                                .frame(width: 64, height: 64)
                                            
                                        } placeholder: {
                                            //else show loading after user uploads but sending/downloading from database
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                            //                            .scaleEffect(1, anchor: .center)
                                                .frame(width: 64, height: 64)
                                                .background(
                                                    Circle()
                                                        .fill(targetUserColor)
                                                        .frame(width: 64, height: 64)
                                                )
                                        }
                                        
                                    } else {
                                        
                                        //if user has not uploaded profile pic, show circle
                                        Circle()
                                        
                                            .strokeBorder(targetUserColor, lineWidth:0)
                                            .background(Circle().fill(targetUserColor))
                                            .frame(width: 64, height: 64)
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                                
                                VStack(alignment: .leading){
                                    
                                    
                                    Text(userTile.name!)
                                        .font(.headline)
                                    
                                    
                                    Text(
                                        "@\(userTile.username!)")
                                    .font(.caption)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    
                                    HStack{
                                        Button {
                                            viewModel.acceptFriendRequest(friendUserId: userTile.userId)
                                            
                                            Task{
                                                //reload requests list
                                                try? await viewModel.getAllRequests(targetUserId: targetUserId)
                                            }
                                            
                                            
                                        } label: {
                                            Text("Accept")
                                                .font(.caption)
                                            
                                            
                                                .frame(maxWidth: .infinity)
                                            
                                        }
                                        .tint(.green)
                                        .buttonStyle(.bordered)
                                        .cornerRadius(10)
                                        
                                        
                                        Button {
                                            
                                            viewModel.declineFriendRequest(friendUserId: userTile.userId)
                                            
                                        } label: {
                                            Text("Decline")
                                                .font(.caption)
                                            
                                            
                                                .frame(maxWidth: .infinity)
                                            
                                        }
                                        .tint(.gray)
                                        .buttonStyle(.bordered)
                                        .cornerRadius(10)
                                    }
                                    
                                }
                                
                                
                                
                                
                            }
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }
                .listStyle(PlainListStyle())
                
                .navigationTitle("Friend Requests ✨")
                .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
                
            }
            .task {
                
                try? await viewModel.getAllRequests(targetUserId: targetUserId)
            }
//        }
        
    }
}

struct FriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
//        FriendRequestsView(showSignInView: .constant(false),loadedColor: .constant(.red),showCreateProfileView: .constant(false), targetUserId: "")
        FriendsView(activeSheet: .constant(nil), loadedColor: .constant(.red), targetUserId: "")
    }
}
