//
//  CreateProfileView.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import PhotosUI
import SwiftUI

struct AddMemberView: View {

    @Environment(AppModel.self) var appModel
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @State var viewModel: AddMemberViewModel
    let spaceId: String

    init(spaceId: String) {
        self.spaceId = spaceId
        self.viewModel = AddMemberViewModel(spaceId: spaceId)
    }

    private let noMembersMessage: [String] = [
        "no friends in the industry...",
        "lonely at the top...",
        "solo queuing social media !!",
        "all my friends are bots...",
        "lonely hearts club, membership: me...",
        "just me and my mirror, having deep conversations...",
        "empty Space, full of existential dread...",
        "every night's a solo dance party...",
        "social life on airplane mode...",
        "talking to myself, and we’re getting along great...",
        "my phone autocorrects 'friend' to 'solo'...",
        "i'm not friendless.. i'm just introverted",
        "not having friends -- its a choice.",
    ]

    @Environment(\.dismiss) var dismissScreen
    
    func Icon(userTile: DBUser, targetUserColor: Color) -> some View {
        Group {
            if let urlString = userTile
                .profileImageUrl,
               let url = URL(string: urlString)
            {
                
                //If there is URL for profile pic, show
                //circle with stroke
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(
                            width: 16,
                            height: 16)
                    
                } placeholder: {
                    //else show loading after user uploads but sending/downloading from database
                    
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: Color(
                                    UIColor
                                        .systemBackground
                                ))
                        )
                        .scaleEffect(
                            0.5, anchor: .center
                        )
                        .frame(
                            width: 16,
                            height: 16
                        )
                        .background(
                            Circle()
                                .fill(
                                    targetUserColor
                                )
                                .frame(
                                    width: 16,
                                    height: 16)
                        )
                }
                
            } else {
                
                //if user has not uploaded profile pic, show circle
                Circle()
                
                    .fill(targetUserColor)
                    .frame(
                        width: 16, height: 16)
                
            }
        }
    }

    var body: some View {

        VStack {
            //Selected Members
            VStack(alignment: .leading) {
                Text("Members 👯‍♀️")
                    .font(.title3)
                    .fontWeight( /*@START_MENU_TOKEN@*/
                        .bold /*@END_MENU_TOKEN@*/)

                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack {

                        //No members selected message
                        if viewModel.selectedMembers.count == 0 {
                            Text("Loading...")
                                .italic()
                                .font(.headline)
                                .foregroundStyle(.tertiary)
                                .fontWeight(.regular)
                                .padding(.vertical, 2.5)
                        }

                        //No members selected message
                        if viewModel.selectedMembers.count == 1
                            && (viewModel.selectedMembersUserId[0]
                                == viewModel.user?.userId)
                        {
                            Text(
                                noMembersMessage[
                                    Int.random(in: 0..<(noMembersMessage.count))
                                ]
                            )
                            .italic()
                            .font(.headline)
                            .foregroundStyle(.tertiary)
                            .fontWeight(.regular)
                            .padding(.vertical, 2.5)
                        }

                        ForEach(viewModel.selectedMembers) { userTile in
                            let targetUserColor: Color = viewModel.getUserColor(
                                userColor: userTile.userColor!)

                            if userTile.userId != viewModel.user?.userId {
                                Group {
                                    HStack {
                                        //Circle or Profile Pic
                                        Icon(userTile: userTile, targetUserColor: targetUserColor)
                                        Text(userTile.name!)
                                            .font(.headline)
                                    }
                                }
                                .onTapGesture {
                                    viewModel.removeMember(friend: userTile)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2.5)
                                .background(.thickMaterial, in: Capsule())
                                .background(targetUserColor, in: Capsule())
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)

            //Friends

            VStack(alignment: .leading) {

                Text("Excluded 💔")
                    .font(.title3)
                    .fontWeight( /*@START_MENU_TOKEN@*/
                        .bold /*@END_MENU_TOKEN@*/)

                ScrollView(.horizontal, showsIndicators: false) {

                    HStack {

                        //No friends  message
                        if viewModel.allFriends.count == 0 {
                            Text("All the homies are cordially invited")
                                .italic()
                                .font(.headline)
                                .foregroundStyle(.tertiary)
                                .fontWeight(.regular)
                                .padding(.vertical, 2.5)
                        }

                        ForEach(viewModel.filterFriends()) { userTile in
                            let targetUserColor: Color = viewModel.getUserColor(
                                userColor: userTile.userColor!)
                            Group {
                                HStack {
                                    Group {
                                        //Circle or Profile Pic

                                        if let urlString = userTile
                                            .profileImageUrl,
                                            let url = URL(string: urlString)
                                        {

                                            //If there is URL for profile pic, show
                                            //circle with stroke
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(Circle())
                                                    .frame(
                                                        width: 16, height: 16)

                                            } placeholder: {
                                                //else show loading after user uploads but sending/downloading from database

                                                ProgressView()
                                                    .progressViewStyle(
                                                        CircularProgressViewStyle(
                                                            tint: Color(
                                                                UIColor
                                                                    .systemBackground
                                                            ))
                                                    )
                                                    .scaleEffect(
                                                        0.5, anchor: .center
                                                    )
                                                    .frame(
                                                        width: 16, height: 16
                                                    )
                                                    .background(
                                                        Circle()
                                                            .fill(
                                                                targetUserColor
                                                            )
                                                            .frame(
                                                                width: 16,
                                                                height: 16)
                                                    )
                                            }

                                        } else {

                                            //if user has not uploaded profile pic, show circle
                                            Circle()

                                                .fill(targetUserColor)
                                                .frame(width: 16, height: 16)

                                        }

                                    }

                                    Text(userTile.name!)
                                        .font(.headline)

                                }
                            }
                            .onTapGesture {
                                viewModel.addMember(friend: userTile)
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2.5)
                            .background(.thickMaterial, in: Capsule())
                            .background(targetUserColor, in: Capsule())

                        }
                    }
                }
            }
//            .padding()
//            .background(Color(UIColor.secondarySystemBackground))
//            .cornerRadius(10)

            Button {
                Task {
                    try? await viewModel.saveSpace(spaceId: spaceId, members: canvasViewModel.members.map({ $0.userId }))
                }
                dismissScreen()

            } label: {
                Text("Save")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)

            }
            .disabled(viewModel.selectedMembers.isEmpty)

            .buttonStyle(.bordered)
            .tint(.accentColor)
            .frame(height: 55)
            .cornerRadius(10)

        }
        .padding()
        .task {
            //to prevent list from refreshing when one exits tab and comes back
            if viewModel.selectedMembers.isEmpty {
                try? await viewModel.getAllFriends(
                    userId: appModel.user!.userId)

            }

            try? await viewModel.getSelectedMembers(space: canvasViewModel.space)

        }
        .navigationTitle("Edit Members 😈")
        .toolbar {

            ToolbarItem(placement: .navigationBarLeading) {

                Button(
                    action: {
                        print("HI")
                        Task {
                            //                        try? await viewModel.deleteSpace(spaceId: spaceId)
                        }
                        dismissScreen()
                    },
                    label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(UIColor.label))
                        //                        .font(.title2)
                        //                        .padding()
                    })

            }
        }

    }

}

struct AddMemberView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddMemberView(spaceId: UUID().uuidString)
        }
    }
}
