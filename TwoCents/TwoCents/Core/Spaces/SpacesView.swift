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
    
    
    
    @State private var searchTerm = ""
    
    
    
    @StateObject private var viewModel = SpacesViewModel()
    
    
    var filteredSearch: [DBSpace]{
        guard !searchTerm.isEmpty else { return viewModel.allSpaces}
        return viewModel.allSpaces.filter{$0.name!.localizedCaseInsensitiveContains(searchTerm)}
    }
    
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var body: some View {
        
        
        NavigationStack{
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: nil){
                    
                    ForEach(filteredSearch) { spaceTile    in
                        
                        NavigationLink {
                            CanvasPage(chatroom: db.collection("spaces").document(spaceTile.spaceId))
                            
                        } label: {
                            ZStack{
                                Group{
                                    //Circle or Profile Pic
                                    
                                    
                                    if let urlString = spaceTile.profileImageUrl,
                                       let url = URL(string: urlString) {
                                        
                                        //If there is URL for profile pic, show
                                        //circle with stroke
                                        
                                        
                                        Color.clear
                                            .aspectRatio(1, contentMode: .fit)
                                            .background(
                                                
                                                
                                                AsyncImage(url: url) {image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .layoutPriority(-1)
                                                    
                                                } placeholder: {
                                                    Rectangle()
                                                        .fill(Color.accentColor)
                                                }
                                                
                                            )
                                            .clipped()
//                                            .overlay(.regularMaterial)
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                    } else {
                                        //if space does not have profile pic, show circle
                                        Rectangle()
                                            .fill(Color.accentColor)
//                                            .overlay(.thickMaterial)
                                    }
                                    
                                    
                                }
//                                .frame(maxWidth:.infinity)
//                                .aspectRatio(1, contentMode: .fit)
                     
                              
                               
                                
                                
                                
                                VStack(alignment:.leading){
                                    
                                    Group{
                                        //Circle or Profile Pic
                                        
                                        
                                        if let urlString = spaceTile.profileImageUrl,
                                           let url = URL(string: urlString) {
                                            
                                            //If there is URL for profile pic, show
                                            //circle with stroke
                                            AsyncImage(url: url) {image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                
                                            } placeholder: {
                                                //else show loading after user uploads but sending/downloading from database
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                                    .frame(width: 64, height: 64)
                                                    .background(
                                                        Circle()
                                                            .fill(Color.accentColor)
                                                    )
                                            }
                                            .clipShape(Circle())
                                            .frame(width: 64, height: 64)
                                            
                                        } else {
                                            //if space does not have profile pic, show circle
                                            Circle()
                                                .fill(Color.accentColor)
                                                .clipShape(Circle())
                                                .frame(width: 64, height: 64)
                                        }
                                        
                                        
                                    }
                                    
                                    
                                    Spacer()
                         
                                    
                                    Text(spaceTile.name!)
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                    
                                    
                                    if let mySpaceMembers = spaceTile.members{
                                       
                                            
                                        Text( "\(mySpaceMembers.count) members")
                                                .foregroundStyle(.secondary)
                                                .font(.headline)
                                            
//                                                .fontWeight(.regular)
                                            
                                            
                                        
                                    }
                                    
                                    
                                    
                                    
                                    
                                
                                }
                                .padding()
                                .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .topLeading)
                                .aspectRatio(1, contentMode: .fit)
                                .background(.regularMaterial)
                               
                               
                                
                                
                            }
                            
                            
//
                            .cornerRadius(20)
                            
                            
                            
                            
                        }
                        
                        
                        
                    }
                    
                }
                .padding(.horizontal)
                
                
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
            try? await viewModel.loadCurrentUser()
            if let user = viewModel.user {
                try? await viewModel.getAllSpaces(userId: user.userId)
            }
        }
        
        
    }
}

struct SpacesView_Previews: PreviewProvider {
    static var previews: some View {
        SpacesView(showSignInView: .constant(false),loadedColor: .constant(.red),showCreateProfileView: .constant(false))
    }
}
