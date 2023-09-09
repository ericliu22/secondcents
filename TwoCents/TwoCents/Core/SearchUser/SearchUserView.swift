//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct SearchUserView: View {
    
    
    @State private var tintLoaded: Bool = false
    
    @State private var searchTerm = ""
    
    @StateObject private var viewModel = SearchUserViewModel()
    
    
    var filteredFriends: [DBUser]{
        guard !searchTerm.isEmpty else { return viewModel.friends }
        return viewModel.friends.filter{$0.name!.localizedCaseInsensitiveContains(searchTerm) || $0.username!.localizedCaseInsensitiveContains(searchTerm)}
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
            
                ForEach(filteredFriends) { friends    in
                    let loadedColor: Color = viewModel.getUserColor(userColor: friends.userColor!)
                    
                    
                    
                    
                    HStack(spacing: 20){
                        
                        
                        
                        Group{
                            //Circle or Profile Pic
                            
                            
                            if let urlString = friends.profileImageUrl,
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
                                                .fill(loadedColor)
                                                .frame(width: 48, height: 48)
                                        )
                                }
                                
                            } else {
                                
                                //if user has not uploaded profile pic, show circle
                                Circle()
                                
                                    .strokeBorder(loadedColor, lineWidth:0)
                                    .background(Circle().fill(loadedColor))
                                    .frame(width: 48, height: 48)
                                
                            }
                            
                            
                            
                            
                        }
                        
                        VStack(alignment: .leading){
                            
                            Text(friends.name!)
                                .font(.headline)
                            
                            
                            Text(
                                "@\(friends.username!)")
                                .font(.caption)
                            
                        }
                        
                    }
                }
                
                
                
               
                
                
            }
            .navigationTitle("Search")
            .searchable(text: $searchTerm, prompt: "Search")
            
        }
        .task {
            try? await viewModel.getAllFriends()
        }
        
        
        
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
