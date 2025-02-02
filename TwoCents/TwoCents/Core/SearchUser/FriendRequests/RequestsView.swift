import SwiftUI
import Foundation

struct RequestsView: View {
    @State var targetUserId: String
    @State private var searchTerm = ""
    
    @Environment(AppModel.self) var appModel
    @State private var viewModel = RequestsViewModel()
    
    private let noFriendsMessage: [String] = [
        "it's getting dry 😬",
        "no friends 🫵😂"
    ]
    
    //    private let friendRequestMessages = [
    //        "BEGS to be your friend",
    //        "wants to be your friend SO BADLY",
    //        "DESPERATELY wants to be your friend",
    //        "is feeling lonely... Pls be their friend?",
    //        "craves your friendship",
    //        "longs for your company",
    //        "eagerly awaits your friendship",
    //        "yearns for your companionship",
    //        "feels a strong need for your friendship",
    //        "desperately wishes to be close to you",
    //        "wants to be friends more than anything"
    //    ]
    //
    //    private let spaceRequestMessages = [
    //        ""
    //    ]
    
    // State property to store the selected message
    //    @State private var friendRequestMessage: String = ""
    //    @State private var spaceRequestMessage: String = ""
    //
    //    init(targetUserId: String) {
    //        self._targetUserId = State(initialValue: targetUserId)
    //        // Initialize the friend request message
    //        _friendRequestMessage = State(initialValue: friendRequestMessages.randomElement() ?? "No message available")
    //        // Initialize space request message
    //        _spaceRequestMessage = State(initialValue: spaceRequestMessages.randomElement() ?? "")
    //    }
    
    //filter all requests
    var filteredSearch: [any Requestable] {
        guard !searchTerm.isEmpty else { return viewModel.allRequests }
        return viewModel.allRequests.filter{
            $0.id.localizedCaseInsensitiveContains(searchTerm)
        }
    }
    //    //filter friend requests
    //    var filteredSearch: [DBUser] {
    //        guard !searchTerm.isEmpty else { return viewModel.allRequests }
    //        return viewModel.allRequests.filter {
    //            $0.name!.localizedCaseInsensitiveContains(searchTerm) /*|| $0.username!.localizedCaseInsensitiveContains(searchTerm)*/
    //        }
    //    }
    //
    //    //filter space requests
    //    var filteredSpaceSearch: [DBSpace] {
    //        guard !searchTerm.isEmpty else { return viewModel.allSpaceRequests }
    //        return viewModel.allSpaceRequests.filter {
    //            $0.name!.localizedCaseInsensitiveContains(searchTerm) /*|| $0.username!.localizedCaseInsensitiveContains(searchTerm)*/
    //        }
    //    }
    
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredSearch.indices, id: \.self) { index in
                    let request = filteredSearch[index]
                    if request.isSpaceRequest {
                        SpaceRequestTile(targetSpaceId: request.id).environment(viewModel)
                    } else {
                        FriendRequestTile(targetUserId: request.id).environment(viewModel)
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Requests ✨")
                .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
                .scrollDismissesKeyboard(.interactively)
            }
            .task {
                try? await viewModel.getAllFriendRequests(targetUserId: targetUserId)
            }
        }
    }
    
    struct FriendRequestTile: View{
        @State private var friendRequestMessage: String = ""
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
            "wants to be friends more than anything"
        ]
        let targetUserId: String
        @State var requestUser: DBUser?
        @Environment(RequestsViewModel.self) var viewModel
        
        init(targetUserId: String) {
            self.targetUserId = targetUserId
            
            // Initialize the friend request message
            self.friendRequestMessage = friendRequestMessages.randomElement() ?? "No message available"
            Task {
                await fetchUser()
            }
        }
        
        func fetchUser() async {
            guard let user = try? await UserManager.shared.getUser(userId: targetUserId) else {
                print("fail")
                return
            }
            requestUser = user
        }
        
        var body: some View{
            let targetUserColor: Color = viewModel.getUserColor(userColor: requestUser?.userColor ?? "gray")
            NavigationLink {
                ProfileView(targetUserColor: targetUserColor, targetUserId: targetUserId)
            } label: {
                HStack(spacing: 20) {
                    Group {
                        if let urlString = requestUser?.profileImageUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 64, height: 64)
                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                    .frame(width: 64, height: 64)
                                    .background(Circle().fill(targetUserColor).frame(width: 64, height: 64))
                            }
                        } else {
                            
                            Circle().fill(targetUserColor)
                                .frame(width: 64, height: 64)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(requestUser?.name! ?? "Blank")
                            .font(.headline)
                        
                        Text(friendRequestMessage)
                            .font(.caption)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                        
                        HStack {
                            Button {
                                viewModel.acceptFriendRequest(friendUserId: requestUser?.userId ?? "No User ID 1")
                                Task {
                                    try? await viewModel.getAllFriendRequests(targetUserId: targetUserId)
                                }
                            } label: {
                                Text("Accept")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                            }
                            .tint(.green)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                            
                            Button {
                                viewModel.declineFriendRequest(friendUserId: requestUser?.userId ?? "No User ID 2")
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


struct SpaceRequestTile: View{
    let targetSpaceId: String
    @State var userSpaceId: DBSpace
    @State private var spaceRequestMessage: String = ""
    private let spaceRequestMessages = [
        ""
    ]
    @Environment(RequestsViewModel.self) var viewModel
    init(targetSpaceId: String) {
        self.targetSpaceId = userSpaceId.id
        // Initialize space request message
        _spaceRequestMessage = State(initialValue: spaceRequestMessages.randomElement() ?? "")
    }
    
    
    
    var body: some View{
        NavigationLink(){
            AcceptSpaceRequestView(spaceId: targetSpaceId)
        }
        label: {
            Text("Hello")
        }
    }
}

/*
struct FriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestsView(activeSheet: .constant(nil), appModel.loadedColor: .constant(.red), targetUserId: "")
    }
}
*/

//{ userTile in
//    let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
//    
//    NavigationLink {
//        ProfileView(targetUserColor: targetUserColor, targetUserId: userTile.userId)
//    } label: {
//        HStack(spacing: 20) {
//            Group {
//                if let urlString = userTile.profileImageUrl, let url = URL(string: urlString) {
//                    AsyncImage(url: url) { image in
//                        image
//                            .resizable()
//                            .scaledToFill()
//                            .clipShape(Circle())
//                            .frame(width: 64, height: 64)
//                    } placeholder: {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
//                            .frame(width: 64, height: 64)
//                            .background(Circle().fill(targetUserColor).frame(width: 64, height: 64))
//                    }
//                } else {
//                  
//                    Circle().fill(targetUserColor)
//                        .frame(width: 64, height: 64)
//                }
//            }
//            
//            VStack(alignment: .leading) {
//                Text(userTile.name!)
//                    .font(.headline)
//                
//                Text(friendRequestMessage)
//                    .font(.caption)
//                    .foregroundColor(Color(UIColor.secondaryLabel))
//                
//                HStack {
//                    Button {
//                        viewModel.acceptFriendRequest(friendUserId: userTile.userId)
//                        Task {
//                            try? await viewModel.getAllFriendRequests(targetUserId: targetUserId)
//                        }
//                    } label: {
//                        Text("Accept")
//                            .font(.caption)
//                            .frame(maxWidth: .infinity)
//                    }
//                    .tint(.green)
//                    .buttonStyle(.bordered)
//                    .cornerRadius(10)
//                    
//                    Button {
//                        viewModel.declineFriendRequest(friendUserId: userTile.userId)
//                    } label: {
//                        Text("Decline")
//                            .font(.caption)
//                            .frame(maxWidth: .infinity)
//                    }
//                    .tint(.gray)
//                    .buttonStyle(.bordered)
//                    .cornerRadius(10)
//                }
//            }
//        }
//    }
//}
