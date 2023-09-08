//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct SearchUserView: View {
    
    
    @State private var tintLoaded: Bool = false
    
    @StateObject private var viewModel = SearchUserViewModel()
    var body: some View {
        //        VStack {
        //            ForEach(viewModel.images, id: \.id) { item in
        //                Text("URL: \(item.url)")
        //                Text("Quote: \(item.quote)")
        //            }
        //        }.onAppear { viewModel.fetchData() }
        
        VStack{
            List{
            
                ForEach(viewModel.friends) { friends    in
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
