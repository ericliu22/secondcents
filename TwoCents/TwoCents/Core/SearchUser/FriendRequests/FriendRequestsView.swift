import SwiftUI
import Foundation

struct FriendRequestsView: View {
    @State var targetUserId: String
    @State private var searchTerm = ""
    
    @Environment(AppModel.self) var appModel
    @StateObject private var viewModel = FriendRequestsViewModel()
    
    private let noFriendsMessage: [String] = [
        "it's getting dry 😬",
        "no friends 🫵😂"
    ]
    
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
    
    // State property to store the selected message
    @State private var friendRequestMessage: String = ""
    
    init(targetUserId: String) {
        self._targetUserId = State(initialValue: targetUserId)
        // Initialize the friend request message
        _friendRequestMessage = State(initialValue: friendRequestMessages.randomElement() ?? "No message available")
    }
    
    var filteredSearch: [DBUser] {
        guard !searchTerm.isEmpty else { return viewModel.allRequests }
        return viewModel.allRequests.filter {
            $0.name!.localizedCaseInsensitiveContains(searchTerm) || $0.username!.localizedCaseInsensitiveContains(searchTerm)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredSearch) { userTile in
                    let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                    
                    NavigationLink {
                        ProfileView(targetUserColor: targetUserColor, targetUserId: userTile.userId)
                    } label: {
                        HStack(spacing: 20) {
                            Group {
                                if let urlString = userTile.profileImageUrl, let url = URL(string: urlString) {
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
                                    Circle()
                                        .strokeBorder(targetUserColor, lineWidth: 0)
                                        .background(Circle().fill(targetUserColor))
                                        .frame(width: 64, height: 64)
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text(userTile.name!)
                                    .font(.headline)
                                
                                Text(friendRequestMessage)
                                    .font(.caption)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                
                                HStack {
                                    Button {
                                        viewModel.acceptFriendRequest(friendUserId: userTile.userId)
                                        Task {
                                            try? await viewModel.getAllRequests(targetUserId: targetUserId)
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
                                        viewModel.declineFriendRequest(friendUserId: userTile.userId)
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
            .listStyle(PlainListStyle())
            .navigationTitle("Friend Requests ✨")
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .scrollDismissesKeyboard(.interactively)
        }
        .task {
            try? await viewModel.getAllRequests(targetUserId: targetUserId)
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
