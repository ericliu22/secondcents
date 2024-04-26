//
//  SpaceSettingsView.swift
//  TwoCents
//
//  Created by jonathan on 4/25/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct SpaceSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SpaceSettingsViewModel()
    
    private var spaceId: String
    private var chatroomDocument: DocumentReference
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.chatroomDocument = db.collection("spaces").document(spaceId)
        
        //        viewModel = SpaceSettingsViewModel()
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack{
                VStack{
                    Group{
                        //Circle or Profile Pic
                        //
                        //
                        
                        if let urlString = viewModel.space?.profileImageUrl,
                           let url = URL(string: urlString) {
                            
                            
                            
                            //If there is URL for profile pic, show
                            //circle with stroke
                            AsyncImage(url: url) {image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 160, height: 160)
                                
                                
                                
                            } placeholder: {
                                //else show loading after user uploads but sending/downloading from database
                                
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint:
                                                                    Color(UIColor.systemBackground)
                                                                  
                                                                 )
                                    )
                                //                            .scaleEffect(1, anchor: .center)
                                    .frame(width: 160, height: 160)
                                    .background(
                                        Circle()
                                            .fill(Color.accentColor)
                                            .frame(width: 160, height: 160)
                                    )
                            }
                            
                        } else {
                            
                            //if no profile pic, show circle
                            Circle()
                            
                            
                                .background(Circle()   .fill(Color.accentColor))
                                .frame(width: 160, height: 160)
                            
                            
                        }
                        
                    }
                    
                    
                    
                    
                    Text(viewModel.space?.name ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                    
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    
                    
                    if let mySpaceMembers = viewModel.space?.members{
                        
                        
                        Text( "\(mySpaceMembers.count) members")
                            .foregroundStyle(.secondary)
                            .font(.headline)
                        
                        //                                                .fontWeight(.regular)
                        
                        
                        
                    }
                }
                .padding()
                
                .frame(maxWidth:.infinity)
                
                //            .aspectRatio(2, contentMode: .fit)
                .background(.thickMaterial)
                .cornerRadius(20)
                
                
                Divider()
                    .padding(.vertical)
                
                
                
                VStack{
                    
                    
                    ForEach(viewModel.allMembers) { userTile    in
                        
                    
                        if userTile.userId != viewModel.user?.userId {
                       
//                        
                        let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                        
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
                                        //                                                .scaleEffect(0.5, anchor: .center)
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
                            
                            VStack(alignment: .leading){
                                
                                Text(userTile.name!)
                                    .font(.headline)
                                
                                
                                Text(
                                    "@\(userTile.username!)")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                
                            }
                            
                            
                            
                            Spacer()
                            
                            
                            
                            Button {
                                Task{
                                    try? await viewModel.removeUser(userId: userTile.userId, spaceId: spaceId)
                                    try? await viewModel.loadCurrentSpace(spaceId: spaceId)
                                    //                                viewModel.declineFriendRequest(friendUserId: userTile.userId)
                                    try? await viewModel.getMembersInfo()
                                }
                            } label: {
                                Text("Kick")
                                    .font(.caption)
                                
                                
//                                    .frame(maxWidth: .infinity)
                                
                            }
                            .tint(.gray)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                            
                            
                        }
                        .frame(maxWidth: .infinity,  alignment: .leading)
                   
                        
                        
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                       
                        .background(.thickMaterial)
                        .background(targetUserColor)
                        .cornerRadius(10)
                       
                        
                    }
                    }
                }
                
                
                
                
                
                Spacer()
                
                Divider()
                    .padding(.vertical)
                
                Button(action: {
                    Task{
                        if viewModel.allMembers.count == 1 {
                            
                            //delete entire space
                            try? await viewModel.deleteSpace(spaceId: spaceId)
                            
                        } else{
                            
                            //remove self
                            try? await viewModel.removeSelf(spaceId: spaceId)
                        }
                        
                        
                        
                        
                    }
                    self.presentationMode.wrappedValue.dismiss()
                    
                }, label: {
                    Text("Leave Space")
                        .font(.headline)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                    
                })
                
                
                .buttonStyle(.bordered)
                .tint(.red)
                .frame(height: 55)
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .task{
            try? await viewModel.loadCurrentUser()
            try? await viewModel.loadCurrentSpace(spaceId: spaceId)
            try? await viewModel.getMembersInfo()
            
        }
     
    }
}

#Preview {
    SpaceSettingsView(spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F")
    
}
