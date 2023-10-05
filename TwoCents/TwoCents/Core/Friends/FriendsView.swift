//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct FriendsView: View {
    
    @Binding var showSignInView: Bool
    @Binding var loadedColor: Color
    @Binding var showCreateProfileView: Bool
    

    @State var targetUserId: String
    
    @State private var searchTerm = ""
    
    
    
    @StateObject private var viewModel = FriendsViewModel()
    
    
    var filteredSearch: [DBUser]{
        guard !searchTerm.isEmpty else { return viewModel.allFriends}
        return viewModel.allFriends.filter{$0.name!.localizedCaseInsensitiveContains(searchTerm) || $0.username!.localizedCaseInsensitiveContains(searchTerm)}
    }
    var body: some View {
        //        VStack {
        //            ForEach(viewModel.images, id: \.id) { item in
        //                Text("URL: \(item.url)")
        //                Text("Quote: \(item.quote)")
        //            }
        //        }.onAppear { viewModel.fetchData() }
        
        NavigationStack{
            List{
                
                ForEach(filteredSearch) { userTile    in
                    let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                    
                    
                    
                    
                    
                    
                    
                    NavigationLink {
                        
                        ProfileView(showSignInView: $showSignInView, loadedColor: $loadedColor,targetUserColor: targetUserColor, showCreateProfileView: $showCreateProfileView, targetUserId: userTile.userId)
                    } label: {
                        HStack(spacing: 20){
                            
                            ProfilePicWidget(urlString: userTile.profileImageUrl ?? "", tintColor: targetUserColor)
                            
                            
                            
                            VStack(alignment: .leading){
                                
                                Text(userTile.name!)
                                    .font(.headline)
                                
                                
                                Text(
                                    "@\(userTile.username!)")
                                .font(.caption)
                                
                            }
                            
                        }
                    }
                    
                    
                    
                }
                
                
                
                
                
                
                
            }
            .navigationTitle( "Friends" )
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            
        }
        .task {
           
          try? await viewModel.getAllFriends(targetUserId: targetUserId)
         
        }
        
        
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView(showSignInView: .constant(false),loadedColor: .constant(.red),showCreateProfileView: .constant(false), targetUserId: "")
    }
}
