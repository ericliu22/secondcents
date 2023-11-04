
//
//  CreateProfileView.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import SwiftUI
import PhotosUI

struct CreateSpacesView: View {
    
    @State private var url: URL? = nil
    @State var spaceId: String
    
    @StateObject private var viewModel = CreateSpacesViewModel()
    @State private var randomIndex: Int = 0
    
    
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    
    @State private var searchTerm = ""
    
    
    
    private let noMembersMessage: [String] = [
        "crickets...",
        "looking a little lonely here...",
        "whole lotta silence !!"
    ]
    
    
    
    var body: some View {
        
        VStack {
          
            //Name Textfield
            TextField("Enter a name", text: $viewModel.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                
                .foregroundStyle(Color.accentColor)
//                .padding(.bottom)
            
//            
////
//            Spacer()
//                .frame(height: 100)
                
   
    
            //Selected Members
            VStack(alignment:.leading){
                
                Text("Members 👯‍♀️")
                    .font(.title3)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack{
                        
                        
                        
                        //No members selected message
                        if viewModel.selectedMembers.count == 0 {                            Text(noMembersMessage[randomIndex])
                                .italic()
                                .font(.headline)
                                .foregroundStyle(.tertiary)
                                .fontWeight(.regular)
                                .padding(.vertical,2.5)
                        }
                        
                        
                        
                        
                        ForEach(viewModel.selectedMembers) { userTile    in
                            let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                            Group{
                                HStack{
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
                                                    .frame(width: 16, height: 16)
                                                
                                                
                                                
                                            } placeholder: {
                                                //else show loading after user uploads but sending/downloading from database
                                                
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                                    .scaleEffect(0.5, anchor: .center)
                                                    .frame(width: 16, height: 16)
                                                    .background(
                                                        Circle()
                                                            .fill(targetUserColor)
                                                            .frame(width: 16, height: 16)
                                                    )
                                            }
                                            
                                        } else {
                                            
                                            //if user has not uploaded profile pic, show circle
                                            Circle()
                                            
                                                .strokeBorder(targetUserColor, lineWidth:0)
                                                .background(Circle().fill(targetUserColor))
                                                .frame(width: 16, height: 16)
                                            
                                        }
                                        
                                        
                                        
                                        
                                    }
                                    Text(userTile.name!)
                                        .font(.headline)
                                }
                            }
                            .onTapGesture {
                                viewModel.removeMember(friend: userTile)
                            }
                            .padding(.horizontal,5)
                            .padding(.vertical,2.5)
                            .background(.thickMaterial, in: Capsule())
                            .background(targetUserColor, in: Capsule())
                            
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            
            
            //Friends
            
            VStack(alignment:.leading){
                
                Text("Friends 💛")
                    .font(.title3)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack{
                        
                        //No friends  message
                        if viewModel.allFriends.count == 0 {                            Text("It's a party!")
                                .italic()
                                .font(.headline)
                                .foregroundStyle(.tertiary)
                                .fontWeight(.regular)
                                .padding(.vertical,2.5)
                        }
                        
                        
                        ForEach(viewModel.allFriends) { userTile    in
                            let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                            Group{
                                HStack{
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
                                                    .frame(width: 16, height: 16)
                                                
                                                
                                                
                                            } placeholder: {
                                                //else show loading after user uploads but sending/downloading from database
                                                
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                                    .scaleEffect(0.5, anchor: .center)
                                                    .frame(width: 16, height: 16)
                                                    .background(
                                                        Circle()
                                                            .fill(targetUserColor)
                                                            .frame(width: 16, height: 16)
                                                    )
                                            }
                                            
                                        } else {
                                            
                                            //if user has not uploaded profile pic, show circle
                                            Circle()
                                            
                                                .strokeBorder(targetUserColor, lineWidth:0)
                                                .background(Circle().fill(targetUserColor))
                                                .frame(width: 16, height: 16)
                                            
                                        }
                                        
                                        
                                        
                                        
                                    }
                                    
                                    Text(userTile.name!)
                                        .font(.headline)
                                    
                                   
                                    
                                }
                            }
                            .onTapGesture {
                                viewModel.addMember(friend: userTile)
                            }
                            .padding(.horizontal,5)
                            .padding(.vertical,2.5)
                            .background(.thickMaterial, in: Capsule())
                            .background(targetUserColor, in: Capsule())
                            
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            
            
            Button {
                Task {
                    do {
                        try await viewModel.createSpace(spaceId: spaceId)
                        
                        return
                    } catch {
                    }
                }
            } label: {
                Text("Create")
                    .font(.headline)
                
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                
            }
            
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .frame(height: 55)
            .cornerRadius(10)
        }
        .padding()
        .task{
            try? await viewModel.loadCurrentSpace(spaceId: spaceId)
            try? await viewModel.getAllFriends()
            
            randomIndex = Int.random(in: 0..<(noMembersMessage.count))
            
        }
        
        //        .onChange(of: selectedPhoto, perform: { newValue in
        //            if let newValue {
        //
        //                viewModel.saveProfileImage(item: newValue, spaceId: spaceId)
        //            }
        //        })
        .navigationTitle("Create Space 💭")
    }
    
}


struct CreateSpacesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            CreateSpacesView(spaceId: UUID().uuidString)
        }
    }
}
