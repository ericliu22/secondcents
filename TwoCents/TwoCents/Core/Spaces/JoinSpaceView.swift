//
//  JoinSpaceView.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/10.
//

import SwiftUI

struct JoinSpaceView: View {

    let spaceId: String
    let spaceToken: String
    @State var space: DBSpace?
    @State var loaded: Bool = false

    init(spaceId: String, spaceToken: String) {
        self.spaceId = spaceId
        self.spaceToken = spaceToken
    }

    var body: some View {
        VStack {
            VStack {
                if loaded {
                    if let space {
                        if let urlString = space.profileImageUrl,
                            let url = URL(string: urlString)
                        {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 160, height: 160)

                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(
                                            tint:
                                                Color(UIColor.systemBackground)
                                        )
                                    )
                                    .frame(width: 160, height: 160)
                                    .background(
                                        Circle()
                                            .fill(Color.accentColor)
                                    )
                            }
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
                print("hello")
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

#Preview {
    JoinSpaceView(spaceId: "232D4422-8856-468B-A9F3-E0DAD5180F82", spaceToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MzY2Mjk5NzIsImlhdCI6MTczNjU0MzU3Miwic3ViIjoiMjMyRDQ0MjItODg1Ni00NjhCLUE5RjMtRTBEQUQ1MTgwRjgyIn0.HzhIPrTwl41dD6gC-HPz5YMaizsWANaxVmPYCILUZbw")
}
