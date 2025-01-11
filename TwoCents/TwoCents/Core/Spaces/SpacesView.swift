//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct SpacesView: View {
    
    @State var viewModel = SpacesViewModel()
    @Environment(AppModel.self) var appModel
    
    
    var filteredSearch: [DBSpace]{
        guard !viewModel.searchTerm.isEmpty else { return viewModel.allSpaces}
        return viewModel.allSpaces.filter{$0.name!.localizedCaseInsensitiveContains(viewModel.searchTerm)}
    }
    
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    private func handleNavigationRequest() async {
               // If the request is for a space, load that space and push CanvasPage
               guard case .space(let spaceId) = appModel.navigationRequest else {
                   return
               }

               do {
                   // Attempt to load the space from Firestore
                   let space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
                   // Once loaded, reset the request so we don’t do it again
                   appModel.navigationRequest = .none
                   
                   // Push the space onto the navigation stack
                   // This triggers your .navigationDestination(for: DBSpace.self) block
                   viewModel.presentedPath.removeAll()
                   viewModel.presentedPath.append(space)
               } catch {
                   print("Failed to get DBSpace for \(spaceId)")
               }
   }

    
    func linkLabel(spaceTile: DBSpace) -> some View {
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
                } else {
                    //if space does not have profile pic, show circle
                    Rectangle()
                        .fill(Color.accentColor)
                }
            }
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
        .overlay {
            NotificationCountView(value: Binding<Int>(
                get: { viewModel.notificationCount[spaceTile.spaceId] ?? 0 },
                set: { newValue in viewModel.notificationCount[spaceTile.spaceId] = newValue }
            ))
        }
        .cornerRadius(20)
        
        
    }
    
    var body: some View {
        
        
        NavigationStack(path: $viewModel.presentedPath) {
            ScrollView(.vertical) {
                if !viewModel.finishedLoading {
                    ProgressView()
                        .padding(.top, 250)
                } else if filteredSearch.isEmpty && viewModel.finishedLoading {
                    
                    ContentUnavailableView(
                        "No Spaces",
                        systemImage: "rectangle.3.group.fill",
                        description: Text("But hey, maybe personal space is all you need.")
                    )
                    .onTapGesture {
                        viewModel.isShowingCreateSpaces = true
                    }
                    .padding(.top, 200)
                    
                } else {
                    
                    LazyVGrid(columns: columns, spacing: nil){
                        
                        ForEach(filteredSearch) { spaceTile    in
                            
                            NavigationLink {
                                CanvasPage(spaceId: spaceTile.spaceId)
                                    .tint(appModel.loadedColor)
                                    .onAppear {
                                        if let notificationCount = viewModel.notificationCount[spaceTile.spaceId] {
                                            let currentBadgeNumber = UIApplication.shared.applicationIconBadgeNumber
                                            UNUserNotificationCenter.current().setBadgeCount(max(currentBadgeNumber - notificationCount, 0))
                                        }
                                    }
                                
                            } label: {linkLabel(spaceTile: spaceTile)}
                            
                        }
                        
                    }
                    .padding(.horizontal)
                }
            }
            
            
            .scrollDismissesKeyboard(.interactively)
            
            
            
            .fullScreenCover(isPresented: $viewModel.isShowingCreateSpaces, content: {
                NavigationView{
                    CreateSpacesView(spaceId: viewModel.newSpaceUUID, isShowingCreateSpaces: $viewModel.isShowingCreateSpaces )
                    
                }
            })
            .onChange(of: viewModel.presentedPath, { oldValue, newValue in
                print("PRESENTED PATH \(newValue)")
            })
            .navigationDestination(for: DBSpace.self) { space in
                CanvasPage(spaceId: space.spaceId)
            }
            .onChange(of: viewModel.isShowingCreateSpaces, { oldValue, newValue in
                if !viewModel.isShowingCreateSpaces {
                    if let user = viewModel.user {
                        viewModel.newSpaceUUID = UUID().uuidString
                    }
                }
            })
            .toolbar{toolbar()}
            .navigationTitle( "Spaces 💬" )
            .searchable(text: $viewModel.searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
        }
        .task {
            await handleNavigationRequest()
        }
        .onChange(of: appModel.navigationRequest) {
            Task { await handleNavigationRequest() }
        }
        .onChange(of: appModel.user) {
            viewModel.detachListener()
            if let user = appModel.user {
                viewModel.attachSpacesListener(userId: user.userId)
            }
        }
        .environment(viewModel)
        
    }
    
    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button{
                viewModel.isShowingCreateSpaces = true
                
            } label: {
                Image (systemName: "square.and.pencil")
                    .font(.headline)
            }
            
        }
    }
    
}

/*
 struct SpacesView_Previews: PreviewProvider {
 static var previews: some View {
 //        SpacesView(showSignInView: .constant(false),appModel.loadedColor: .constant(.red),showCreateProfileView: .constant(false))
 SpacesView(activeSheet: .constant(nil), appModel.loadedColor: .constant(.red))
 }
 }
 
 */
