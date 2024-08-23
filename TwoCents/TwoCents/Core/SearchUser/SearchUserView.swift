//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct SearchUserView: View {
    @Binding var activeSheet: PopupSheet?
//    @Binding var showSignInView: Bool
    @Binding var loadedColor: Color
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
        
      
            List{
                
                ForEach(filteredSearch) { userTile    in
                    let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                    
                    
                    
                    
                    
                    
                    
                    NavigationLink {
                        
//                        ProfileView(showSignInView: $showSignInView, loadedColor: $loadedColor,targetUserColor: targetUserColor, showCreateProfileView: $showCreateProfileView, targetUserId: userTile.userId)
                        ProfileView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserColor: targetUserColor, targetUserId: userTile.userId)
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
                            
//                            VStack(alignment: .leading){
                                
                                Text(userTile.name!)
                                    .font(.headline)
                                
//                                
//                                Text(
//                                    "@\(userTile.username!)")
//                                .font(.caption)
//                                
//                            }
                            
                        }
                    }
                    
                    
                    
                }
                
                
                
                
                
                
                
            }
            .listStyle(PlainListStyle())
            .navigationTitle( "Search 👀")
            .searchable(text: $searchTerm, prompt: "Search")
        
     .scrollDismissesKeyboard(.interactively)
            
        .task {
         try? await viewModel.getAllUsers()
        }
        
        
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
//        SearchUserView(showSignInView: .constant(false),loadedColor: .constant(.red),showCreateProfileView: .constant(false),  targetUserId: "")
        SearchUserView(activeSheet: .constant(.signInView), loadedColor: .constant(.red), targetUserId: "")
    }
}
