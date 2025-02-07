//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI
struct SearchUserView: View {
    @State var targetUserId: String
    @State private var searchTerm = ""
    @StateObject private var viewModel = SearchUserViewModel()

    var filteredSearch: [DBUser] {
        guard !searchTerm.isEmpty else { return viewModel.allUsers }
        return viewModel.allUsers.filter {
            guard let name = $0.name else {
                return false
            }
            return name.localizedCaseInsensitiveContains(searchTerm) /*|| $0.username!.localizedCaseInsensitiveContains(searchTerm) */}
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(filteredSearch) { userTile in
                
                    let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor ?? "gray")

                    NavigationLink {
                        ProfileView( targetUserId: userTile.userId, targetUserColor: targetUserColor)
                    } label: {
                        HStack(spacing: 20) {
                            if let urlString = userTile.profileImageUrl,
                               let url = URL(string: urlString) {
                                CachedUrlImage(imageUrl: url)
                                    .clipShape(Circle())
                                    .frame(width: 64, height: 64)
                            } else {
                                Circle()
                                    .fill(targetUserColor)
                                    .frame(width: 64, height: 64)
                            }

                            
                         
                            let isFriends =  viewModel.user?.friends?.contains(userTile.id) ?? false
                            
                            
                            VStack(alignment: .leading) {
                                Text(userTile.name ?? "")
                                    .font(.headline)
                                    .foregroundStyle(Color(UIColor.label))

                                if isFriends {
                                    Text("Friended")
                                        .font(.caption)
                                        .foregroundStyle(Color.secondary)
                                }
                            }

                            Spacer()

                            if let clickedState = viewModel.clickedStates[userTile.id], !isFriends{
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    
                                    Task {
                                        if clickedState {
                                            viewModel.unsendFriendRequest(friendUserId: userTile.id)
                                        } else {
                                            viewModel.sendFriendRequest(friendUserId: userTile.id)
                                        }
                                    }
                                } label: {
                                    Text(clickedState ? "Undo" : "Add")
                                        .font(.caption)
                                        .frame(width: 32)
                                }
                                .tint(targetUserColor)
                                .buttonStyle(.bordered)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.thickMaterial)
                        .background(targetUserColor)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }

                if viewModel.hasMoreUsers {
                    ProgressView()
                        .onAppear {
                            viewModel.loadAllUsers()
                        }
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Search 👀")
            .searchable(text: $searchTerm, prompt: "Search")
        }
        .scrollDismissesKeyboard(.interactively)
        .task{
                try? await viewModel.loadCurrentUser()
                viewModel.loadAllUsers()
            
          
        }
    }
}
