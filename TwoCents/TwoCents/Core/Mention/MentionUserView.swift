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
    
    
//    @State var spaceId: String
    
    
    @State var allUsers: [DBUser]
    
    
    
    var filteredSearch: [DBUser]{
        guard !searchTerm.isEmpty else { return allUsers}
        return allUsers.filter{$0.name!.localizedCaseInsensitiveContains(searchTerm) /*|| $0.username!.localizedCaseInsensitiveContains(searchTerm)*/}
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
                                
                                    .fill(targetUserColor)
                                    .frame(width: 48, height: 48)
                                
                            }
                            
                            
                            
                            
                        }
                        
//                        VStack(alignment: .leading){
                            
                            Text(userTile.name!)
                                .font(.headline)
                            
//                            
//                            Text(
//                                "@\(userTile.username!)")
//                            .font(.caption)
//                            
//                        }
                        
                    }
                    
                    })
                    
                    
                }
                
                
              
                  
               
              
                
                
                
                
                
            }
            
            .scrollDismissesKeyboard(.interactively)
            .listStyle(PlainListStyle())
            .navigationTitle( "Mention 🤝" )
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            
            .toolbar{
                ToolbarItem(placement: .bottomBar) {
                    
                    if mentionedUser != nil {
                        Button(action: {
                            mentionedUser = nil
                            presentationMode.wrappedValue.dismiss()
                            
                        }, label: {
                            
                            
                            Text("Remove Mention")
//                                .fontWeight(.semibold)
                                .foregroundStyle(.red)
                            //                            .frame(height: 48)
                            //                            .frame(maxWidth: .infinity, alignment: .center)
                            
                        })
                    }
                }
            }
            
          
       
            
            
        }
//        .task {
//            
//            try? await viewModel.getAllUsers(spaceId: spaceId)
//            
//        }
        
        
    }
}

//struct MentionUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        MentionUserView(mentionedUser: .constant(nil), spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E")
//    }
//}
