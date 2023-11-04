//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct SpacesView: View {
    
    @Binding var showSignInView: Bool
    @Binding var loadedColor: Color
    @Binding var showCreateProfileView: Bool
    

    @State var targetUserId: String
    
    @State private var searchTerm = ""
    
    
    
    @StateObject private var viewModel = SpacesViewModel()
    
    
    var filteredSearch: [DBUser]{
        guard !searchTerm.isEmpty else { return viewModel.allFriends}
        return viewModel.allFriends.filter{$0.name!.localizedCaseInsensitiveContains(searchTerm) || $0.username!.localizedCaseInsensitiveContains(searchTerm)}
    }
    var body: some View {

        
        NavigationStack{
            List{
                
                ForEach(filteredSearch) { userTile    in
                    let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                    
                    NavigationLink {
                        
                        ProfileView(showSignInView: $showSignInView, loadedColor: $loadedColor,targetUserColor: targetUserColor, showCreateProfileView: $showCreateProfileView, targetUserId: userTile.userId)
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
                                            .frame(width: 48, height: 48)
                                        
                                        
                                        
                                    } placeholder: {
                                        //else show loading after user uploads but sending/downloading from database
                                        
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                        //                            .scaleEffect(1, anchor: .center)
                                            .frame(width: 48, height: 48)
                                            .background(
                                                Circle()
                                                    .fill(targetUserColor)
                                                    .frame(width: 48, height: 48)
                                            )
                                    }
                                    
                                } else {
                                    
                                    //if user has not uploaded profile pic, show circle
                                    Circle()
                                    
                                        .strokeBorder(targetUserColor, lineWidth:0)
                                        .background(Circle().fill(targetUserColor))
                                        .frame(width: 48, height: 48)
                                    
                                }
                                
                                
                                
                                
                            }
                            
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
            .toolbar{
               
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink{
                        CreateSpacesView(spaceId: UUID().uuidString)
                    } label: {
                        Image (systemName: "square.and.pencil")
                            .font(.headline)
                    }
                }
             
            }
            .navigationTitle( "Spaces 💬" )
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            
        }
        .task {
           
          try? await viewModel.getAllFriends(targetUserId: targetUserId)
         
        }
        
        
    }
}

struct SpacesView_Previews: PreviewProvider {
    static var previews: some View {
        SpacesView(showSignInView: .constant(false),loadedColor: .constant(.red),showCreateProfileView: .constant(false), targetUserId: "")
    }
}
