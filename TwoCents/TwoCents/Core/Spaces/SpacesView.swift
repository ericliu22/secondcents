//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct SpacesView: View {
    @Binding var activeSheet: PopupSheet?

    @State private var showDetail = false
    
    
    @Bindable var viewModel = SpacesViewModel()
    @Environment(AppModel.self) var appModel
    
    
    var filteredSearch: [DBSpace]{
        guard !viewModel.searchTerm.isEmpty else { return viewModel.allSpaces}
        return viewModel.allSpaces.filter{$0.name!.localizedCaseInsensitiveContains(viewModel.searchTerm)}
    }
    
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
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
                                
                                    .onDisappear {
                                        /* Eric
                                            DO NOT DELETE THIS
                                            This happens too slow and fucks up the viewModel.loadCurrentUser() of CanvasPage
                                            Hence resulting in bug where canvas shows up as nothing
                                         */
                                        //refresh spaces list to check if user left a space
//                                        Task {
//                                            
//                                            try? await viewModel.loadCurrentUser()
//                                            if let user = viewModel.user {
//                                                
//                                                try? await viewModel.getAllSpaces(userId: user.userId)
//                                            }
//                                        }
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
                    CreateSpacesView(spaceId: viewModel.newSpaceUUID, activeSheet: $activeSheet, isShowingCreateSpaces: $viewModel.isShowingCreateSpaces )
                    
                }
            })
            .onChange(of: viewModel.presentedPath, { oldValue, newValue in
                print("PRESENTED PATH \(newValue)")
            })
            .navigationDestination(for: DBSpace.self) { space in
                CanvasPage(spaceId: space.spaceId)
                .onDisappear {
                //refresh spaces list to check if user left a space
                    Task {
                        try? await viewModel.loadCurrentUser()
                        if let user = viewModel.user {
                            try? await viewModel.getAllSpaces(userId: user.userId)
                        }
                    }
                }
            }
            .onChange(of: viewModel.isShowingCreateSpaces, { oldValue, newValue in
                if !viewModel.isShowingCreateSpaces {
                    print("YO")
                    
                    Task{
                        try? await viewModel.loadCurrentUser()
                           
                        if let user = viewModel.user {
                            try? await viewModel.getAllSpaces(userId: user.userId)
                            viewModel.newSpaceUUID = UUID().uuidString
                        }
                    }
                }
            })
            .toolbar{toolbar()}
            .navigationTitle( "Spaces 💬" )
            .searchable(text: $viewModel.searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
        }
        .task {
     
            //use self for clarity
            if appModel.shouldNavigateToSpace {
                guard let spaceId = appModel.navigationSpaceId else { return }
                guard let space: DBSpace = try? await SpaceManager.shared.getSpace(spaceId: spaceId) else {
                    print("Failed to get DBSpace from deeplink")
                    return
                }
                appModel.shouldNavigateToSpace = false
                viewModel.presentedPath.append(space)
                guard let user = viewModel.user else {
                    return
                }
                appModel.addToSpace(userId: user.userId)
            }
        }
        .modifier(modelNavigation())
        .environment(viewModel)

    }
    
    struct modelNavigation: ViewModifier {
        @Environment(AppModel.self) var appModel
        @Environment(SpacesViewModel.self) var viewModel
        
        func body(content: Content) -> some View {
            content
                .onChange(of: appModel.shouldNavigateToSpace, {
                    DispatchQueue.global().async {
                        appModel.navigationMutex.lock()
                        print("SPACESVIEW ACQUIRED MUTEX")
                        if appModel.shouldNavigateToSpace{
                            print("appModel.inSpace \(appModel.inSpace)")
                            print("appModel.currentSpaceId \(appModel.currentSpaceId ?? "nil")")
                            while (appModel.inSpace && appModel.navigationSpaceId != appModel.currentSpaceId) {
                                    print("SPACESVIEW WAITING FOR SPACE")
                                    appModel.navigationMutex.wait() // Block the thread until the condition is true
                            }
                            appModel.navigationMutex.broadcast()
                            var succeded: Bool = false
                            while (!appModel.correctTab) {
                                print("SPACESVIEW WAITING FOR TAB")
                                succeded = appModel.navigationMutex.wait(until: .now+100)
                            }
                            if !succeded {
                                print("TIMEDOUT")
                                appModel.navigationMutex.unlock()
                                return
                            }
                            print("SPACESVIEW DONE WAITING")
                            if appModel.navigationSpaceId == appModel.currentSpaceId {
                                appModel.navigationMutex.unlock()
                                return
                            }
                            //Just wait lmao
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                guard let spaceId = appModel.navigationSpaceId else {
                                    print("not spaceId")
                                    appModel.navigationMutex.unlock()
                                    return
                                }
                                appModel.shouldNavigateToSpace = false
                                appModel.correctTab = false
                                print("APPENDING TO PRESENTED PATH")
                                Task {
                                    guard let space: DBSpace = try? await SpaceManager.shared.getSpace(spaceId: spaceId) else {
                                        print("Failed to get DBSpace from deeplink")
                                        return
                                    }
                                    if !viewModel.presentedPath.contains(where: {$0.spaceId == space.spaceId}) {
                                        viewModel.presentedPath.append(space)
                                    }
                                    guard let user = viewModel.user else {
                                        return
                                    }
                                    appModel.addToSpace(userId: user.userId)
                                }
                            }
                        }
                        appModel.navigationMutex.unlock()
                    }
    
                })
    
        }
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
