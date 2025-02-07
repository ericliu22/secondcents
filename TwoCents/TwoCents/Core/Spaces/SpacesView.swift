//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct NavigationSpace: Equatable, Identifiable, Hashable {
    let space: DBSpace
    let widgetId: String?

    var id: String { space.spaceId }

    init(space: DBSpace, widgetId: String? = nil) {
        self.space = space
        self.widgetId = widgetId
    }
}

struct SpacesView: View {

    @State var viewModel = SpacesViewModel()
    @Environment(AppModel.self) var appModel

    var filteredSearch: [NavigationSpace] {
        guard !viewModel.searchTerm.isEmpty else { return viewModel.allSpaces }
        return viewModel.allSpaces.filter {
            $0.space.name!.localizedCaseInsensitiveContains(
                viewModel.searchTerm)
        }
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    private func handleNavigationRequest() async {
        // If the request is for a space, load that space and push CanvasPage
        guard
            case .space(let spaceId, let widgetId) = appModel.navigationRequest
        else {
            return
        }

        do {
            // Attempt to load the space from Firestore
            let space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
            // Once loaded, reset the request so we don’t do it again
            appModel.navigationRequest = .none

            // Push the space onto the navigation stack
            // This triggers your .navigationDestination(for: DBSpace.self) block
            let navigationSpace = NavigationSpace(
                space: space, widgetId: widgetId)
            viewModel.presentedPath.removeAll()
            viewModel.presentedPath.append(navigationSpace)
        } catch {
            print("Failed to get DBSpace for \(spaceId)")
        }
    }

    func linkLabel(spaceTile: NavigationSpace) -> some View {
        ZStack {
            Group {
                //Circle or Profile Pic
                if let urlString = spaceTile.space.profileImageUrl,
                    let url = URL(string: urlString)
                {

                    //If there is URL for profile pic, show
                    //circle with stroke

                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                        .background(

                            CachedUrlImage(imageUrl: url)
                                .clipShape(Circle())
                                    .layoutPriority(-1)


                        )
                        .clipped()
                } else {
                    //if space does not have profile pic, show circle
                    Rectangle()
                        .fill(Color.accentColor)
                }
            }
            VStack(alignment: .leading) {

                Group {
                    //Circle or Profile Pic
                    if let urlString = spaceTile.space.profileImageUrl,
                        let url = URL(string: urlString)
                    {

                        //If there is URL for profile pic, show
                        //circle with stroke
                        CachedUrlImage(imageUrl: url)
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

                Text(spaceTile.space.name ?? "")
                    .font(.title)
                    .fontWeight(.bold)

                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                if let mySpaceMembers = spaceTile.space.members {

                    Text("\(mySpaceMembers.count) members")
                        .foregroundStyle(.secondary)
                        .font(.headline)

                    //                                                .fontWeight(.regular)

                }
            }
            .padding()
            .frame(
                maxWidth: .infinity, maxHeight: .infinity,
                alignment: .topLeading
            )
            .aspectRatio(1, contentMode: .fit)
            .background(.regularMaterial)

        }
        .overlay {
            NotificationCountView(
                value: Binding<Int>(
                    get: {
                        viewModel.notificationCount[spaceTile.space.spaceId]
                            ?? 0
                    },
                    set: { newValue in
                        viewModel.notificationCount[spaceTile.space.spaceId] =
                            newValue
                    }
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
                        description: Text(
                            "But hey, maybe personal space is all you need.")
                    )
                    .onTapGesture {
                        viewModel.isShowingCreateSpaces = true
                    }
                    .padding(.top, 200)

                } else {
                    Tile()
                }
            }

            .scrollDismissesKeyboard(.interactively)

            .fullScreenCover(
                isPresented: $viewModel.isShowingCreateSpaces,
                content: {
                    NavigationView {
                        CreateSpacesView(
                            spaceId: viewModel.newSpaceUUID,
                            isShowingCreateSpaces: $viewModel
                                .isShowingCreateSpaces)

                    }
                }
            )
            .onChange(
                of: viewModel.presentedPath,
                { oldValue, newValue in
                    print("PRESENTED PATH \(newValue)")
                }
            )
            .navigationDestination(for: NavigationSpace.self) { navigationSpace in
                CanvasPage(spaceId: navigationSpace.space.spaceId, widgetId: navigationSpace.widgetId)
            }
            .onChange(
                of: viewModel.isShowingCreateSpaces,
                { oldValue, newValue in
                    if !viewModel.isShowingCreateSpaces {
                        if let user = viewModel.user {
                            viewModel.newSpaceUUID = UUID().uuidString
                        }
                    }
                }
            )
            .toolbar { toolbar() }
            .navigationTitle("Spaces 💬")
            .searchable(
                text: $viewModel.searchTerm,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search")
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

    func Tile() -> some View {

        LazyVGrid(columns: columns, spacing: nil) {

            ForEach(filteredSearch, id: \.space.spaceId) { spaceTile in

                NavigationLink {
                    CanvasPage(spaceId: spaceTile.space.spaceId)
                        .tint(appModel.loadedColor)
                        .onAppear {
                            if let notificationCount =
                                viewModel.notificationCount[
                                    spaceTile.space.spaceId]
                            {
                                let currentBadgeNumber = UIApplication.shared
                                    .applicationIconBadgeNumber
                                UNUserNotificationCenter.current()
                                    .setBadgeCount(
                                        max(
                                            currentBadgeNumber
                                                - notificationCount, 0))
                            }
                        }

                } label: {
                    linkLabel(spaceTile: spaceTile)
                }

            }

        }
        .padding(.horizontal)

    }
    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.isShowingCreateSpaces = true

            } label: {
                Image(systemName: "square.and.pencil")
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
