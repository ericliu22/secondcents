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
    @Environment(\.dismiss) var dismissScreen
    
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
            
            
            
            
            Spacer()
            
            Button(action: {
                Task{
                    try? await viewModel.removeSelf(spaceId: spaceId)
                }
                
                dismissScreen()
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
        
        .padding(.horizontal)
        .task{
            try? await viewModel.loadCurrentSpace(spaceId: spaceId)
            
        }
     
    }
}

#Preview {
    SpaceSettingsView(spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F")
    
}
