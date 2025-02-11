
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
    
    @Environment(AppModel.self) var appModel
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    
    
    
    private let noMembersMessage: [String] = [
        "crickets...",
        "looking a little lonely here...",
        "whole lotta silence !!"
    ]
    @Binding var isShowingCreateSpaces: Bool
    @Environment(\.dismiss) var dismissScreen
    
    var body: some View {
        ScrollView{
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
                                                CachedImage(imageUrl: url)
                                                    .clipShape(Circle())
                                                    .frame(width: 16, height: 16)
                                                
                                            } else {
                                                
                                                //if user has not uploaded profile pic, show circle
                                                Circle()
                                                
                                                 .fill(targetUserColor)
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
                            if viewModel.allFriends.count == 0 && !viewModel.hasNoFriends{
                                Text("It's a party!")
                                    .italic()
                                    .font(.headline)
                                    .foregroundStyle(.tertiary)
                                    .fontWeight(.regular)
                                    .padding(.vertical,2.5)
                            }
                            
                            if viewModel.allFriends.count == 0 && viewModel.hasNoFriends {
                                
                                
                                NavigationLink {
                                    SearchUserView(targetUserId: "")
                                } label: {
                                    Label("No friends? I figured. Tap me!", systemImage: "person.badge.plus")
                                        .font(.headline)
                                        .padding(.horizontal,5)
                                        .padding(.vertical,2.5)
                                    //                                    .foregroundColor(Color(UIColor.systemBackground))
                                        .background(.thickMaterial, in: Capsule())
                                        .background(Color.accentColor, in: Capsule())
                                    
                                }
                                
                                
                                
                                
                                
                                
                                
                            } else {
                                ForEach(viewModel.allFriends) { userTile    in
                                    let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor ?? "gray")
                                    Group{
                                        HStack{
                                            Group{
                                                //Circle or Profile Pic
                                                
                                                
                                                if let urlString = userTile.profileImageUrl,
                                                   let url = URL(string: urlString) {
                                                    
                                                    
                                                    
                                                    //If there is URL for profile pic, show
                                                    //circle with stroke
                                                    CachedImage(imageUrl: url)
                                                        .clipShape(Circle())
                                                        .frame(width: 16, height: 16)
                                                    
                                                } else {
                                                    
                                                    //if user has not uploaded profile pic, show circle
                                                    Circle()
                                                    
                                                  .fill(targetUserColor)
                                                        .frame(width: 16, height: 16)
                                                    
                                                }
                                                
                                                
                                                
                                                
                                            }
                                            
                                            Text(userTile.name ?? "")
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
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                
                
                NavigationLink {
                    
                    SpaceProfilePicView(spaceId: spaceId,isShowingCreateSpaces: $isShowingCreateSpaces)
                    
                } label: {
                    Text("Create")
                        .font(.headline)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                    
                    
                    
                }
                .disabled(viewModel.name.isEmpty || viewModel.selectedMembers.isEmpty)
                
                .buttonStyle(.bordered)
                .tint(.accentColor)
                .frame(height: 55)
                .cornerRadius(10)
                
                
                .simultaneousGesture(TapGesture().onEnded{
                    Task{
                        do {
                            if !viewModel.name.isEmpty && !viewModel.selectedMembers.isEmpty {
                                
                                try await viewModel.createSpace(spaceId: spaceId)
                                
                                print("created  ")
                            }
                            
                            
                            return
                        } catch {
                        }
                    }
                    
                })
                
                
                
                //
                //            NavigationLink {
                //
                //                SpaceProfilePicView(spaceId: spaceId)
                //            } label: {
                //                Button {
                ////                    Task {
                ////                        do {
                ////                            try await viewModel.createSpace(spaceId: spaceId)
                ////
                ////                            return
                ////                        } catch {
                ////                        }
                ////                    }
                //                } label: {
                //                    Text("Create")
                //                        .font(.headline)
                //                        .frame(height: 55)
                //                        .frame(maxWidth: .infinity)
                //
                //                }
                //                .disabled(viewModel.name.isEmpty || viewModel.selectedMembers.isEmpty)
                //                .buttonStyle(.bordered)
                //                .tint(.accentColor)
                //                .frame(height: 55)
                //                .cornerRadius(10)
                //
                //
                //            }
                
                
                
                
                
                
                
            }
            .padding()
            .task{
                try? await viewModel.loadCurrentSpace(spaceId: spaceId)
                try? await viewModel.loadCurrentUser()
                //to prevent list from refreshing when one exits tab and comes back
                if viewModel.selectedMembers.isEmpty {
                    try? await viewModel.getAllFriends()
                    
                }
                
                randomIndex = Int.random(in: 0..<(noMembersMessage.count))
                
            }
        }
        
        .scrollDismissesKeyboard(.interactively)
        //        .onChange(of: selectedPhoto, perform: { newValue in
        //            if let newValue {
        //
        //                viewModel.saveProfileImage(item: newValue, spaceId: spaceId)
        //            }
        //        })
        .navigationTitle("Create Space 💭")
     
        .toolbar{
            
            ToolbarItem(placement: .navigationBarLeading) {
                
                Button(action: {
                    print("HI")
                    Task{
                        try? await viewModel.deleteSpace(spaceId: spaceId)
                    }
                    dismissScreen()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(UIColor.label))
//                        .font(.title2)
//                        .padding()
                })
                
                
            }
        }
            
            
            
           
            
        
    }
    
}

//
//struct CreateSpacesView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack{
//            CreateSpacesView(spaceId: UUID().uuidString, isShowingCreateSpaces: .constant(false))
//        }
//    }
//}
