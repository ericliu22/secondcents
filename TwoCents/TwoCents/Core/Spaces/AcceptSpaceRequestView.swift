//
//  JoinSpaceInviteView.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/23.
//


import SwiftUI

struct AcceptSpaceRequestView: View {
    
    @Environment(AppModel.self) var appModel

    let spaceId: String
    @State var space: DBSpace?
    @State var loaded: Bool = false

    init(spaceId: String) {
        self.spaceId = spaceId
    }

    var body: some View {
        VStack {
            VStack {
                if loaded {
                    if let space {
                        if let urlString = space.profileImageUrl,
                            let url = URL(string: urlString)
                        {
                            CachedImage(imageUrl: url)
                                .clipShape(Circle())
                                .frame(width: 160, height: 160)
                        } else {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 160, height: 160)
                        }
                        Text(space.name ?? "")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.accentColor)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                        if let members = space.members {
                            Text("\(members.count) members")
                                .foregroundStyle(.secondary)
                                .font(.headline)
                        }
                    } else {
                        Text("Invalid space invite link")
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thickMaterial)
            .cornerRadius(20)

            Button {
                appModel.activeSheet = nil
                Task {
                    do {
                        try await acceptSpaceRequest(spaceId: spaceId)
                    } catch {
                        print("Failed to join space")
                    }
                }
            } label: {
                Text("Join Space")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.green)
            .frame(height: 55)
            .cornerRadius(10)
        }
        .task {
            do {
                try await space = SpaceManager.shared.getSpace(spaceId: spaceId)
                loaded = true
            } catch {
                print("FAILED TO LOAD SPACE")
                loaded = true
            }
        }
    }
}
