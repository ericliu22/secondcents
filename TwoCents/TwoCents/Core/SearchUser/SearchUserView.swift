//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct SearchUserView: View {
//    @Binding var showSignInView: Bool
//    @Binding var showCreateProfileView: Bool
    
   
    @State var targetUserId: String
    
    @State private var searchTerm = ""
    
    
    
    @StateObject private var viewModel = SearchUserViewModel()
    
    
    var filteredSearch: [DBUser]{
        guard !searchTerm.isEmpty else { return viewModel.allUsers}
        return viewModel.allUsers.filter{$0.name!.localizedCaseInsensitiveContains(searchTerm) || $0.username!.localizedCaseInsensitiveContains(searchTerm)}
    }
    var body: some View {
        //        VStack {
        //            ForEach(viewModel.images, id: \.id) { item in
        //                Text("URL: \(item.url)")
        //                Text("Quote: \(item.quote)")
        //            }
        //        }.onAppear { viewModel.fetchData() }
        
        ScrollView {
            LazyVStack(alignment: .leading) {
                
                ForEach(filteredSearch) { userTile    in
                    let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                    
                    
                    
                    
                    
                    
                    
                    NavigationLink {
                        
                        //                        ProfileView(showSignInView: $showSignInView, appModel.loadedColor: $appModel.loadedColor,targetUserColor: targetUserColor, showCreateProfileView: $showCreateProfileView, targetUserId: userTile.userId)
                        ProfileView(targetUserColor: targetUserColor, targetUserId: userTile.userId)
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
                            
                            //                            VStack(alignment: .leading){
                            
                        
                            
                            
                          
                            
                       
                            
                            // if friends
                            if let friendsList = viewModel.user?.friends, friendsList.contains(userTile.id) {
                                VStack(alignment: .leading){
                                    
                                    Text(userTile.name!)
                                        .font(.headline)
                                        .foregroundStyle(Color(UIColor.label))
                                    
                                    
                                    Text("Friended")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                    
                                }
                                
                                Spacer()
                                
                            } else {
                                
                                //not friends view :(
                                Text(userTile.name!)
                                    .font(.headline)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                
                                Spacer()
                                
                                
                                
                                //add or undo add friend button
                                if let clickedState = viewModel.clickedStates[userTile.id] {
                                    
                                    Button {
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                        
                                        
                                        print(clickedState)
                                        
                                        Task{
                                            //                                            viewModel.sendFriendRequest(friendUserId: user.userId!)
                                            if clickedState{
                                                
                                                viewModel.unsendFriendRequest(friendUserId: userTile.id)
                                                
                                                
                                            } else{
                                                viewModel.sendFriendRequest(friendUserId: userTile.id)
                                                
                                            }
                                            
                                            
                                        }
                                        
                                    } label: {
                                        
                                        Text(clickedState ? "Undo" : "Add")
                                            .font(.caption)
                                            .frame(width:32)
                                        
                                    }
                                    .tint(targetUserColor)
                                    .buttonStyle(.bordered)
                                    .cornerRadius(10)
                                    
                                }
                                
                                
                                
                                
                            }
                            
                            
                            
                            
                            //
                            //                                Text(
                            //                                    "@\(userTile.username!)")
                            //                                .font(.caption)
                            //
                            //                            }
                            
                        }
                        
                        .frame(maxWidth: .infinity,  alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        .background(.thickMaterial)
                        .background(targetUserColor)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                    }
                    
                    
                    
                }
                
                
                
                
                
                
                
            }
//            .listStyle(PlainListStyle())
            .navigationTitle( "Search 👀")
            .searchable(text: $searchTerm, prompt: "Search")
        }
        
     .scrollDismissesKeyboard(.interactively)
            
        .task {
         try? await viewModel.getAllUsers()
        }
        
        
    }
}

/*
struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
//        SearchUserView(showSignInView: .constant(false),appModel.loadedColor: .constant(.red),showCreateProfileView: .constant(false),  targetUserId: "")
        SearchUserView(activeSheet: .constant(.signInView), appModel.loadedColor: .constant(.red), targetUserId: "")
    }
}
*/
