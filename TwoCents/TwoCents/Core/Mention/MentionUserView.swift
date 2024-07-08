//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct MentionUserView: View {
    
    @State private var searchTerm = ""
    @Binding var mentionedUser: DBUser?
    
    
    @StateObject private var viewModel = MentionUserViewModel()
    
    
    let userId: String = (try? AuthenticationManager.shared.getAuthenticatedUser().uid) ?? ""
    
    
    @State var spaceId: String
    
    var filteredSearch: [DBUser]{
        guard !searchTerm.isEmpty else { return viewModel.allUsers}
        return viewModel.allUsers.filter{$0.name!.localizedCaseInsensitiveContains(searchTerm) || $0.username!.localizedCaseInsensitiveContains(searchTerm)}
    }
    
    
    @Environment(\.presentationMode) var presentationMode
    
    
    
    var body: some View {
        
        
        NavigationStack{
            List{
                
                ForEach(filteredSearch) { userTile    in
                    let targetUserColor: Color = Color.fromString(name: userTile.userColor!)
                    
                    
                    
                    
                    Button(action: {
                        mentionedUser = userTile
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                    
                  
                    
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
                    
                    })
                    
                    
                }
                
                
                
                
                
                
                
            }
            .listStyle(PlainListStyle())
            .navigationTitle( "Mention 🤝" )
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            
        }
        .task {
            
            try? await viewModel.getAllUsers(targetUserId: userId, spaceId: spaceId)
            
        }
        
        
    }
}

struct MentionUserView_Previews: PreviewProvider {
    static var previews: some View {
        MentionUserView(mentionedUser: .constant(nil), spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E")
    }
}
