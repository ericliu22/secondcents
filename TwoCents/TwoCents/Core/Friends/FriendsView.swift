//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct FriendsView: View {
    //    @Binding var showSignInView: Bool
    @Environment(AppModel.self) var appModel
    //    @Binding var showCreateProfileView: Bool
    
    
    @State var targetUserId: String
    
    @State private var searchTerm = ""
    
    
    
    @StateObject private var viewModel = FriendsViewModel()
    
    
    var filteredSearch: [DBUser]{
        guard !searchTerm.isEmpty else { return viewModel.allFriends}
        return viewModel.allFriends.filter{
            guard let name = $0.name else {
                return false
            }
            return name.localizedCaseInsensitiveContains(searchTerm) /*|| $0.username!.localizedCaseInsensitiveContains(searchTerm)*/}
    }
    var body: some View {
        //        VStack {
        //            ForEach(viewModel.images, id: \.id) { item in
        //                Text("URL: \(item.url)")
        //                Text("Quote: \(item.quote)")
        //            }
        //        }.onAppear { viewModel.fetchData() }
        
        NavigationStack{
            ScrollView {
                LazyVStack(alignment: .leading) {
                    
                    ForEach(filteredSearch) { userTile    in
                        let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                        
                        
                        
                        
                        
                        
                        
                        NavigationLink {
                            
                            //                        ProfileView(showSignInView: $showSignInView, appModel.loadedColor: $appModel.loadedColor,targetUserColor: targetUserColor, showCreateProfileView: $showCreateProfileView, targetUserId: userTile.userId)
                            
                            ProfileView(targetUserId: userTile.userId,
                            targetUserColor: targetUserColor)
                        } label: {
                            HStack(spacing: 20){
                                
                                
                                
                                Group{
                                    //Circle or Profile Pic
                                    
                                    
                                    if let urlString = userTile.profileImageUrl,
                                       let url = URL(string: urlString) {
                                        
                                        
                                        
                                        //If there is URL for profile pic, show
                                        //circle with stroke
                                        CachedUrlImage(imageUrl: url)
                                            .clipShape(Circle())
                                            .frame(width: 64, height: 64)
                                        
                                    } else {
                                        
                                        //if user has not uploaded profile pic, show circle
                                        Circle()
                                        .fill(targetUserColor)
                                            .frame(width: 64, height: 64)
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                                
                                //                            VStack(alignment: .leading){
                                
                                Text(userTile.name ?? "gray")
                                    .font(.headline)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                //
                                //                                Text(
                                //                                    "@\(userTile.username!)")
                                //                                .font(.caption)
                                
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
                .listStyle(PlainListStyle())
                .navigationTitle( "Friends 💛" )
                .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            }
            
            .scrollDismissesKeyboard(.interactively)
            
        }
        .task {
            
            try? await viewModel.getAllFriends(targetUserId: targetUserId)
            
        }
        
        
    }
}

/*
struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        //        FriendsView(showSignInView: .constant(false),appModel.loadedColor: .constant(.red),showCreateProfileView: .constant(false), targetUserId: "")
        
        FriendsView(activeSheet: .constant(nil), appModel.loadedColor: .constant(.red), targetUserId: "")
    }
}
*/
