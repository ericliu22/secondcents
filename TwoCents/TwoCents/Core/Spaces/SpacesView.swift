//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct SpacesView: View {
    @Binding var activeSheet: sheetTypes?
//    @Binding var showSignInView: Bool
    @Binding var loadedColor: Color
//    @Binding var showCreateProfileView: Bool

    @State private var searchTerm = ""
    @StateObject var viewModel = SpacesViewModel()
    
    
    @State private var showDetail = false
    @State var isShowingCreateSpaces: Bool = false
    
    @State private var presentedPath: [DBSpace] = []
    @State private var newSpaceUUID = UUID().uuidString
    
    @Environment(AppModel.self) var appModel
    
    
    var filteredSearch: [DBSpace]{
        guard !searchTerm.isEmpty else { return viewModel.allSpaces}
        return viewModel.allSpaces.filter{$0.name!.localizedCaseInsensitiveContains(searchTerm)}
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
                            .cornerRadius(20)
          
                        
        
    }
    
    var body: some View {
        
        
        NavigationStack(path: $presentedPath) {
            ScrollView(.vertical) {
                if !viewModel.finishedLoading {
                    ProgressView()
                        .padding(.top, 250)
                }else if filteredSearch.isEmpty && viewModel.finishedLoading {
                    
                    
               
                    
               
                        ContentUnavailableView(
                            "No Spaces",
                            systemImage: "rectangle.3.group.fill",
                            description: Text("But hey, maybe personal space is all you need.")
                        )
                        .onTapGesture {
                            isShowingCreateSpaces = true
                        }
                        .padding(.top, 200)
                    
                } else {
                    
                    LazyVGrid(columns: columns, spacing: nil){
                        
                        ForEach(filteredSearch) { spaceTile    in
                            
                            NavigationLink {
                                CanvasPage(spaceId: spaceTile.spaceId)
                                    .tint(loadedColor)
                                
                                    .onDisappear {
                                        //refresh spaces list to check if user left a space
                                        Task {
                                            
                                            try? await viewModel.loadCurrentUser()
                                            if let user = viewModel.user {
                                                
                                                try? await viewModel.getAllSpaces(userId: user.userId)
                                            }
                                        }
                                    }
                                
                            } label: {linkLabel(spaceTile: spaceTile)}
                            
                        }
                        
                    }
                    .padding(.horizontal)
                }
            }
            
            
            
            .fullScreenCover(isPresented: $isShowingCreateSpaces, content: {
                NavigationView{
                    CreateSpacesView(spaceId: newSpaceUUID, loadedColor: $loadedColor, activeSheet: $activeSheet, isShowingCreateSpaces: $isShowingCreateSpaces )
                    
                    
                }
            })
            .onChange(of: presentedPath, { oldValue, newValue in
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
            .onChange(of: isShowingCreateSpaces, { oldValue, newValue in
                if !isShowingCreateSpaces {
                    print("YO")
                    
                    Task{
                        try? await viewModel.loadCurrentUser()
                           
                        if let user = viewModel.user {
                            try? await viewModel.getAllSpaces(userId: user.userId)
                            newSpaceUUID = UUID().uuidString
                        }
                    }
                }
            })
            .toolbar{toolbar()}
            .navigationTitle( "Spaces 💬" )
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
        }
        .task {
     
            try? await viewModel.loadCurrentUser()
            if let user = viewModel.user {
                
                try? await viewModel.getAllSpaces(userId: user.userId)
                
            }
            //use self for clarity
            if appModel.shouldNavigateToSpace {
                guard let spaceId = appModel.navigationSpaceId else { return }
                guard let space: DBSpace = try? await SpaceManager.shared.getSpace(spaceId: spaceId) else {
                    print("Failed to get DBSpace from deeplink")
                    return
                }
                appModel.shouldNavigateToSpace = false
                presentedPath.append(space)
                guard let user = viewModel.user else {
                    return
                }
                appModel.addToSpace(userId: user.userId)
            }
        }
        .modifier(modelNavigation(presentedPath: $presentedPath))
        .environmentObject(viewModel)

    }
    
    struct modelNavigation: ViewModifier {
        @Environment(AppModel.self) var appModel
        @EnvironmentObject var viewModel: SpacesViewModel
        @Binding var presentedPath: [DBSpace]
        
        func body(content: Content) -> some View {
            content
                .onChange(of: appModel.shouldNavigateToSpace, {
                    DispatchQueue.global().async {
                        appModel.mutex.lock()
                        print("SPACESVIEW ACQUIRED MUTEX")
                        if appModel.shouldNavigateToSpace{
                            print("appModel.inSpace \(appModel.inSpace)")
                            print("appModel.currentSpaceId \(appModel.currentSpaceId ?? "nil")")
                            while (appModel.inSpace && appModel.navigationSpaceId != appModel.currentSpaceId) {
                                    print("SPACESVIEW WAITING FOR SPACE")
                                    appModel.mutex.wait() // Block the thread until the condition is true
                            }
                            appModel.mutex.broadcast()
                            var succeded: Bool = false
                            while (!appModel.correctTab) {
                                print("SPACESVIEW WAITING FOR TAB")
                                succeded = appModel.mutex.wait(until: .now+100)
                            }
                            if !succeded {
                                print("TIMEDOUT")
                                appModel.mutex.unlock()
                                return
                            }
                            print("SPACESVIEW DONE WAITING")
                            if appModel.navigationSpaceId == appModel.currentSpaceId {
                                appModel.mutex.unlock()
                                return
                            }
                            //Just wait lmao
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                guard let spaceId = appModel.navigationSpaceId else {
                                    print("not spaceId")
                                    appModel.mutex.unlock()
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
                                    if !presentedPath.contains(where: {$0.spaceId == space.spaceId}) {
                                        presentedPath.append(space)
                                    }
                                    guard let user = viewModel.user else {
                                        return
                                    }
                                    appModel.addToSpace(userId: user.userId)
                                }
                            }
                        }
                        appModel.mutex.unlock()
                    }
    
                })
    
        }
    }
    
    
    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button{
              isShowingCreateSpaces = true
                
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
//        SpacesView(showSignInView: .constant(false),loadedColor: .constant(.red),showCreateProfileView: .constant(false))
        SpacesView(activeSheet: .constant(nil), loadedColor: .constant(.red))
    }
}

*/
