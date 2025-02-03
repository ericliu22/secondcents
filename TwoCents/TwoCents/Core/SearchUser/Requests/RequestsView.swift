import Foundation
import SwiftUI

private let friendRequestMessages = [
    "BEGS to be your friend",
    "wants to be your friend SO BADLY",
    "DESPERATELY wants to be your friend",
    "is feeling lonely... Pls be their friend?",
    "craves your friendship",
    "longs for your company",
    "eagerly awaits your friendship",
    "yearns for your companionship",
    "feels a strong need for your friendship",
    "desperately wishes to be close to you",
    "wants to be friends more than anything",
]
private let spaceRequestMessages = [
    "They really want you to join the space"
]

struct RequestsView: View {
    @State var viewModel: RequestsViewModel
    @Environment(AppModel.self) var appModel

    private let noFriendsMessage: [String] = [
        "it's getting dry 😬",
        "no friends 🫵😂",
    ]

    init(userId: String) {
        self.viewModel = RequestsViewModel(userId: userId)
    }
    //filter all requests

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredSearch, id: \.id) { request in
                    makeRequestTile(request: request)
                        .environment(viewModel)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Requests ✨")
                .searchable(
                    text: $viewModel.searchTerm,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search"
                )
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .onAppear {
            viewModel.attachRequestsListener()
        }
    }
}

@MainActor @ViewBuilder
func makeRequestTile(request: any Requestable) -> some View {
    if request.isSpaceRequest {
        if let requestSpace = request as? DBSpace {
            SpaceRequestTile(requestSpace: requestSpace)
        }
    } else {
        if let requestUser = request as? DBUser {
            FriendRequestTile(requestUser: requestUser)
        }
    }
}

struct SpaceRequestTile: View {
    let spaceRequestMessage: String
    let requestSpace: DBSpace
    @Environment(RequestsViewModel.self) var viewModel
    @Environment(AppModel.self) var appModel

    init(requestSpace: DBSpace) {
        // Initialize space request message
        self.requestSpace = requestSpace
        self.spaceRequestMessage = spaceRequestMessages.randomElement() ?? ""
    }

    var body: some View {
        VStack {
                NavigationLink {
                    AcceptSpaceRequestView(spaceId: requestSpace.spaceId)
                } label: {

                    HStack(spacing: 20) {
                        Group {
                            if let urlString = requestSpace.profileImageUrl,
                                let url = URL(string: urlString)
                            {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .frame(width: 64, height: 64)
                                } placeholder: {
                                    ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(
                                                tint: Color(
                                                    UIColor.systemBackground
                                                ))
                                        )
                                        .frame(width: 64, height: 64)
                                        .background(
                                            Circle().fill(appModel.loadedColor)
                                                .frame(
                                                    width: 64, height: 64))
                                }
                            } else {

                                Circle().fill(appModel.loadedColor)
                                    .frame(width: 64, height: 64)
                            }
                        }

                        VStack(alignment: .leading) {
                            Text(requestSpace.name ?? "")
                                .font(.headline)

                            Text(spaceRequestMessage)
                                .font(.caption)
                                .foregroundColor(
                                    Color(UIColor.secondaryLabel))

                            HStack {
                                Button {
                                    viewModel.acceptSpaceRequest(spaceId: requestSpace.spaceId)
                                } label: {
                                    Text("Accept")
                                        .font(.caption)
                                        .frame(maxWidth: .infinity)
                                }
                                .tint(.green)
                                .buttonStyle(.bordered)
                                .cornerRadius(10)

                                Button {
                                    viewModel.declineSpaceRequest(spaceId:
                                         requestSpace.spaceId)
                                } label: {
                                    Text("Decline")
                                        .font(.caption)
                                        .frame(maxWidth: .infinity)
                                }
                                .tint(.gray)
                                .buttonStyle(.bordered)
                                .cornerRadius(10)
                            }
                        }
                    }
                
                }
        }
    }
}

    struct FriendRequestTile: View {
        let requestUser: DBUser
        let friendRequestMessage: String
        @Environment(RequestsViewModel.self) var viewModel

        init(requestUser: DBUser) {
            self.requestUser = requestUser
            self.friendRequestMessage =
                friendRequestMessages.randomElement()
                ?? "requests to be your friend"
        }

        var body: some View {
            VStack {
                let targetUserColor = Color.fromString(
                    name: requestUser.userColor ?? "gray")
                NavigationLink {
                    ProfileView(
                        targetUserId: requestUser.userId, targetUserColor: targetUserColor)
                } label: {
                    HStack(spacing: 20) {
                        Group {
                            if let urlString = requestUser.profileImageUrl,
                                let url = URL(string: urlString)
                            {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .frame(width: 64, height: 64)
                                } placeholder: {
                                    ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(
                                                tint: Color(
                                                    UIColor.systemBackground
                                                ))
                                        )
                                        .frame(width: 64, height: 64)
                                        .background(
                                            Circle().fill(targetUserColor)
                                                .frame(
                                                    width: 64, height: 64))
                                }
                            } else {

                                Circle().fill(targetUserColor)
                                    .frame(width: 64, height: 64)
                            }
                        }

                        VStack(alignment: .leading) {
                            Text(requestUser.name ?? "Blank")
                                .font(.headline)

                            Text(friendRequestMessage)
                                .font(.caption)
                                .foregroundColor(
                                    Color(UIColor.secondaryLabel))

                            HStack {
                                Button {
                                    viewModel.acceptFriendRequest(
                                        friendUserId: requestUser.userId)
                                } label: {
                                    Text("Accept")
                                        .font(.caption)
                                        .frame(maxWidth: .infinity)
                                }
                                .tint(.green)
                                .buttonStyle(.bordered)
                                .cornerRadius(10)

                                Button {
                                    viewModel.declineFriendRequest(
                                        friendUserId: requestUser.userId)
                                } label: {
                                    Text("Decline")
                                        .font(.caption)
                                        .frame(maxWidth: .infinity)
                                }
                                .tint(.gray)
                                .buttonStyle(.bordered)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
            }
        }
    }
